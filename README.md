# winter &nbsp; [![bluebuild build badge](https://github.com/fu5ha/winter/actions/workflows/build.yml/badge.svg)](https://github.com/fu5ha/winter/actions/workflows/build.yml)

My BlueBuild image(s).

See the [BlueBuild docs](https://blue-build.org/how-to/setup/).

See also, [nix-home-manager](https://github.com/fu5ha/nix-home-manager) which is how I config dev tooling with this.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/fu5ha/winter
```

## Temporary notes

### eMudhra CA compromise (2026-10-21)

`files/scripts/distrust-emudhra-roots.sh` blocklists the emSign ECC Root CA - G3 and Comodo AAA Services roots in the trust store. Compromised eMudhra intermediates chain to those roots (CVE-2026-111943).

Check from time to time whether the base image now ships Fedora `ca-certificates` 2026.2.92_v9.0.319 or later (`rpm -q ca-certificates`). The script no-ops once it does. Then remove the script, its module entry in `recipes/winter.yaml`, and this note. Confirm removal is safe by checking that `curl https://dv-g3b-emudhra.we-have-a-problem.com/` fails with a certificate error.
