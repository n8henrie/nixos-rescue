{
  description = "NixOS-based rescue drive";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      nixos =
        let src = (import nixpkgs { inherit system; }).applyPatches {
          name = "nixos-rescue-patches";
          src = nixpkgs;
          patches = [ ./iso-image.patch ];
        };
        in
        nixpkgs.lib.fix (self: (import "${src}/flake.nix").outputs { inherit self; });
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
      };
    };
}
