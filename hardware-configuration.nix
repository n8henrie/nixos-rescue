{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
  ];

  isoImage = {
    makeUsbBootable = true;
    compressImage = true;
    isoName = lib.mkForce "rescue.iso";
    appendToMenuLabel = " Rescue";
  };

  hardware.enableAllFirmware = true;
}
