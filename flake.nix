{
  description = "NixOS-based rescue drive";
  inputs.nixos.url = "nixpkgs/nixos-22.11";
  outputs = {
    self,
    nixos,
  }: let
    system = "x86_64-linux";
  in {
    packages.x86_64-linux = rec {
      default = rescue.config.system.build.isoImage;
      rescue = nixos.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
        ];
      };
      vm =
        (nixos.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            (nixos + "/nixos/modules/virtualisation/qemu-vm.nix")
            (nixos + "/nixos/modules/profiles/qemu-guest.nix")
            ({
              config,
              pkgs,
              ...
            }: {
              virtualisation.graphics = false;
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
