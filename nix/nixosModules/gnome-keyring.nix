#TODO: Replace with oo7 when it is more feature complete.
{
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  # Dont use for ssh, as gnome-keyring doesnt work properly with -sk keys

  /*
    environment.sessionVariables = {
      SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh";
    };
  */

  # Auto start keyring
  home-manager.sharedModules = [
    {
      services.gnome-keyring = {
        enable = true;
        components = [
          "secrets"
          # "ssh"
        ];
      };
    }
  ];
}
