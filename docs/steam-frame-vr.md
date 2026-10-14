# Steam Frame + SteamVR on NixOS (mrgeotech-pc)

Debug log. When VR works, go back through this, find what actually fixed it,
and turn the end of this file into a short guide.

## Setup

- host: `mrgeotech-pc`, NixOS, Hyprland (Wayland)
- headset: Steam Frame (`frame_D1ECDB03`) over the USB wireless dongle
- dongle NIC: `wlp6s0f3u4`, PC side `10.35.78.21/24`, headset `10.35.78.1`
- other NICs SteamVR also binds: `enp5s0` (LAN), `wg0` (wireguard)
- SteamVR 2.17.10, build id 25330290
- Steam client version 1788652215
- related nix: `hosts/common/optional/steam.nix`

## Symptom

Launch SteamVR, get "Headset Not Detected (108)".

`vrmonitor.txt`:

```
VR_Init failed with Hmd Not Found (108)
[Status Alert] Headset Not Detected (108)
```

108 only means "no driver found a headset". It is the result, not the cause.

## Log files that matter

All in `~/.local/share/Steam/logs/`.

| file | what it tells |
| --- | --- |
| `remote_connections.txt` | dongle found? Frame connected? |
| `driver_vrlink.txt` | the SteamVR driver that talks to the Frame |
| `vrserver.txt` | which drivers loaded, why HMD not found |
| `vrmonitor.txt` | the 108 popup |
| `streaming_log.txt` | Remote Play stream: VR or flat desktop? |
| `console_log.txt` | Steam client itself, incl. SteamVR init |

Tip: `driver_vrlink.txt` is full of `Null VTE_CLIENT_SESSION_ID` spam. Filter it:

```
grep -v VTE_CLIENT ~/.local/share/Steam/logs/driver_vrlink.txt
```

## What is known good

1. Dongle detected by Steam.
   `remote_connections.txt`: `Dongle found: wlp6s0f3u4 ... MAC 50:37:CD:86:74:AA`
2. Frame connects to Steam over the dongle.
   `Connecting to remote: 0x39 10.35.78.1:27036` then
   `Client ... (frame) connected via direct connection`
3. Firewall is open for vrlink. Checked with:
   ```
   nix eval --json .#nixosConfigurations.mrgeotech-pc.config.networking.firewall \
     --apply 'f: { inherit (f) allowedUDPPorts allowedUDPPortRanges allowedTCPPorts; }'
   ```
   UDP 10400/10401 (vrlink) and 27031-27036 already allowed (from `programs.steam`).
4. vrlink binds UDP 10400 on the dongle NIC fine:
   `SVLDataLinkTransferUDP SO_BINDTODEVICE 10.35.78.21 dev wlp6s0f3u4 OK`
5. Wifi regdom already pinned to US in `steam.nix` (earlier dongle fix).

## Findings

### F1. vrlink starts with no session

Every SteamVR start, `driver_vrlink.txt`:

```
SVLRoot::SVLRoot() Parsing Arg (0)
No links? Server-as-client Mode?
ERROR: Null VTE_CLIENT_SESSION_ID!   (thousands of times)
```

and `vrserver.txt`:

```
Driver vrlink has no suitable devices.
No connected devices found. Returning best error VRInitError_Init_HmdNotFound
```

vrlink gets no session id from the Steam client. So it doesn't know about the
Frame, even though Steam itself is connected to it. No log has ever shown a
non-null session.

### F2. Starting a VR game from the headset gives a flat stream

Launched Primitive (777890, native Linux VR) from the Frame.

First try: `streaming_log.txt` says
`Steam needs to be restarted with -pipewire ...` (k_ECaptureFailedReasonPipewireRequired).

With `steam -pipewire`: stream starts but the headset hangs. Log shows:

```
Device form factor: computer
Maximum capture: 1920x1080
setting activity to k_EStreamActivityDesktop
```

So Steam treated the Frame as a normal flat Remote Play client and captured
the desktop. SteamVR was never started for that stream. The `-pipewire` error
was only the flat desktop capture path. It was not the VR path.

### F3. Steam client says SteamVR "isn't installed"

`console_log.txt`, on every Steam start since at least 2026-09-27:

```
Failed to init SteamVR because it isn't installed
```

But it is installed:

- `steamapps/appmanifest_250820.acf` has `StateFlags 4` (fully installed)
- `~/.config/openvr/openvrpaths.vrpath` runtime points to
  `~/.local/share/Steam/steamapps/common/SteamVR`

The line prints right after `steam-runtime-launcher-service` starts. That is
very early, so it might just be a harmless race at startup, before the library
has loaded. Not confirmed either way.

