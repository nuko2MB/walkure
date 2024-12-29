{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  cosmic-ext-alternative-startup,
  bash,
  dbus,
}:
stdenvNoCC.mkDerivation {
  pname = "cosmic-ext-niri";
  version = "unstable-2024-11-1";

  src = fetchFromGitHub {
    owner = "drakulix";
    repo = "cosmic-ext-extra-sessions";
    rev = "6cc38de1d9840110aef1210e9b04d495a3e244e97";
    hash = "sha256-UX/Iym7UObVCcOdjVpQExojeaqKIT5SNTGPdAX48/lM=";
    sparseCheckout = [ "niri" ];
  };

  passthru.providedSessions = [ "cosmic-ext-niri" ];

  installPhase = ''
    install -Dm644 $src/niri/cosmic-ext-niri.desktop -t $out/share/wayland-sessions
    install -Dm755  $src/niri/start-cosmic-ext-niri -t $out/bin
  '';

  postFixup = ''
    substituteInPlace "$out/share/wayland-sessions/cosmic-ext-niri.desktop" \
      --replace-fail "Exec=/usr/bin/start-cosmic-ext-niri" "Exec=start-cosmic-ext-niri"

    patchShebangs $out/bin
    substituteInPlace "$out/bin/start-cosmic-ext-niri" \
      --replace-fail "/usr/bin/dbus-run-session" "${dbus}/bin/dbus-run-session" \
      --replace-fail "/usr/bin/cosmic-session" "cosmic-session"
  '';
}
