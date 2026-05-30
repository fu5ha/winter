{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv) system;
in
{
  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.jujutsu
    pkgs.nushell
    inputs.bluebuild-cli.packages.${system}.default
  ];

  languages = {
    nix.enable = true;
  };

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.validate = {
    exec = ''
      glob -d 1 ./recipes/*.yaml | each { |f| ^bluebuild validate $f }
    '';
    package = pkgs.nushell;
    binary = "nu";
  };

  # See full reference at https://devenv.sh/reference/options/
}
