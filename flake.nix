{
  description = "NixOS-based rescue drive";
  inputs.nixos.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixos }: {
    packages.x86_64-linux = rec {
      default = rescue.config.system.build.isoImage;
      rescue = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
