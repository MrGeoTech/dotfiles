{ pkgs, lib, stdenv, makeWrapper, wineWowPackages, winetricks }:

let
  pname = "fusion360";
  version = "1.0";
  
  # Wine prefix directory
  winePrefix = "\${HOME}/.wine-fusion360";
  
in stdenv.mkDerivation {
  inherit pname version;
  
  # No source needed, we'll reference the installer directly
  dontUnpack = true;
  
  nativeBuildInputs = [ makeWrapper ];
  
  buildInputs = [
    wineWowPackages.stable
    winetricks
  ];
  
  dontBuild = true;
  
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    
    # Create the launcher script
    cat > $out/bin/fusion360 << 'EOF'
    #!/bin/sh
    export WINEPREFIX="${winePrefix}"
    export WINEARCH=win64
    
    INSTALLER_PATH="/etc/nixos/pkgs/fusion360/Fusion Client Downloader.exe"
    
    # Initialize wine prefix if it doesn't exist
    if [ ! -d "$WINEPREFIX" ]; then
      echo "Initializing Wine prefix for Fusion 360..."
      ${wineWowPackages.stable}/bin/wineboot -u
      echo "Wine prefix initialized."
    fi
    
    # Check if Fusion 360 is installed
    FUSION_EXE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Autodesk/webdeploy/production/Fusion360.exe"
    
    if [ ! -f "$FUSION_EXE" ]; then
      echo "Fusion 360 not installed. Running installer..."
      
      if [ ! -f "$INSTALLER_PATH" ]; then
        echo "Error: Installer not found at $INSTALLER_PATH"
        echo "Please place 'Fusion Client Downloader.exe' at that location."
        exit 1
      fi
      
      ${wineWowPackages.stable}/bin/wine "$INSTALLER_PATH"
      
      # Wait a moment for installation to complete
      echo "Waiting for installation to complete..."
      echo "Once installation is done, run 'fusion360' again to launch."
      exit 0
    fi
    
    # Launch Fusion 360
    ${wineWowPackages.stable}/bin/wine "$FUSION_EXE" "$@"
    EOF
    
    chmod +x $out/bin/fusion360
    
    # Create desktop entry for Rofi/application launchers
    cat > $out/share/applications/fusion360.desktop << EOF
    [Desktop Entry]
    Name=Fusion 360
    Comment=Autodesk Fusion 360 CAD Software
    Exec=$out/bin/fusion360
    Terminal=false
    Type=Application
    Icon=fusion360
    Categories=Graphics;Engineering;3DGraphics;
    StartupNotify=true
    EOF
  '';
  
  meta = with lib; {
    description = "Autodesk Fusion 360 running under Wine";
    homepage = "https://www.autodesk.com/products/fusion-360";
    platforms = platforms.linux;
    mainProgram = "fusion360";
  };
}
