{
  description = "qiwi (personal Minecraft modpack)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    packwiz2nix = {
      url = "github:dozed-dev/packwiz2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          hash = "sha256-7M38w7N5sdYkSfBh14M9GhZSEWZdOyTe0+Blf3hpigk=";
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

