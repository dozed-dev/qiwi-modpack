{ nix-minecraft, pkgs, lib, ... }: {
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = let
    authlib-injector = pkgs.fetchurl {
      url = "https://github.com/yushijinhun/authlib-injector/releases/download/v1.2.5/authlib-injector-1.2.5.jar";
      hash = "sha256-O8nr3Fg7NqvSpltibEufNfIRd/v0KoUWBuquo/1C7g8=";
    };
    modpack = pkgs.fetchPackwizModpack {
      url = "https://raw.githubusercontent.com/dozed-dev/qiwi-modpack/main/packwiz/pack.toml";
      packHash = "sha256-56O2JT77Ayf8OCsED52y6IKRZ+0zAE8Qc4K/B3GS/8I=";
    };
    mcVersion = modpack.manifest.versions.minecraft;
    fabricVersion = modpack.manifest.versions.fabric;
    serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
  in {
    enable = true;
    eula = true;
    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };
    servers = {
      test-server1 = {
        enable = true;
        autoStart = false;
        package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
        symlinks = {
          "mods" = "${modpack}/mods";
          "allowed_symlinks.txt" = pkgs.writeText "allowed_symlinks.txt" "/nix/store";
        } // (
          with builtins;
          let
            getFilesRecursively = path:
              lib.lists.concatMap (path:
                if path.value == "directory"
                then (getFilesRecursively path.name)
                else [path]
              ) (
                map (file: {
                  value = file.value;
                  name = "${path}/${file.name}";
                }) (
                  lib.attrsets.attrsToList (readDir path)
                )
              );
            relPath = root: path:
                unsafeDiscardStringContext (substring
                  (stringLength (toString root) + 1)
                  (-1)
                  (toString path));
            zipListsToAttrset = names: values:
              lib.listToAttrs (
                lib.zipListsWith
                  (name: value: { inherit name value; })
                  names values
              );
            configFileList = map (file: file.name) (getFilesRecursively "${modpack}/config");
            relPaths = map (relPath modpack) configFileList;
            configFilesAttrset = zipListsToAttrset relPaths (map toString configFileList);
          in configFilesAttrset
        );

        serverProperties = {
          serverPort = 25565;
        };
        jvmOpts = "-javaagent:${authlib-injector}=ely.by";
      };
    };
  };
}
