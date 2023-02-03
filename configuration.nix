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
    makeEfiBootable = true;
    makeUsbBootable = true;
    compressImage = true;
    isoName = lib.mkForce "rescue.iso";
    appendToMenuLabel = " Rescue";
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelParams = [ "copytoram" ];
    kernelModules = [ ];
    loader.timeout = lib.mkForce 0;
    supportedFilesystems = [
      "apfs"
      "btrfs"
      "exfat"
      "ext2"
      "ext4"
      "ntfs"
      "vfat"
      "xfs"
      "zfs"
    ];
  };

  systemd.services = {
    wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];
    sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  };
  services.nscd.enableNsncd = true;

  networking = {
    hostName = "rescue";
    domain = "home.arpa";
    useDHCP = true;
    wireless.enable = true;
  };

  environment = {
    # Many of these are unecessary (automatically imported due to
    # supportedFilesystems, but this makes it explicit)
    systemPackages = with pkgs; [
      arch-install-scripts
      bashInteractive
      ddrescue
      efibootmgr
      efivar
      fd
      gawk
      git
      gptfdisk
      hdparm
      jq
      mkpasswd
      neovim
      parted
      pciutils
      python3
      ripgrep
      rsync
      screen
      sdparm
      smartmontools
      tmux
      unzip
      usbutils
      zip
      zstd
    ];
    variables = {
      EDITOR = "nvim";
    };
    shells = [
      pkgs.bashInteractive
    ];
  };

  users = {
    defaultUserShell = pkgs.bashInteractive;
    mutableUsers = false;
    users = {
      root = {
        password = "nixos-rescue";
        openssh.authorizedKeys.keyFiles = [
          (builtins.fetchurl {
            url = "https://github.com/n8henrie.keys";
            sha256 = "1zhq1r83v6sbrlv1zh44ja70kwqjifkqyj1c258lki2dixqfnjk7";
          })
        ];
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

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
