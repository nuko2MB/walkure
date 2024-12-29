{ inputs, ... }:
[
  # Overlay updated mpv with bug fix.
  # TODO: Remove on mpv 0.40.0 release
  (final: prev: {
    mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs {
      src = prev.fetchFromGitHub {
        owner = "mpv-player";
        repo = "mpv";
        rev = "83bb49815cc163e4481097034e1058c4a04a9299";
        hash = "sha256-ZuGcTdVX0VBrXKylVGGPWSMlO2JJWpy+mh6D5LqWRxs=";
      };
      postPatch = final.lib.concatStringsSep "\n" [
        # Don't reference compile time dependencies or create a build outputs cycle
        # between out and dev
        ''
          substituteInPlace meson.build \
            --replace-fail "conf_data.set_quoted('CONFIGURATION', meson.build_options())" \
                           "conf_data.set_quoted('CONFIGURATION', '<omitted>')"
        ''
        # A trick to patchShebang everything except mpv_identify.sh
        ''
          pushd TOOLS
          mv mpv_identify.sh mpv_identify
          patchShebangs *.py *.sh
          mv mpv_identify mpv_identify.sh
          popd
        ''
      ];
    };
  })
]
