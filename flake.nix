{
  description = "qiwi (personal Minecraft modpack)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          packwiz
          unzip
          zip
          temurin-jre-bin-21
          toml-cli
        ];
      };
    } // {
      server = import ./server.nix;
    }
  );
}

