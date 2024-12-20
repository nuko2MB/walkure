# Patched menomonia font for Guild Wars 2.
{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchurl,
  writers,
}:
let
  src = fetchurl {
    url = "https://d1h9a8s8eodvjz.cloudfront.net/fonts/menomonia/08-02-12/font/menomonia.ttf";
    hash = "sha256-0UpkhjhVqxV7zgkAQw8+x1/qqRqHY/YYhY5DdY/hiJU=";
  };

  # Fix the invalid name attributes on the font.
  # Using a python script because a fontforge legacy script would not set the names properly...
  menomonia-font-patcher =
    writers.writePython3Bin "menomonia-font-patcher"
      { libraries = with python3Packages; [ fontforge ]; }
      ''
        import sys
        import fontforge

        name = "Menomonia"
        fnt = fontforge.open(sys.argv[1])

        # appendSFNTName needs to be set FIRST.
        # Before setting postscript attributes.
        # Or it won't apply properly (?????)

        fnt.appendSFNTName("English (US)", "Family", name)
        fnt.appendSFNTName("English (US)", "SubFamily", "Regular")

        # Fullname *should* be inherited from the PostScript attribute
        # fnt.appendSFNTName("English (US)", "Fullname", name)

        # Postscript attributes
        fnt.fontname = name
        fnt.familyname = name
        fnt.fullname = name

        fnt.generate("menomonia.ttf")
      '';

in
stdenvNoCC.mkDerivation {
  inherit src;
  name = "menomonia";
  version = "1.0.0";

  dontUnpack = true;

  nativeBuildInputs = [ menomonia-font-patcher ];

  buildPhase = ''${lib.getExe menomonia-font-patcher} $src'';

  installPhase = ''install -Dm644 menomonia.ttf -t $out/share/fonts/truetype'';

  meta = {
    liscense = lib.licenses.unfree;
  };
}
