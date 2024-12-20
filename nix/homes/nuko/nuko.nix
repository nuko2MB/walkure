{
  lib,
  pkgs,
  inputs',
  ...
}:
{
  imports = [
    ./packages.nix
    ./vscode.nix
    ./niri.nix
  ];

  walkure = {
    firefox.enable = true;
  };

  home = {
    stateVersion = "23.11";
    username = "nuko";
    homeDirectory = "/home/nuko";
    shellAliases = {
      ls = "eza";
      cat = "bat";
      "@" = "${pkgs.just}/bin/just ~/walkure/";
    };
  };

  xdg.portal = {
    xdgOpenUsePortal = true;
  };

  programs.mangohud = {
    enable = true;
    /*
      settings = {
        fps_only = 1;
        fps_limit = 168;
      };
    */
  };

  xdg.configFile."MangoHud/presets.conf".text = ''
    [preset 1]
    no_display

    [preset 2]
    fps_only=1
    alpha=0.6

    [preset 3]
    fps
    frametime
    gpu_stats
    gpu_temp
    gpu_junction_temp
    gpu_power
    gpu_core_clock
    gpu_voltage
    gpu_fan
    cpu_stats=0
    throttling_status
  '';

  programs = {
    nix-index-database.comma.enable = true;
    eza.enable = true;
    broot.enable = true;
    fish.enable = true;
    foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "Monaspace Neon:size=12";
          dpi-aware = "yes";
        };
      };
    };

    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    starship.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        keys.normal = {
          space.e = "file_browser";
          space.E = "file_browser_in_current_directory";
        };
      };

      languages = { };
    };

    # FIXME: mpv does not start with vulkan.
    # Works when using opengl or dmabuf-wayland
    mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        thumbfast
        modernz
        autoload
        mpris
      ];
      config = {
        hwdec = "auto-safe";
        gpu-context = "wayland";
        vo = "gpu-next";
        profile = "high-quality";
        gpu-api = "vulkan";
      };
    };

    # Git
    # Retrieve the resident key handle from yubikey with
    # ssh-keygen -K
    git = {
      enable = true;
      userEmail = "git@nuko.boo";
      userName = "nuko";
      signing = {
        signByDefault = true;
        key = "~/.ssh/id_ed25519_sk.pub";
      };
      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
    };
    lazygit.enable = true;
    gh.enable = true;
  };

  # Add public ssh key so git will sign commits with it.
  home.file.".ssh/allowed_signers".text =
    ''git@nuko.boo namespaces="git" sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGoPvIrvztlQy8iflV+UO3oVf52pH4iGsHB/XVjPbd5CAAAABHNzaDo= yubikey@nuko.boo'';

}
