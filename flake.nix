{
  description = "qiwi (personal Minecraft modpack)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = {
    nixpkgs,
    nix-minecraft,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      overlays = [nix-minecraft.overlay];
      inherit system;
      config.allowUnfree = true;
    };
  in {
    devShells."${system}".default = pkgs.mkShell {
      packages = with pkgs; [
        packwiz
        unzip
        zip
        temurin-jre-bin-21
        toml-cli
      ];
    };
    nixosModules = {
      server = import ./server.nix {inherit nix-minecraft pkgs;};
    };
  };
}

