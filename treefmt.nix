# treefmt.nix
{ pkgs, lib, ... }:
{
  programs = {
    just.enable = true;
    /*
      biome = {
        enable = true;
        includes = lib.mkOptionDefault [ "*.css" ];
      };
    */
    prettier.enable = true;
    nixfmt.enable = true;
    nufmt.enable = true;
    statix.enable = false;
  };
}
