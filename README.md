# nixos-rescue

NixOS-based rescue image, intended for a USB stick.

Should be able to download an image from releases, or clone and build locally.
Has a convenience target that will run the image in a VM to ensure it has the
tools you're used to: `nix run`.

Has ZFS and BTRFS tools. Tries to start an SSH server automatically.

Please note that by default this permits root access to [my ssh
key](github.com/n8henrie.keys) (see
`users.users.root.openssh.authorizedKeys.keyFiles` in `configuration.nix`) and
uses `root:rescue` as the login credentials, so you may want to change those
settings.
