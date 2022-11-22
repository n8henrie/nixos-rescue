{
  description = "NixOS-based rescue drive";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux = rec {
      default = rescue;
      rescue = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "install-iso";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
