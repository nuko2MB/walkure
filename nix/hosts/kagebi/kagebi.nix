{
  inputs',
  inputs,
  pkgs,
  hostname,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./kanata.nix
    ./sound.nix
    ./tailscale.nix
    ./audiobookshelf.nix
    ./virt.nix
    ./caddy.nix
    ./vikunja.nix
    ./adguard.nix
    # ./lact.nix
  ];

  age.secrets.kagebi-pw.rekeyFile = inputs.self + "/secrets/kagebi-pw.age";
  walkure.user.hashedPasswordFile = config.age.secrets.kagebi-pw.path;

  walkure = {
    cosmic-niri.enable = false;

    fileSystem.btrfs = {
      enable = true;
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_232859801809";
    };
    ephemeral.enable = true;

    bootloader = {
      enable = true;
      secureBoot = false;
    };

    network = {
      device = "enp8s0";
      enable = true;
      staticIPV4 = {
        enable = true;
        address = "10.10.10.44/16";
      };
    };

    /*
      services.samba = {
        enable = true;
        paths = [ "/srv/share" ];
      };
    */
  };

  services.desktopManager.cosmic.enable = true;

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYN6PEtmqPcLFobhKsv3nkdGLonysu2eJWCrJjlLSAK root@kagebi";
    # localStorageDir = inputs.self + "/secrets/rekeyed/${config.networking.hostName}";
  };

  # AMDGPU bug fix in 6.13
  # TODO: Revert to latest when 6.13 is released
  boot.kernelPackages = pkgs.linuxPackages_testing;

  programs = {
    fish.enable = true;
    nh = {
      flake = "/home/${config.walkure.user.username}/walkure?submodules=1";
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 10";
      };
    };
    niri = {
      enable = true;
      package = inputs'.niri.packages.niri-stable;
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;
  };

  # FFXIV OTP APP
  networking.firewall = {
    allowedTCPPorts = [ 4646 ];
    # allowedUDPPorts = [ 4646 ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 45;
  };

  services = {
    pcscd.enable = true; # age-plugin-yubi
    # fwupd.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session --remember --remember-session --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
          user = "greeter";
        };
      };
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts
      noto-fonts
      noto-fonts-emoji
      inter
      roboto
      ubuntu_font_family
      # noto-fonts-cjk-sans
      # noto-fonts-cjk-serif

      # Mono
      nerd-fonts.jetbrains-mono
      # nerd-fonts.monaspace
      source-code-pro
      monaspace

      # REPLACE
      symbola
      menomonia
    ];
    # nerdFonts = [ "JetBrainsMono" ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" ];
        monospace = [ "Monaspace Neon" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = 1;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    http-connections = 50;
    warn-dirty = false;

    auto-optimise-store = true;
    substituters = [
      "https://cosmic.cachix.org/"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

  hardware = {
    amdgpu.initrd.enable = true;
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
      ];
      extraPackages32 = with pkgs.driversi686Linux; [ intel-media-driver ];
    };
  };

  boot.initrd.kernelModules = [ "i915" ]; # xe

  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=15
  '';

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_CA.UTF-8";

  system.stateVersion = "23.11";
}
