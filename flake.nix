{
  description = "qiwi (personal Minecraft modpack)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    packwiz2nix.url = "github:getchoo/packwiz2nix/rewrite";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    packwiz2nix,
    self,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      inherit
        (packwiz2nix.lib.${system})
        fetchPackwizModpack
        mkMultiMCPack
        ;
    in {
      packages = {
        modpack = fetchPackwizModpack {
          manifest = "${self}/pack.toml";
          hash = "sha256-Bs04hnAXwirwn7krfYlCr4RiRhXLX3Sw0G0FdxlDnsg=";
        };
        modpack-zip = mkMultiMCPack {
          src = self.packages.${system}.modpack;
          instanceCfg = ./files/instance.cfg;
        };
        default = self.packages.${system}.modpack-zip;
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          packwiz
          unzip
          zip
        ];
      };
    }
  );
}

