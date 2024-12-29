{
  config,
  lib,
  inputs,
  ...
}:
{
  walkure.ephemeral.preserve = lib.mkIf config.walkure.ephemeral.enable {
    directories = [
      "/var/lib/systemd"
      "/var/log"
      "/etc/secureboot"
      "/var/db/sudo/lectured"
      {
        directory = "/var/lib/nixos";
        inInitrd = true;
      }
      {
        directory = "/var/cache/tuigreet/";
        user = "greeter";
      } # FIXME Remove with tuigreet
    ];
    files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
        how = "symlink";
      }
    ];

    users.${config.walkure.user.username} = {
      directories = [

        # Vscode
        ".vscode"
        {
          directory = ".config/Code/User";
          configureParent = true;
        }

        {
          directory = ".ssh";
          mode = "0700";
        }

        # Direnv
        ".local/share/direnv"

        ".local/share/zoxide/"

        # User Folders
        "Downloads"
        "Documents"
        "Pictures"
        "Videos"
        "Music"
        "dev"
        "persist"
        "walkure"

        # Browsers
        ".mozilla"
        ".zen"
        ".cache/google-chrome"
        ".cache/mozilla"

        # Games
        ".steam"
        ".local/share/Steam"
        ".local/share/applications" # Steam installs .desktop files here
        ".local/share/PrismLauncher"

        # Shader Cache
        ".cache/mesa_shader_cache"
        ".cache/mesa_shader_cache-db"

        # Other Caches
        ".cargo"
        ".cache/fontconfig"
        ".cache/nix"
        ".local/share/nix" # Repl history

      ];
      files = [
        # Fish Shell
        {
          file = ".local/share/fish/fish_history";
          configureParent = true;
        }
      ];
    };
  };

  # https://github.com/WilliButz/preservation/issues/6
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/state/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /state"
    ];
  };

  # Preservation creates parent folders with root permissions by default.
  # Make sure these common folders always exist with the correct permissions.
  # Avoids specifying configureParent on a lot of items above.

  systemd.tmpfiles.settings.preservation =
    let
      inherit (config.walkure.user) username;
    in
    {
      "/home/${username}/.config".d = {
        user = username;
        group = "users";
        mode = "0755";
      };
      "/home/${username}/.cache".d = {
        user = username;
        group = "users";
        mode = "0755";
      };
      "/home/${username}/.local".d = {
        user = username;
        group = "users";
        mode = "0755";
      };
      "/home/${username}/.local/share".d = {
        user = username;
        group = "users";
        mode = "0755";
      };
      "/home/${username}/.local/state".d = {
        user = username;
        group = "users";
        mode = "0755";
      };
    };
}
