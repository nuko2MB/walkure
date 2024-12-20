{ pkgs, config, ... }:
{
  services.tailscale = {
    openFirewall = true;
    enable = true;
    extraSetFlags = [
      "--advertise-routes=10.10.0.0/16"
    ];
  };

  # Does tailscale require the state here other than login information?
  # Can maybe be removed later with proper secret setup
  walkure.ephemeral.preserve.directories = [
    {
      directory = "/var/lib/tailscale";
      mode = "0700";
    }
  ];

  systemd.network = {
    config.networkConfig = {
      # Tailscale router
      IPv4Forwarding = "yes";
      IPv6Forwarding = "yes";
    };
  };

  # See https://tailscale.com/kb/1320/performance-best-practices#ethtool-configuration.
  systemd.services.tailscale-transport-layer-offloads = {
    description = "Tailscale: better performance for exit nodes";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/sbin/ethtool -K enp8s0 rx-udp-gro-forwarding on rx-gro-list off";
    };
    wantedBy = [ "default.target" ];
  };

  # always allow traffic from your Tailscale network
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}
