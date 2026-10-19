#!/usr/bin/env bash
set -euo pipefail

# Install vaultbroker (pinned release binary from fu5ha/vaultbroker) and
# the Bitwarden CLI it drives. Bump versions and hashes together.
vaultbroker_version=0.2.0
vaultbroker_sha256=196b33937a00fc99dc0ec8a9e192356d62562d69add6e5ea11e2661005fd42eb
bw_version=2026.10.0
bw_sha256=269b67559caab860d1737f7554b32bdb8be9285d5689fee55193c137a0df9973

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

curl --fail --location --retry 3 \
    "https://github.com/fu5ha/vaultbroker/releases/download/v${vaultbroker_version}/vaultbroker-linux-amd64" \
    --output "$workdir/vaultbroker"
echo "$vaultbroker_sha256  $workdir/vaultbroker" | sha256sum --check
install -Dm0755 "$workdir/vaultbroker" /usr/libexec/vaultbroker

curl --fail --location --retry 3 \
    "https://github.com/bitwarden/clients/releases/download/cli-v${bw_version}/bw-linux-${bw_version}.zip" \
    --output "$workdir/bw.zip"
echo "$bw_sha256  $workdir/bw.zip" | sha256sum --check
python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extract("bw", sys.argv[2])' \
    "$workdir/bw.zip" "$workdir"
install -Dm0755 "$workdir/bw" /usr/bin/bw
