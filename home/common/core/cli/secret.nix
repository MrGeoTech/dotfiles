{pkgs, ...}: {
  home.packages = [
    # Thin wrapper around `sops` for arbitrary files under secrets/ (see
    # .sops.yaml's catch-all binary rule). `sops` itself already does the
    # decrypt-to-tempfile/$EDITOR/re-encrypt dance -- this just saves typing
    # and creates the file (and its parent dir) on first use.
    (pkgs.writeShellApplication {
      name = "secret";
      runtimeInputs = [pkgs.sops];
      text = ''
        usage() {
          echo "Usage: secret edit <path>   create or open an encrypted file in \$EDITOR" >&2
          echo "       secret cat <path>    decrypt to stdout" >&2
          echo "" >&2
          echo "<path> must be under a secrets/ directory (see .sops.yaml)." >&2
          exit 1
        }

        [ "$#" -eq 2 ] || usage
        cmd=$1
        path=$2

        case "$path" in
          */secrets/* | secrets/*) ;;
          *)
            echo "secret: $path is not under a secrets/ directory" >&2
            exit 1
            ;;
        esac

        rest=''${path##*secrets/}
        case "$rest" in
          */*)
            echo "secret: $path is nested more than one level under secrets/, which .sops.yaml doesn't match" >&2
            exit 1
            ;;
          "")
            echo "secret: $path has no filename after secrets/" >&2
            exit 1
            ;;
        esac

        case "$cmd" in
          edit)
            mkdir -p "$(dirname "$path")"
            [ -e "$path" ] || : > "$path"
            exec sops "$path"
            ;;
          cat)
            exec sops --decrypt "$path"
            ;;
          *)
            usage
            ;;
        esac
      '';
    })
  ];
}
