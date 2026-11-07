# `voice-type`: hold SUPER + V, talk, let go. A local whisper.cpp model
# turns the take into text and dotool types it into whatever has focus
# through a uinput keyboard, so apps see plain key presses. Everything around
# the focused window is dimmed while it listens and thinks.
#
# dotool needs /dev/uinput. systemd's seat ACL already gives the logged-in
# user that, so there is no daemon or group to set up.
#
# Import with arguments from home/<hostname>.nix, like steam-full.nix:
#   (import ./common/optional/apps/voice-type.nix { model = "small.en"; gpu = "vulkan"; })
{
  # A whisper.cpp model name from `models` below (bigger = slower, better),
  # or a path / derivation of any ggml .bin file.
  model ? "base.en",
  # Spoken language: "en", "de", ..., or "auto". The .en models only do "en".
  language ? "en",
  # GPU backend for whisper.cpp: null (CPU), "vulkan", "rocm" or "cuda".
  # vulkan is in the binary cache; rocm and cuda build from source.
  gpu ? null,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  # sha256 of each model, from huggingface's LFS metadata:
  #   curl -s https://huggingface.co/api/models/ggerganov/whisper.cpp/tree/main
  models = {
    "tiny" = "be07e048e1e599ad46341c8d2a135645097a538221678b7acdd1b1919c6e1b21";
    "tiny-q5_1" = "818710568da3ca15689e31a743197b520007872ff9576237bda97bd1b469c3d7";
    "tiny-q8_0" = "c2085835d3f50733e2ff6e4b41ae8a2b8d8110461e18821b09a15c40c42d1cca";
    "tiny.en" = "921e4cf8686fdd993dcd081a5da5b6c365bfde1162e72b08d75ac75289920b1f";
    "tiny.en-q5_1" = "c77c5766f1cef09b6b7d47f21b546cbddd4157886b3b5d6d4f709e91e66c7c2b";
    "tiny.en-q8_0" = "5bc2b3860aa151a4c6e7bb095e1fcce7cf12c7b020ca08dcec0c6d018bb7dd94";
    "base" = "60ed5bc3dd14eea856493d334349b405782ddcaf0028d4b5df4088345fba2efe";
    "base-q5_1" = "422f1ae452ade6f30a004d7e5c6a43195e4433bc370bf23fac9cc591f01a8898";
    "base-q8_0" = "c577b9a86e7e048a0b7eada054f4dd79a56bbfa911fbdacf900ac5b567cbb7d9";
    "base.en" = "a03779c86df3323075f5e796cb2ce5029f00ec8869eee3fdfb897afe36c6d002";
    "base.en-q5_1" = "4baf70dd0d7c4247ba2b81fafd9c01005ac77c2f9ef064e00dcf195d0e2fdd2f";
    "base.en-q8_0" = "a4d4a0768075e13cfd7e19df3ae2dbc4a68d37d36a7dad45e8410c9a34f8c87e";
    "small" = "1be3a9b2063867b937e64e2ec7483364a79917e157fa98c5d94b5c1fffea987b";
    "small-q5_1" = "ae85e4a935d7a567bd102fe55afc16bb595bdb618e11b2fc7591bc08120411bb";
    "small-q8_0" = "49c8fb02b65e6049d5fa6c04f81f53b867b5ec9540406812c643f177317f779f";
    "small.en" = "c6138d6d58ecc8322097e0f987c32f1be8bb0a18532a3f88f734d1bbf9c41e5d";
    "small.en-q5_1" = "bfdff4894dcb76bbf647d56263ea2a96645423f1669176f4844a1bf8e478ad30";
    "small.en-q8_0" = "67a179f608ea6114bd3fdb9060e762b588a3fb3bd00c4387971be4d177958067";
    "medium" = "6c14d5adee5f86394037b4e4e8b59f1673b6cee10e3cf0b11bbdbee79c156208";
    "medium-q5_0" = "19fea4b380c3a618ec4723c3eef2eb785ffba0d0538cf43f8f235e7b3b34220f";
    "medium-q8_0" = "42a1ffcbe4167d224232443396968db4d02d4e8e87e213d3ee2e03095dea6502";
    "medium.en" = "cc37e93478338ec7700281a7ac30a10128929eb8f427dda2e865faa8f6da4356";
    "medium.en-q5_0" = "76733e26ad8fe1c7a5bf7531a9d41917b2adc0f20f2e4f5531688a8c6cd88eb0";
    "medium.en-q8_0" = "43fa2cd084de5a04399a896a9a7a786064e221365c01700cea4666005218f11c";
    "large-v2" = "9a423fe4d40c82774b6af34115b8b935f34152246eb19e80e376071d3f999487";
    "large-v2-q5_0" = "3a214837221e4530dbc1fe8d734f302af393eb30bd0ed046042ebf4baf70f6f2";
    "large-v2-q8_0" = "fef54e6d898246a65c8285bfa83bd1807e27fadf54d5d4e81754c47634737e8c";
    "large-v3" = "64d182b440b98d5203c4f9bd541544d84c605196c4f7b845dfa11fb23594d1e2";
    "large-v3-q5_0" = "d75795ecff3f83b5faa89d1900604ad8c780abd5739fae406de19f23ecd98ad1";
    "large-v3-turbo" = "1fc70f774d38eb169993ac391eea357ef47c88757ef72ee5943879b7e8e2bc69";
    "large-v3-turbo-q5_0" = "394221709cd5ad1f40c46e6031ca61bce88931e6e088c188294c6d5a55ffa7e2";
    "large-v3-turbo-q8_0" = "317eb69c11673c9de1e1f0d459b253999804ec71ac4c23c17ecf5fbe24e259a1";
  };

  modelFile =
    if builtins.isString model
    then
      pkgs.fetchurl {
        url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${model}.bin";
        sha256 = models.${model} or (throw "voice-type: unknown model \"${model}\", pick one of: ${lib.concatStringsSep ", " (lib.attrNames models)}");
      }
    else model;

  # Silero voice activity detection. Without it whisper hears a silent take
  # (a quick tap, a pause) as "Thank you." and types that.
  vadModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v6.2.0.bin";
    sha256 = "2aa269b785eeb53a82983a20501ddf7c1d9c48e33ab63a41391ac6c9f7fb6987";
  };

  whisper =
    if gpu == null
    then pkgs.whisper-cpp
    else pkgs.whisper-cpp.override {"${gpu}Support" = true;};

  voice-type = pkgs.writeShellApplication {
    name = "voice-type";
    runtimeInputs = [whisper pkgs.pipewire pkgs.dotool pkgs.glibc.bin pkgs.jq pkgs.coreutils pkgs.gnused];
    text = ''
      dir=''${XDG_RUNTIME_DIR:-/tmp}/voice-type
      wav=$dir/take.wav
      pidfile=$dir/recorder.pid
      mkdir -p "$dir"

      # dim_around on the window darkens everything else on screen.
      dim() {
        [ -n "$1" ] || return 0
        hyprctl dispatch "hl.dsp.window.set_prop({ prop = \"dim_around\", value = \"$2\", window = \"address:$1\" })" >/dev/null || true
      }

      super_down() {
        [ "$(hyprctl repl 'return tostring(hl.is_key_down("Super_L") or hl.is_key_down("Super_R"))' 2>/dev/null)" = true ]
      }

      case "''${1-}" in
      start)
        # One take at a time.
        if [ -e "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
          exit 0
        fi

        # Remember the window, not "active": focus can move before we're done.
        addr=$(hyprctl -j activewindow | jq -r '.address // empty')
        dim "$addr" 1
        trap 'dim "$addr" 0; rm -f "$pidfile" "$wav"' EXIT

        # whisper wants 16kHz mono.
        pw-record --rate 16000 --channels 1 --format s16 "$wav" &
        echo $! >"$pidfile"
        wait $! || true # `voice-type stop` ends it with SIGINT
        rm -f "$pidfile"

        # Drop whisper's non-speech tags like [BLANK_AUDIO] and (music),
        # then fold the lines into one.
        text=$(whisper-cli -m ${modelFile} -l ${lib.escapeShellArg language} -nt -np --vad -vm ${vadModel} -f "$wav" 2>/dev/null \
          | sed -E 's/\[[^]]*\]//g; s/\([^)]*\)//g' \
          | tr -s ' \n' ' ' \
          | sed -E 's/^ +//; s/ +$//') || true
        [ -n "$text" ] || exit 0

        # dotool is a real keyboard to Hyprland, so typing while SUPER is
        # still held would fire SUPER + letter binds.
        for _ in $(seq 100); do
          super_down || break
          sleep 0.05
        done

        # dotool can only press keys on the layout (us), so fold the rest to
        # ASCII: café -> cafe, curly quotes -> straight. iconv turns what it
        # can't fold into "?", so park the real ones first and drop those.
        text=$(printf '%s' "$text" \
          | tr '?' '\001' \
          | LC_ALL=C.UTF-8 iconv -f UTF-8 -t ASCII//TRANSLIT \
          | tr -d '?' \
          | tr '\001' '?') || true

        # wtype was tried first: its made-up keymap lands some letters on
        # Tab's keycode, and ghostty types a Tab for them.
        printf 'type %s\n' "$text" | dotool
        ;;
      stop)
        # A quick tap can land here before `start` has a recorder going.
        for _ in $(seq 20); do
          [ -e "$pidfile" ] && break
          sleep 0.05
        done
        if [ -e "$pidfile" ]; then
          kill -INT "$(cat "$pidfile")" 2>/dev/null || true
        fi
        ;;
      *)
        echo "usage: voice-type start|stop" >&2
        exit 1
        ;;
      esac
    '';
  };
in {
  home.packages = [voice-type];

  wayland.windowManager.hyprland.extraLuaFiles."35-voice-type" =
    lib.mkIf config.wayland.windowManager.hyprland.enable {
      autoLoad = true;
      content = ''
        -- GENERATED BY NIX (apps/voice-type.nix). Do not edit by hand.
        -- Hold SUPER + V to talk, let go to type it.

        -- Fires when V comes up. Off until SUPER + V turns it on, so plain
        -- typing never sees it. ignore_mods: still fires if SUPER is let go
        -- before V. It has to live in the same submap the press happened in,
        -- because Hyprland matches release binds against that submap.
        local stop
        stop = hl.bind("V", function()
          stop:set_enabled(false)
          hl.dispatch(hl.dsp.exec_cmd("${voice-type}/bin/voice-type stop"))
        end, { release = true, ignore_mods = true })
        stop:set_enabled(false)

        hl.bind("SUPER + V", function()
          stop:set_enabled(true)
          hl.dispatch(hl.dsp.exec_cmd("${voice-type}/bin/voice-type start"))
        end, { description = "hold to dictate" })
      '';
    };
}
