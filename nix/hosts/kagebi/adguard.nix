{
  # TODO Declarative adguard config.
  services.adguardhome = {
    openFirewall = true;
    enable = true;
  };

  walkure.network.DNS = "127.0.0.1";

  walkure.ephemeral.preserve.directories = [
    {
      directory = "/var/lib/private/AdGuardHome";
      mode = "0755";
      user = "adguardhome";
      group = "adguardhome";
    }
  ];

  services.resolved.extraConfig = ''
    DNS=::1 127.0.0.1
    DNSStubListener=no
  '';
}