Still there after verifying files and after switching SteamVR to `beta`
(22:32, 22:33).

Update (10-02): probably harmless. strace shows the startup check reads
`openvrpaths.vrpath` but never looks at the SteamVR folder. That is too early,
before the library has loaded. Later, when SteamVR is launched, the same thread
reads the file again. That time it finds `common/SteamVR/bin/version.txt` and
launches it fine. Demoted to noise.

### F4. GPU hardware encode works

RX 6800/6900 (navi21), Mesa 26.2.3. vrlink has to encode video for the Frame.
Checked outside Steam:

```
nix shell nixpkgs#vulkan-tools nixpkgs#libva-utils -c sh -c 'vulkaninfo; vainfo'
```

- Vulkan: `VK_KHR_video_encode_queue`, `_h264`, `_h265` present
- VAAPI (radeonsi): H264 + HEVC `VAEntrypointEncSlice` present

So `k_EVRLinkCapsMissingHardwareEncoding` should not apply. Not checked
inside the Steam runtime container though.

### F5. Strings inside the Steam client

`strings ~/.local/share/Steam/linux64/steamclient.so` shows:

- `Failed to init SteamVR because it isn't installed`, near
  `openvr/openvrpaths.vrpath` and `vrpathreg.sh`. The check probably reads
  the openvr paths file.
- `EVRLinkCaps`: `Available`, `Unimplemented`, `MissingHardwareEncoding`.
  The client decides whether this PC can do VR link at all.
- `-vrlinkforceenable`: a hidden launch flag.
- `steamui.so`: `CGameStreamManager::OnVRVRLinkActiveChanged`.

### F6. Steam's environment looks sane

Read `/proc/<steam pid>/environ` and `/proc/<pid>/root` of the running client:

- `HOME`, `XDG_CONFIG_HOME` are normal
- `openvrpaths.vrpath` can be read from inside the FHS root
- library 1 `~/.local/share/Steam` has SteamVR (250820)
- library 2 `/data/SteamLibrary` has Primitive (777890)

Odd: `~/.config/openvr/openvrpaths.vrpath` last changed 2025-04-13. SteamVR
normally rewrites it through vrpathreg. Content still looks right.

The client logs nothing about why VR link is off. There is no VRLink or caps
line anywhere in the webhelper, cef, remote_connections or streaming logs.

Note: in the user's zsh, `grep` is aliased to batgrep. Use `command grep` for
`-v` and the like.

### F7. vrwebhelper crashes on start, missing libs (STRONG LEAD)

User saw: SteamVR settings won't open. Base station settings say bluetooth is
disabled. Steam's bluetooth page says "Bluetooth not available", but
`bluetoothctl show` on the host is fine (powered on).

All `vrwebhelper*.txt` logs stop on 2025-04-13. That is the same day
`openvrpaths.vrpath` last changed. vrserver says it starts it every time:

```
Started VRWebhelper '.../SteamVR/bin/vrwebhelper/linux64/vrwebhelper.sh' with pid 44289
```

strace of Steam startup (`strace -f -e trace=%file`) shows that pid ends:

```
openat(... "libatk-bridge-2.0.so.0" ...) = -1 ENOENT   (every path)
+++ exited with 127 +++
```

127 means the dynamic loader failed. The full list comes from `ldd` inside
the Steam FHS env:

```
D=~/.local/share/Steam/steamapps/common/SteamVR/bin/vrwebhelper/linux64
steam-run sh -c "cd $D && LD_LIBRARY_PATH=$D:\$LD_LIBRARY_PATH ldd ./vrwebhelper ./libcef.so" | grep "not found"
```

```
libatk-1.0.so.0  libatk-bridge-2.0.so.0  libatspi.so.0
libnspr4.so  libnss3.so  libnssutil3.so  libsmime3.so
libSDL2-2.0.so.0  libXcomposite.so.1
```

vrwebhelper is SteamVR's CEF UI (settings, dashboard, pairing, system UI).
It probably also handles the Steam/vrlink session handoff. Not proven yet.

Candidate fix in `hosts/common/optional/steam.nix`:

```nix
programs.steam.extraPackages = with pkgs; [
  at-spi2-core # libatk-1.0, libatk-bridge-2.0, libatspi
  nss # libnss3, libnssutil3, libsmime3
  nspr
  SDL2
  libxcomposite
];
```

Checked before switching: built the system, and `ldd` with the new
`programs.steam.package.run` reports 0 missing libs.

Result after switch (10-02 02:50): SteamVR settings window opens. New
`vrwebhelper_main/settings_desktop/pairing.txt` logs exist. vrwebhelper is
FIXED. 108 still happens when SteamVR starts from the desktop, and vrlink
still has no session. So F7 was a real bug, but not the only one.

