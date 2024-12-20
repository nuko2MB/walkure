{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
}
