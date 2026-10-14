#!/usr/bin/env bash
set -euo pipefail

# Build against the image's Fedora libraries, not Rawhide's.
# Remove this override once Fedora 44 ships uresourced >= 0.5.5.
version=0.5.5
installed_version=$(rpm -q --qf '%{VERSION}' uresourced)
if [[ $(printf '%s\n' "$version" "$installed_version" | sort -V | head -n 1) == "$version" ]]; then
    echo "uresourced $installed_version already includes the priority-loop fix."
    exit 0
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
mkdir -p "$workdir"/{SOURCES,SPECS}
cp "$(dirname "$0")/../rpmbuild/uresourced.spec" "$workdir/SPECS/"

archive="$workdir/SOURCES/uresourced-v$version.tar.bz2"
curl --fail --location --retry 3 \
    "https://gitlab.freedesktop.org/benzea/uresourced/-/archive/v$version/uresourced-v$version.tar.bz2" \
    --output "$archive"
echo "bd73130559c09c46e317a52267685ac6d6af1b05c4eb082140c779d912c9592e  $archive" \
    | sha256sum --check

# Remove build tools afterwards unless they were already in the image.
build_packages=(
    gcc meson rpm-build glib2-devel pipewire-devel systemd-devel
    systemd-rpm-macros pkgconf-pkg-config
)
added_build_packages=()
for package in "${build_packages[@]}"; do
    if ! rpm -q "$package" > /dev/null; then
        added_build_packages+=("$package")
    fi
done
# systemd supplies pkgconfig(systemd) and is a runtime dependency too.
dnf5 install -y --setopt=install_weak_deps=False systemd "${build_packages[@]}"
rpmbuild -bb --define "_topdir $workdir" "$workdir/SPECS/uresourced.spec"

dnf5 install -y --setopt=install_weak_deps=False \
    "$workdir"/RPMS/*/uresourced-"$version"-*.rpm

if (( ${#added_build_packages[@]} )); then
    dnf5 remove -y --no-autoremove "${added_build_packages[@]}"
fi
dnf5 clean all

[[ $(rpm -q --qf '%{VERSION}' uresourced) == "$version" ]]
