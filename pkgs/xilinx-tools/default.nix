{ pkgs ? import <nixpkgs> {} }:

let
  # Clone the xilinx-tools-docker repository
  xilinxToolsDocker = pkgs.fetchFromGitHub {
    owner = "esnet";
    repo = "xilinx-tools-docker";
    rev = "main";
    sha256 = "sha256-UUHoLGox4TpBidMT8wOcNJ1vkTeU43XTYsc1xgncvv0=";
  };

  # Path to user's Vivado installer
  vivadoInstallerDir = "${builtins.getEnv "HOME"}/.vivado-installer";
  installerTarName = "FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145.tar";

in
pkgs.stdenv.mkDerivation {
  pname = "vivado";
  version = "2025.1";
  
  src = xilinxToolsDocker;
  
  buildInputs = with pkgs; [ docker ];
  
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  
  unpackPhase = ''
    cp -r ${xilinxToolsDocker}/* .
    chmod -R u+w .
    
    # Create vivado-installer directory and copy the installer
    mkdir -p vivado-installer
    
    # Check if installer exists and copy it
    if [ -f "${vivadoInstallerDir}/${installerTarName}" ]; then
      cp "${vivadoInstallerDir}/${installerTarName}" vivado-installer/
    else
      echo "ERROR: Vivado installer not found at ${vivadoInstallerDir}/${installerTarName}"
      echo "Please download the installer from Xilinx and place it at:"
      echo "  ${vivadoInstallerDir}/${installerTarName}"
      exit 1
    fi
  '';
  
  buildPhase = ''
    # Build the Docker image
    ${pkgs.docker}/bin/docker build --pull -t xilinx-tools-docker:v2025.1-latest .
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    
    # Create vivado wrapper script
    cat > $out/bin/vivado <<'EOF'
    #!${pkgs.bash}/bin/bash
    ${pkgs.docker}/bin/docker run -it --rm \
      -v "$PWD:/workspace" \
      -v "$HOME/.Xilinx:/root/.Xilinx" \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --workdir /workspace \
      xilinx-tools-docker:v2025.1-latest vivado "$@"
    EOF
    chmod +x $out/bin/vivado
    
    # Create vivado_hls wrapper
    cat > $out/bin/vivado_hls <<'EOF'
    #!${pkgs.bash}/bin/bash
    ${pkgs.docker}/bin/docker run -it --rm \
      -v "$PWD:/workspace" \
      -v "$HOME/.Xilinx:/root/.Xilinx" \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --workdir /workspace \
      xilinx-tools-docker:v2025.1-latest vivado_hls "$@"
    EOF
    chmod +x $out/bin/vivado_hls
    
    # Create vitis wrapper
    cat > $out/bin/vitis <<'EOF'
    #!${pkgs.bash}/bin/bash
    ${pkgs.docker}/bin/docker run -it --rm \
      -v "$PWD:/workspace" \
      -v "$HOME/.Xilinx:/root/.Xilinx" \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --workdir /workspace \
      xilinx-tools-docker:v2025.1-latest vitis "$@"
    EOF
    chmod +x $out/bin/vitis
    
    # Create a generic xilinx-docker wrapper for any command
    cat > $out/bin/xilinx-docker <<'EOF'
    #!${pkgs.bash}/bin/bash
    ${pkgs.docker}/bin/docker run -it --rm \
      -v "$PWD:/workspace" \
      -v "$HOME/.Xilinx:/root/.Xilinx" \
      -e DISPLAY=$DISPLAY \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --workdir /workspace \
      xilinx-tools-docker:v2025.1-latest "$@"
    EOF
    chmod +x $out/bin/xilinx-docker
    
    # Create rebuild script
    cat > $out/bin/rebuild-vivado-docker <<'EOF'
    #!${pkgs.bash}/bin/bash
    echo "Rebuilding Vivado Docker image..."
    cd ${xilinxToolsDocker}
    if [ -f "${vivadoInstallerDir}/${installerTarName}" ]; then
      cp "${vivadoInstallerDir}/${installerTarName}" vivado-installer/
      ${pkgs.docker}/bin/docker build --pull -t xilinx-tools-docker:v2025.1-latest .
      echo "Docker image rebuilt successfully"
    else
      echo "ERROR: Vivado installer not found at ${vivadoInstallerDir}/${installerTarName}"
      exit 1
    fi
    EOF
    chmod +x $out/bin/rebuild-vivado-docker
  '';
  
  meta = with pkgs.lib; {
    description = "Xilinx Vivado Design Suite 2025.1 (Docker-based)";
    homepage = "https://github.com/esnet/xilinx-tools-docker";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [];
  };
}