Side issue: turning on the "gamepad" add-on in SteamVR settings crashes.
vrserver only logs `Not loading driver gamepad because it is disabled in
settings`. No crash trace found yet.

Other exit-127s in the strace are harmless: shell lookups for `pactl` and
`kde-config`, which aren't installed.

`drivers/frame_hmd`, `frame_controller`, `deckard` are resource-only
(icons/input profiles). That is normal. vrlink is the real driver.

### F8. IT CONNECTS (10-02 03:08)

After the F7 fix, the user got the Frame connected by starting the stream
from the headset. That was the same thing tried in attempts 2/3, which failed
before the fix. `driver_vrlink.txt`:

```
SVLRoot::SVLRoot() Parsing Arg (0)          <- still 0, so args were never the problem
No links? Server-as-client Mode?            <- also normal
SVLDataLinkUber: Found primary link 10.35.78.21
VTE_STRING_VERSION_NUMBER = deckardclient;deckard;0.0.1
Connection active at 1.873767
[VideoVulkan] Created vkCreateVideoSessionParametersKHR!
```

and zero `Null VTE_CLIENT_SESSION_ID` lines. That spam was a symptom: vrlink
waiting for a headset that never showed up. It was not the cause. The F1
"no args" theory was wrong.

Seen during the session, maybe perf-related, not checked yet:
`[HMDVulkan] AcquireSync: Couldn't find a backbuffer to use! Waiting...`

### F9. SteamVR Tutorial broken on Linux (Valve bug, not ours)

Tutorial says "unknown error". Steam: `LaunchApp failed with AppError_1`.
`logs/vrtutorial-linux.txt`:

```
Invalid serialized file version. File: ".../steamvr_tutorial_Data/globalgamemanagers". Expected version: 5.6.0b
Failed to initialize player
```

`tools/steamvr_tutorial/linux64/` has two binaries:

- `steamvr_tutorial`, built with Unity 5.6. `steamvr_tutorial.sh` execs this one.
- `steamvr_tutorial.x86_64`, built with Unity 2017.3. Matches the data, which
  is `2017.3.1f1` in the `globalgamemanagers` header.

Valve's script runs the wrong binary. Verify files won't fix it. The tutorial
isn't needed for VR to work.

Confirmed with `strings`: `steamvr_tutorial` has `5.6.0b7`, `.x86_64` has
`2017.3.1f1`. Workaround (10-02 03:29), outside nix, in the Steam library:

```
cd ~/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_tutorial/linux64
mv steamvr_tutorial steamvr_tutorial.unity56.bak
ln -s steamvr_tutorial.x86_64 steamvr_tutorial
```

ldd in steam-run: only `ScreenSelector.so` lacks `libgtk-x11-2.0`. The script
runs under the scout runtime, which ships it. A SteamVR update or verify will
probably undo the symlink, so re-run it if that happens.

### F10. Add-on toggle "crash" = restarthelper missing Qt5

Turning on an add-on (e.g. gamepad) makes SteamVR restart itself through
`SteamVR/bin/linux64/restarthelper`. strace: `restarthelper` exits 127.
`ldd` inside steam-run:

```
libQt5Core.so.5 => not found
libQt5Gui.so.5 => not found
libQt5Widgets.so.5 => not found
```

Fix: add `libsForQt5.qtbase` to `programs.steam.extraPackages`. It builds, and
ldd shows 0 missing for restarthelper, vrwebhelper and libcef.so. Not tested
live yet. Qt may still need a platform plugin (xcb/wayland) at runtime.

Also in the same strace: `vrserver` and `vrcompositor` SIGSEGV at 03:16:00,
after Steam had already quit at 03:15:56. Crash on quit, not during play.
Low priority.

Current best guess: the Steam client's VR side never comes up. Then Frame
streams go flat (F2) and SteamVR gets no session (F1).

## Ruled out

