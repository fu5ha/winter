# winter &nbsp; [![bluebuild build badge](https://github.com/fu5ha/winter/actions/workflows/build.yml/badge.svg)](https://github.com/fu5ha/winter/actions/workflows/build.yml)

My BlueBuild image(s).

See the [BlueBuild docs](https://blue-build.org/how-to/setup/).

See also, [nix-home-manager](https://github.com/fu5ha/nix-home-manager) which is how I config dev tooling with this.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/fu5ha/winter
```
