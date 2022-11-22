{ pkgs
, config
, lib
, modulesPath
, options
, specialArgs
}: {
  isoImage.isoName = lib.mkForce "rescue.iso";
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelParams = [ "copytoram" ];
    initrd = {
      availableKernelModules = [ ];
      supportedFilesystems = [
        "zfs"
        "btrfs"
        "vfat"
      ];
    };
  };
  environment = {
    systemPackages = with pkgs; [
      arch-install-scripts
      bashInteractive
      fd
      jq
      neovim
      parted
      ripgrep
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
}
