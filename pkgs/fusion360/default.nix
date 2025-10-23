{ pkgs ? import <nixpkgs> {} }:

let
  pname = "fusion360";
  version = "2.0.0";
  wine = pkgs.wineWowPackages.stable;
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  # Replace this with the actual path to your installer
  # It can also be a fetchurl if you're hosting it privately.
  src = pkgs.fetchurl {
    url = "file:///path/to/Fusion360installer.exe";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [ wine pkgs.cabextract pkgs.unzip ];
  buildInputs = [ wine ];

  # We don’t actually build anything, just prepare a wine prefix
  # and install Fusion 360 into it
  buildPhase = ''
    echo "Creating Wine prefix..."
    export WINEPREFIX=$PWD/wineprefix
    mkdir -p $WINEPREFIX

    echo "Running Fusion 360 installer..."
    ${wine}/bin/wine "$src" /S || true
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/opt/fusion360

    # Copy wineprefix
    cp -r wineprefix $out/opt/fusion360/wineprefix

    # Create launcher script
    cat > $out/bin/fusion360 <<EOF
    #!${pkgs.bash}/bin/bash
    export WINEPREFIX=$out/opt/fusion360/wineprefix
    exec ${wine}/bin/wine "\$WINEPREFIX/drive_c/Program Files/Autodesk/Webdeploy/production/*/Fusion360.exe" "\$@"
    EOF

    chmod +x $out/bin/fusion360
  '';

  # Don’t try to strip wine binaries
  dontStrip = true;

  # Avoid sandboxing issues
  dontPatchELF = true;

  meta = with pkgs.lib; {
    description = "Autodesk Fusion 360 (via Wine)";
    homepage = "https://www.autodesk.com/products/fusion-360";
    license = licenses.unfree;
    maintainers = [ maintainers.yourself ];
    platforms = platforms.linux;
  };
}