- Hyprland DRM lease bug (hyprwm/Hyprland#7776). That issue is
  `VRInitError_Compositor_CannotDRMLeaseDisplay` for wired headsets (Index)
  that need direct mode. The Frame streams over the network and doesn't lease a
  display. Our logs never reach the compositor. They fail earlier with
  HmdNotFound. Keep in mind in case a wired headset is used later.
- Firewall (see known good 3).
- Dongle / regdom (see known good 1, 5).

## Noise (seen, not the cause)

- `Failed to set thread priority: setschedparam failed` — no CAP_SYS_NICE on
  vrcompositor. Can hurt performance later, not detection.
- `No holo-realtek-firmware-toggles helper script found, low latency mode unavailable`
  — SteamOS-only helper for the dongle. Only affects low latency mode.
- `Unable to load driver oculus ... FileNotFound(103)` — normal.
- `udev disabled by SDL_JOYSTICK_DISABLE_UDEV` — Steam runtime default.

## Attempts

| # | what | result |
| --- | --- | --- |
| 1 | launch SteamVR from desktop | 108, vrlink no session (F1) |
| 2 | launch Primitive from headset, plain `steam` | pipewire capture error, flat stream (F2) |
| 3 | same, `steam -pipewire` | flat desktop stream, headset hangs (F2) |
| 4 | `steam -pipewire`, launch SteamVR | 108 again, "isn't installed" still in console_log (F3) |
| 5 | verify SteamVR files (done before 4) | no change |
| 6 | SteamVR beta branch | no change, "isn't installed" still there |
| 7 | `steam -pipewire -vrlinkforceenable`, Primitive from headset | still `form factor: computer`, `k_EStreamActivityDesktop`. "isn't installed" still there |
| 8 | strace Steam startup + launch SteamVR | openvrpaths read OK. vrwebhelper exits 127 on missing libs (F7) |
| 9 | add libs via `programs.steam.extraPackages`, switch | settings window opens. Still 108 from desktop |
| 10 | start stream from headset (after F7 fix) | Frame connects, vrlink streams video (F8) |
| 11 | SteamVR Tutorial | fails, Valve packaging bug (F9) |
| 12 | add `libsForQt5.qtbase` for restarthelper | builds, ldd clean, not tested live (F10) |
| 13 | symlink tutorial binary to `.x86_64` | pending live test (F9) |

## Next things to try

- [x] SteamVR → Properties → Installed Files → Verify integrity (no change)
- [x] SteamVR → Properties → Betas → `beta` (no change)
- [x] `steam -pipewire -vrlinkforceenable` (F5), then launch from headset (no change)
- [x] strace Steam startup (found F7)
- [x] switch with F7 fix, restart Steam, check SteamVR settings opens (yes)
- [ ] pairing: the pairing helper was dead since 2025-04, so the Frame may never have paired with SteamVR. Look for pairing in SteamVR menu / headset
- [ ] then try headset again (SteamVR + Primitive)
- [ ] check if Steam's "Bluetooth not available" goes away too
- [ ] Steam client beta (Settings → Interface → Client Beta Participation)
- [ ] after each: does `Failed to init SteamVR because it isn't installed` still show?
      ```
      grep -iE "Failed to init SteamVR" ~/.local/share/Steam/logs/console_log.txt | tail -3
      ```
- [ ] in headset, look for a VR vs desktop launch choice for Primitive
- [ ] look into how NixOS `programs.steam` (FHS env) might hide SteamVR from the client check

## Fix

The cause was SteamVR's own helper programs crashing at start because NixOS's
Steam FHS env lacked their libs. The main one was `vrwebhelper` (F7). Fix is in
`hosts/common/optional/steam.nix`:

```nix
{ pkgs, ... }: {
  programs.steam.extraPackages = with pkgs; [
    at-spi2-core # libatk-1.0, libatk-bridge-2.0, libatspi
    nss # libnss3, libnssutil3, libsmime3
    nspr
    SDL2
    libxcomposite
    libsForQt5.qtbase # restarthelper (F10)
  ];
}
```

Red herrings, for the record: "isn't installed" (F3), null session spam (F1),
`-pipewire`/flat stream (F2), firewall, Hyprland DRM lease.

## Guide

Steam Frame + SteamVR on NixOS, short version.

1. Add the `programs.steam.extraPackages` list from "Fix" above, then switch.
2. If the Frame's wireless dongle (rtw89) won't come up, pin the wifi regdom.
   This is already in `steam.nix`:
   ```nix
   hardware.wirelessRegulatoryDatabase = true;
   boot.extraModprobeConfig = ''options cfg80211 ieee80211_regdom="US"'';
   ```
3. Quit Steam fully and start it again.
4. Check: SteamVR → Settings opens. If not, vrwebhelper is still missing libs.
   Run the `ldd` check from F7 and add whatever is missing.
5. Put on the Frame and start the stream from the headset. Don't start SteamVR
   from the desktop first. On its own, the desktop launch just gives 108.
6. SteamVR Tutorial: Valve's script runs the wrong Unity binary. Symlink it
   to `steamvr_tutorial.x86_64` (F9).

If it breaks again after a SteamVR update, re-run the `ldd` check in steam-run
on `SteamVR/bin/vrwebhelper/linux64/{vrwebhelper,libcef.so}` and
`SteamVR/bin/linux64/restarthelper`.
