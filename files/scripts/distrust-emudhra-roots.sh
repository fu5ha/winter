#!/usr/bin/env bash
set -euo pipefail

# TEMPORARY (Oct 2026): eight eMudhra intermediate CA private keys are
# compromised (CVE-2026-111943, https://emudhra.we-have-a-problem.com/).
# They chain to the "emSign ECC Root CA - G3" and "Comodo AAA Services
# root" roots, which most non-browser clients will keep trusting until
# the system bundle distrusts them. Fedora's fix is ca-certificates
# 2026.2.92_v9.0.319 (NSS 3.131.1 bundle); until the base image ships
# it, blocklist both roots in the trust store as the disclosure site
# recommends for Fedora. This also distrusts legitimate chains under
# those two roots, which is the accepted interim tradeoff.
# Remove this script once `rpm -q ca-certificates` on the booted image
# is >= the version below (the script no-ops from then on anyway).
version=2026.2.92_v9.0.319
installed_version=$(rpm -q --qf '%{VERSION}' ca-certificates)
if [[ $(printf '%s\n' "$version" "$installed_version" | sort -V | head -n 1) == "$version" ]]; then
    echo "ca-certificates $installed_version already distrusts the eMudhra roots."
    exit 0
fi

# Older Fedora layouts called the directory "blacklist".
dir=/etc/pki/ca-trust/source/blocklist
[[ -d $dir ]] || dir=/etc/pki/ca-trust/source/blacklist
mkdir -p "$dir"

blocklist() {
    local filter="$1" file="$2"
    # Skip roots a future bundle no longer ships at all.
    if trust list --filter="$filter" | grep -q 'type: certificate'; then
        trust extract --overwrite --format=pem-bundle --filter="$filter" "$dir/$file"
        echo "Blocklisted $file"
    fi
}

blocklist 'pkcs11:object=Comodo%20AAA%20Services%20root;type=cert' \
    Comodo_AAA_Services_root.pem
blocklist 'pkcs11:object=emSign%20ECC%20Root%20CA%20-%20G3;type=cert' \
    emSign_ECC_Root_CA_-_G3.pem

update-ca-trust

# Fail the build rather than ship a silently still-trusting image: no
# blocklisted label may remain a trust anchor.
if trust list | grep -A2 -E 'label: (Comodo AAA Services root|emSign ECC Root CA - G3)$' \
        | grep -q 'trust: anchor'; then
    echo "eMudhra roots are still trust anchors after blocklisting" >&2
    exit 1
fi
