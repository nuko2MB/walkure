{
  lib,
  config,
  ...
}:
let
  mkHomes = lib.mapAttrs (
    name: args: {
      inherit (args) system;
      modules = args.modules ++ (lib.attrValues config.homeModules);
      extraSpecialArgs = {
        homename = name;
      };
    }
  );
in
mkHomes (import ./homes.nix)
