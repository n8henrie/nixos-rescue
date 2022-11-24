{ pkgs
, config
, lib
, modulesPath
, options
, specialArgs
}: {

  imports = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  isoImage = {
    compressImage = true;
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelParams = [ "copytoram" ];
    kernelModules = [ ];
    supportedFilesystems = [
      "btrfs"
      "squashfs"
      "vfat"
      "zfs"
    ];
    loader.grub.memtest86.enable = true;
  };
  environment = {
    systemPackages = with pkgs; [
      arch-install-scripts
      bashInteractive
      fd
      git
      jq
      neovim
      parted
      ripgrep
      rsync
    ];
    variables = {
      EDITOR = "nvim";
    };
    shells = [
      pkgs.bashInteractive
    ];
  };

  users.defaultUserShell = pkgs.bashInteractive;

  # https://github.com/NixOS/nixpkgs/blob/a6968ad43c1b6ab7fc341ddba4ed0a082a24229b/nixos/modules/profiles/installation-device.nix#L36
  # services = {
  #   mingetty.autologinUser = "root";
  #   openssh = {
  #     enable = true;
  #     permitRootLogin = "yes";
  #   };
  # };

  # networking.wireless.enable = mkDefault true;
  # systemd.services.wpa_supplicant.wantedBy = mkOverride 50 [ ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    settings = {
      max-jobs = "auto";
      auto-optimise-store = true;
      cores = 0;
    };
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  system.stateVersion = lib.trivial.release;
}
