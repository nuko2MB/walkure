{
  pkgs,
  config,
  inputs',
  ...
}:
{
  home.packages = with pkgs; [
    inputs'.zen-browser.packages.default
    stremio

    # cli general
    glxinfo
    killall
    fzf
    pciutils
    usbutils
    wget
    curl
    appimage-run
    nushell
    ouch
    ripgrep
    fd
    xdg-utils
    just
    fastfetch

    # chattr
    e2fsprogs

    # nix
    nixfmt-rfc-style
    nix-prefetch-git
    nix-output-monitor
    nix-update
    nixd
    statix
    tree-fmt-nix-wrapped

    # Desktop general
    floorp
    google-chrome
    qbittorrent
    discord
    yt-dlp
    resources
    mission-center

    libva
    libva-utils

    # Games
    (prismlauncher.override {
      jdks = with pkgs; [
        jdk8
        jdk17
        jdk21
      ];
    })
   # bottles
    heroic
    xivlauncher
    wineWow64Packages.stagingFull
  ];

  home.file."bin/wineWow64".source =
    config.lib.file.mkOutOfStoreSymlink pkgs.wineWow64Packages.stagingFull;
}
