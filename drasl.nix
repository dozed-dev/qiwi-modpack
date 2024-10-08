{ drasl, ... }: {
  imports = [ drasl.nixosModules.drasl ];
  services.drasl = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./drasl-config.toml);
  };
}
