# Adapted from Fedora's uresourced.spec:
# https://src.fedoraproject.org/rpms/uresourced/blob/rawhide/f/uresourced.spec
Name:           uresourced
Version:        0.5.5
Release:        1.winter%{?dist}
Summary:        Dynamically allocate resources to the active user

License:        LGPL-2.1-or-later
URL:            https://gitlab.freedesktop.org/benzea/uresourced
Source0:        %{url}/-/archive/v%{version}/%{name}-v%{version}.tar.bz2

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  pkgconfig(libsystemd)
BuildRequires:  pkgconfig(systemd)
BuildRequires:  systemd-rpm-macros

%description
This daemon dynamically assigns a resource allocation to the active
graphical user. If the user has an active graphical session managed
using systemd, the memory allocation protects the session's core processes.

%prep
%autosetup -n %{name}-v%{version} -p1

%build
%meson -Dappmanagement=true
%meson_build

%install
%meson_install

%post
# Before 0.5.5, the system daemon accidentally persisted its allocations.
shopt -s nullglob
for f in /etc/systemd/system.control/user{@*.service.d,-*.slice.d}/50-{CPUWeight,IOWeight,MemoryLow,MemoryMin}.conf; do
    rm -f "$f" || true
done
for d in /etc/systemd/system.control/user{@*.service.d,-*.slice.d}; do
    rmdir --ignore-fail-on-non-empty "$d" || true
done
shopt -u nullglob
%systemd_post uresourced.service
%systemd_user_post uresourced.service

%preun
%systemd_preun uresourced.service
%systemd_user_preun uresourced.service

%postun
%systemd_postun uresourced.service
%systemd_user_postun uresourced.service

%files
%license COPYING
%doc README NEWS.md
%config(noreplace) %{_sysconfdir}/uresourced.conf
%{_datadir}/dbus-1/system.d/org.freedesktop.UResourced.conf
%{_libexecdir}/uresourced
%{_libexecdir}/cgroupify
%{_unitdir}/*
%{_userunitdir}/*

%changelog
* Wed Oct 14 2026 Gray Olson <gray@grayolson.com> - 0.5.5-1.winter
- Build upstream's priority-loop fix for Winter on Fedora 44.
