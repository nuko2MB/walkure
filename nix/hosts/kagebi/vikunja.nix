_: {
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "127.0.0.1";
    settings = {
      service = {
        enableregistration = false;
        timezone = "America/Denver";
      };
    };
  };

  walkure.ephemeral.preserve.directories = [
    {
      directory = "/var/lib/private/vikunja";
      mode = "0755";
      user = "vikunja";
    }
  ];
}
