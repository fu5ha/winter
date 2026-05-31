# Nix does not like home being a symlink, use the real path instead
HOME=$(readlink -f "$HOME")
export HOME

# Make sure XDG_DATA_HOME and XDG_CONFIG_HOME set, needed for CI
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
