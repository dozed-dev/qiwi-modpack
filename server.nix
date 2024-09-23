{ nix-minecraft, pkgs, ... }: {
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = let
    authlib-injector = pkgs.fetchurl {
      url = "https://github.com/yushijinhun/authlib-injector/releases/download/v1.2.5/authlib-injector-1.2.5.jar";
      hash = "sha256-O8nr3Fg7NqvSpltibEufNfIRd/v0KoUWBuquo/1C7g8=";
    };
    modpack = pkgs.fetchPackwizModpack {
      url = "https://raw.githubusercontent.com/dozed-dev/qiwi-modpack/f68e1965bfe848729d9cf5ae06aa877cff2d3d8d/packwiz/pack.toml";
      packHash = "sha256-ZcGUsAFaPCdVmzGt7Fe/UynvDz98ChAdThp4+TmUtws=";
    };
  in {
    enable = true;
    eula = true;
    servers = {
      test-server1 = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21.override { loaderVersion = "0.16.5"; };
        symlinks = {
          "mods" = "${modpack}/mods";
          "config" = "${modpack}/config";
        };

        serverProperties = {
          serverPort = 25565;
        };
        jvmOpts = "-javaagent:${authlib-injector}=ely.by";
      };
    };
  };
}
