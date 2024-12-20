{ config, hostname, ... }:
{
  walkure.ephemeral.preserve.directories = [
    "/var/lib/${config.services.audiobookshelf.dataDir}"
  ];

  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 6543;
  };
}
