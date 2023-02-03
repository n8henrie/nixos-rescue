{
  description = "NixOS-based rescue drive";
  inputs.nixos.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixos }:
    let
      system = "x86_64-linux";
    in
    {
      packages.x86_64-linux = rec {
        default = rescue.config.system.build.isoImage;
        rescue = nixos.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
          ];
        };
        vm = (nixos.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            (nixos + "/nixos/modules/virtualisation/qemu-vm.nix")
            ({ config, pkgs, ... }: {
              virtualisation.qemu.options = [ "-nographic" ];
            })
          ];
        }).config.system.build.vm;
      };
      apps.x86_64-linux.default = {
        type = "app";
        program = "${self.outputs.packages.x86_64-linux.vm}/bin/run-rescue-vm";
      };
    };
}
