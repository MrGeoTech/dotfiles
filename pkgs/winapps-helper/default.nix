{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "winapps-helper";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/winapps-helper
    mkdir -p $out/bin

    # Copy compose file
    cp ${./compose.yaml} $out/share/winapps-helper/compose.yaml
    
    # Copy WinApps config
    cp ${./winapps.conf} $out/share/winapps-helper/winapps.conf

    # Create setup script
    cat > $out/bin/winapps-helper << 'EOF'
    #!/usr/bin/env bash
    set -e

    WINAPPS_DIR="$HOME/.config/winapps"
    COMPOSE_FILE="$WINAPPS_DIR/compose.yaml"

    echo "Setting up WinApps..."

    # Create directories
    mkdir -p "$WINAPPS_DIR"
    mkdir -p "$WINAPPS_DIR/apps"

    # Copy compose file
    if [ -f "$COMPOSE_FILE" ]; then
      echo "Compose file already exists at $COMPOSE_FILE"
      read -p "Overwrite? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping compose file..."
      else
        cp ${placeholder "out"}/share/winapps-helper/compose.yaml "$COMPOSE_FILE"
        echo "Compose file copied to $COMPOSE_FILE"
      fi
    else
      cp ${placeholder "out"}/share/winapps-helper/compose.yaml "$COMPOSE_FILE"
      echo "Compose file copied to $COMPOSE_FILE"
    fi

    # Copy WinApps config
    if [ -f "$WINAPPS_DIR/winapps.conf" ]; then
      echo "WinApps config already exists"
      read -p "Overwrite? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp ${placeholder "out"}/share/winapps-helper/winapps.conf "$WINAPPS_DIR/winapps.conf"
        echo "Config copied to $WINAPPS_DIR/winapps.conf"
      fi
    else
      cp ${placeholder "out"}/share/winapps-helper/winapps.conf "$WINAPPS_DIR/winapps.conf"
      echo "Config copied to $WINAPPS_DIR/winapps.conf"
    fi

    echo ""
    echo "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Edit $COMPOSE_FILE if needed (adjust RAM, CPU, disk size)"
    echo "2. Start the Windows VM: winapps-start"
    echo "3. Access Windows via web UI at http://localhost:8006"
    echo "4. Install your Windows applications (Fusion360, Office, etc.)"
    echo "5. Create app configs in $WINAPPS_DIR/apps/ for each application"
    echo ""
    echo "Tip: Use 'winapps-status' to check if the VM is running"
    EOF

    chmod +x $out/bin/winapps-helper

    # Create start script
    cat > $out/bin/winapps-start << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps"
    COMPOSE_FILE="$WINAPPS_DIR/compose.yaml"

    if [ ! -f "$COMPOSE_FILE" ]; then
      echo "WinApps not set up. Run 'winapps-helper' first."
      exit 1
    fi

    echo "Starting WinApps Windows VM..."
    cd "$WINAPPS_DIR"
    docker compose --file ~/.config/winapps/compose.yaml up

    echo ""
    echo "Windows VM is starting up..."
    echo "Access it at: http://localhost:8006"
    echo "RDP: localhost:3389 (user: docker, pass: docker)"
    EOF

    chmod +x $out/bin/winapps-start

    # Create stop script
    cat > $out/bin/winapps-stop << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps"

    echo "Stopping WinApps Windows VM..."
    cd "$WINAPPS_DIR"
    docker compose stop

    echo "VM stopped."
    EOF

    chmod +x $out/bin/winapps-stop

    # Create status script
    cat > $out/bin/winapps-status << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps"

    cd "$WINAPPS_DIR" 2>/dev/null || {
      echo "WinApps not set up. Run 'winapps-helper' first."
      exit 1
    }

    docker compose ps
    EOF

    chmod +x $out/bin/winapps-status

    # Create restart script
    cat > $out/bin/winapps-restart << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps"

    echo "Restarting WinApps Windows VM..."
    cd "$WINAPPS_DIR"
    docker compose restart

    echo "VM restarted."
    EOF

    chmod +x $out/bin/winapps-restart

    # Create cleanup script
    cat > $out/bin/winapps-cleanup << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps"

    echo "WARNING: This will remove the Windows VM and all installed applications!"
    read -p "Are you sure? (yes/NO): " -r
    echo

    if [[ ! $REPLY == "yes" ]]; then
      echo "Cancelled."
      exit 0
    fi

    echo "Cleaning up WinApps setup..."

    if [ -d "$WINAPPS_DIR" ]; then
      cd "$WINAPPS_DIR"
      docker compose down -v 2>/dev/null || true
      cd "$HOME"
      rm -rf "$WINAPPS_DIR"
      echo "Removed WinApps configuration and VM"
    else
      echo "WinApps directory not found"
    fi

    echo "Cleanup complete!"
    EOF

    chmod +x $out/bin/winapps-cleanup

    # Create app config helper
    cat > $out/bin/winapps-add-app << 'EOF'
    #!/usr/bin/env bash
    
    WINAPPS_DIR="$HOME/.config/winapps/apps"

    if [ $# -lt 2 ]; then
      echo "Usage: winapps-add-app <app-name> <exe-path>"
      echo ""
      echo "Example: winapps-add-app fusion360 'C:\\Program Files\\Autodesk\\Fusion 360\\Fusion360.exe'"
      echo ""
      echo "This will create a basic app config. Edit it in $WINAPPS_DIR/<app-name>.xml"
      exit 1
    fi

    APP_NAME="$1"
    EXE_PATH="$2"

    mkdir -p "$WINAPPS_DIR"

    cat > "$WINAPPS_DIR/$APP_NAME.xml" << APPEOF
    <application>
      <name>$APP_NAME</name>
      <full_name>$(echo $APP_NAME | sed 's/.*/\u&/')</full_name>
      <icon>$APP_NAME</icon>
      <exec>$EXE_PATH</exec>
    </application>
    APPEOF

    echo "Created app config at $WINAPPS_DIR/$APP_NAME.xml"
    echo "You may need to edit it to match your WinApps setup."
    echo ""
    echo "Don't forget to extract/provide an icon for the app!"
    EOF

    chmod +x $out/bin/winapps-add-app
  '';

  meta = with lib; {
    description = "WinApps setup helper for running Windows applications on Linux";
    longDescription = ''
      Sets up WinApps with a single Windows VM that can run multiple Windows applications.
      Includes helper scripts for managing the VM and adding application configurations.
    '';
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
