{
  description = "NixOS-based rescue drive";
  inputs.nixos.url = "nixpkgs/master";
  outputs = {
    self,
    nixos,
  }: let
    system = "aarch64-linux";
  in {
    nixosModules = rec {
      default = rescue;
      rescue.imports = [./configuration.nix];
    };
    packages.x86_64-linux = rec {
      default = rescue.config.system.build.isoImage;
      rescue = nixos.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
          ./hardware-configuration.nix
        ];
      };
      vm =
        (nixos.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.default
            ./hardware-configuration.nix
            (nixos + "/nixos/modules/virtualisation/qemu-vm.nix")
            (nixos + "/nixos/modules/profiles/qemu-guest.nix")
            ({
              config,
              pkgs,
              ...
            }: let
              isoimage = pkgs.runCommandLocal "rescue.iso" {} ''
                set -Eeuf -o pipefail
                set -x
                rescue=${self.outputs.packages.x86_64-linux.default}/iso/rescue.iso
                if [ "${toString config.isoImage.compressImage}" ]; then
                  ${pkgs.zstd}/bin/zstd --decompress --keep --stdout "''${rescue}.zst" > $out
                else
                  ln -s "$rescue" $out
                fi
              '';
            in {
              virtualisation = {
                memorySize = 2048;
                graphics = false;
                useDefaultFilesystems = false;
                diskImage = "/dev/null";
                fileSystems."/" = {
                  fsType = "tmpfs";
                  options = ["mode=0755"];
                };
                forwardPorts = [
                  {
                    from = "host";
                    host.port = 2222;
                    guest.port = 22;
                  }
                ];
                qemu = {
                  drives = [
                    {
                      file = "${isoimage}";
                      driveExtraOpts = {
                        media = "cdrom";
                        format = "raw";
                        readonly = "on";
                      };
                    }
                  ];
                };
              };
            })
          ];
        })
        .config
        .system
        .build
        .vm;
    };
    apps.x86_64-linux.default = {
      type = "app";
      program = "${self.outputs.packages.x86_64-linux.vm}/bin/run-rescue-vm";
    };
  };
}
