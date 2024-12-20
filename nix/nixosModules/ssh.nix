{
  programs.ssh = {
    startAgent = true;
  };

  walkure.ephemeral.preserve.files = [
    {
      file = "/etc/ssh/ssh_host_ed25519_key";
      mode = "0700";
      inInitrd = true;
    }
    {
      file = "/etc/ssh/ssh_host_ed25519_key.pub";
      inInitrd = true;
    }
    {
      file = "/etc/ssh/ssh_host_rsa_key";
      mode = "0700";
      inInitrd = true;
    }
    {
      file = "/etc/ssh/ssh_host_rsa_key.pub";
      inInitrd = true;
    }
  ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/state/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/state/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  home-manager.sharedModules = [
    {
      programs.ssh = {
        enable = true;
        # addKeysToAgent = "yes"; # No work
      };
    }
  ];
}
