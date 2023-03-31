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

The configuration is split into the general settings (packages, users, etc.) in
`configuration.nix`, which can be separately importable as
`rescue.nixosModules.default`, and `hardware-configuration.nix` (I should
probably choose a different name) which has the settings for putting it ont a
bootable drive.

The advantage here is that the module settings can be imported as a separate
boot target on a machine, which I was inspired to attempt [by this
config](https://github.com/cleverca22/nixos-configs/blob/0055f11b62b3278adebdfa115386e0ccf3d350f8/rescue_boot.nix).
For example, on one of my machines, I import this module, minimally modified
from that link, which gives me a `NixOS Rescue` boot target, complete with all
my settings configured in this flake. Once I've added this flake as an input, I
can just import this module in a config and have a machine automatically
provide a separate boot target. NB: if copying this, you'll likely want to
remove the `@boot/` subvolume I added below.

```nix
{
  pkgs,
  rescue,
  ...
}: let
  netboot = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit (pkgs) system;
    modules = [
      (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
      rescue.nixosModules.default
    ];
  };
in {
  boot.loader.grub.extraEntries = ''
    menuentry "NixOS Rescue" {
      linux ($drive1)/@boot/rescue-kernel init=${netboot.config.system.build.toplevel}/init ${toString netboot.config.boot.kernelParams}
      initrd ($drive1)/@boot/rescue-initrd
    }
  '';
  boot.loader.grub.extraFiles = {
    "rescue-kernel" = "${netboot.config.system.build.kernel}/bzImage";
    "rescue-initrd" = "${netboot.config.system.build.netbootRamdisk}/initrd";
  };
}
```
