{ config, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.${config.walkure.user.username} = {
    extraGroups = [ "libvirtd" ];
  };

  # chattr +C /var/lib/libvirt or /btfsroot/@state/var/lib/libvirt ?
  walkure.ephemeral.preserve.directories = [ "/var/lib/libvirt" ];

  home-manager.sharedModules = [
    {
      dconf.settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };
      };
    }
  ];
}
