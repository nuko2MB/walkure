{
  inputs,
  lib,
  config,
  flakelight,
  ...
}:
let
  mkSystems = lib.mapAttrs (
    name: args: {
      inherit (args) system;

      specialArgs = {
        inherit (config) nixDir;
      };

      modules =
        args.modules
        ++ (lib.attrValues config.nixosModules)
        ++ [
          { }
        ];
    }
  );
in
mkSystems (import ./hosts.nix)
