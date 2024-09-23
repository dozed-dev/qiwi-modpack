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
  }: {
    nixosModules = {
      server = let
        pkgs = import nixpkgs {
          overlays = [nix-minecraft.overlay];
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      in {
        imports = [ nix-minecraft.nixosModules.minecraft-servers ];

        services.minecraft-servers =
          let authlib-injector = pkgs.fetchurl {
            url = "https://github.com/yushijinhun/authlib-injector/releases/download/v1.2.5/authlib-injector-1.2.5.jar";
            hash = "sha256-O8nr3Fg7NqvSpltibEufNfIRd/v0KoUWBuquo/1C7g8=";
          };
        in {
          enable = true;
          eula = true;
          servers = {
            test-server1 = {
              enable = true;
              package = pkgs.vanillaServers.vanilla-1_21;

              serverProperties = {
                serverPort = 25565;
              };
              jvmOpts = "-javaagent:${authlib-injector}=ely.by";
            };
          };
        };
      };
    };
  };
}

