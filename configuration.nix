{
  pkgs,
  config,
  lib,
  modulesPath,
  options,
  specialArgs,
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
  ];

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [
      "copytoram"
      "console=ttyS0,115200"
      "console=tty1"
      "boot.shell_on_fail"
    ];
    kernelModules = [];
    loader.timeout = lib.mkForce 0;
    binfmt.emulatedSystems = ["aarch64-linux"];
    supportedFilesystems = [
      # "apfs"
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

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    compressImage = true;
    isoName = lib.mkForce "rescue.iso";
    appendToMenuLabel = " Rescue";
  };

  services = {
    nscd.enableNsncd = true;
    openssh.enable = true;
  };

  networking = {
    hostName = "rescue";
    domain = "home.arpa";
    useDHCP = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  environment = {
    # Many of these are unecessary (automatically imported due to
    # supportedFilesystems), but this makes it explicit
    systemPackages = with pkgs; [
      arch-install-scripts
      bashInteractive
      coreutils
      curl
      ddrescue
      diffutils
      efibootmgr
      efivar
      fd
      file
      findutils
      gawk
      git
      gnugrep
      gnused
      gnutar
      gptfdisk
      hdparm
      inetutils
      jq
      less
      lsof
      mkpasswd
      neovim
      parted
      pciutils
      python311
      ripgrep
      rsync
      screen
      sdparm
      shellcheck
      shfmt
      smartmontools
      time
      tmux
      unzip
      usbutils
      wget
      which
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
        password = "rescue";
        openssh.authorizedKeys.keyFiles = [
          (builtins.fetchurl {
            url = "https://github.com/n8henrie.keys";
            sha256 = "0f5zh39s2xdr6hw3i8q2p3yr713wjj5h7sljgxfkysfsrmf99ypb";
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
