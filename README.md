<!-- markdownlint-disable -->
<h1 align="center">
    <a>
        MrGeoTech's NixOS Config
    </a>
</h1>
<div align="center">
    <sup>
        <a href="https://nixos.org"><img src="https://avatars.githubusercontent.com/u/487568?s=200&v=4"></a>
    </sup>
        <br/>
        <sub>
            <a href="https://nixos.org/manual/nix/stable/language/index.html" target="_blank">
            <img alt="Built With Nix" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&labelColor=5e81ac&message=Nix&color=d8dee9&style=for-the-badge">
            </a>
            <a href="https://nixos.wiki/wiki/Flakes" target="_blank">
            <img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
            </a>
            <a href="https://github.com/nix-community/home-manager" target="_blank">
            <img alt="Uses" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Uses&labelColor=5e81ac&message=Home Manager&color=d8dee9&style=for-the-badge">
            </a>
        </sub>
    </div>
</div>

<div align="center">
    Dotfiles for my <a href="https://hyprland.org">Hyprland</a> setup on my <a href="https://nixos.org">NixOS</a> system.
    <br/>
    <p><strong>Be sure to <a href="#" title="star">⭐️</a> or <a href="#" title="fork">🔱</a> this repo if you find it useful! 😃</strong></p>
</div>
<!-- markdownlint-restore -->

## Setup

- OS: [NixOS](https://nixos.org)
- Window manager: [Hyprland](https://hyprland.org)
- Status bar: [Waybar](https://github.com/Alexays/Waybar)
- Terminal: [Kitty](https://sw.kovidgoyal.net/kitty/)
- Shell: [Zsh](https://www.zsh.org/)
- Current theme: [Catppuccin](https://catppuccin.com/)
- Font: [Iosevka/IosevkaTerm](https://typeof.net/Iosevka/)
- Editor: [Neovim](https://neovim.io)
- File Sync: [Rsync](https://rsync.samba.org/)

## Gallery

|             Desktop              |
| :------------------------------: |
| ![desktop](./assets/desktop.png) |

|              Terminal + Tmux              |
| :---------------------------------------: |
| ![terminals_tmux](./assets/terminals.png) |

|             Neovim             |
| :----------------------------: |
| ![neovim](./assets/neovim.png) |

## Organization of the modules

![directory-structure](./assets/directory_structure.png)

## Sandboxed, on-demand apps

The base system -- browser (Vivaldi), file manager (Yazi), desktop
(Hyprland), terminal (Ghostty), editor (Neovim) -- is configured and
installed the normal home-manager way, same as always.

Everything else that's more of an occasional tool than a daily driver
(compilers, IDEs, CAD/office/media apps, ...) is wrapped instead: see
`home/common/lib/sandbox-apps.nix` and its use in
`home/common/optional/apps/default.nix`. Each wrapped command is a small
script that runs `nix shell nixpkgs#<pkg> --command <bin> "$@"`, so the
actual package is only fetched/built the first time you run it, and isn't
part of every home-manager generation.

Any command that isn't installed at all gets searched automatically: the
shell's `command_not_found_handle`/`command_not_found_handler` (see
`home/common/core/shells/{bash,zsh}.nix`) forwards it to
[`comma`](https://github.com/nix-community/comma), backed by a prebuilt
[nix-index-database](https://github.com/nix-community/nix-index-database)
so no local index needs to be built. It only runs interactively (a real
terminal, `COMMA_ASK_TO_CONFIRM=true` set in `home/common/core/default.nix`
makes it confirm before running anything), and the mistyped/unknown
command is only ever passed through as an argument, never interpolated
into a shell string.

## Installation

#### Requirements

- NixOS (I use 24.11)
- Disk space
- Patience
- Knowledge
- Stubborness

#### Installation 
```sh
# -- If you are me --
mkdir ~/Desktop
mkdir ~/Documents
mkdir ~/Downloads
mkdir ~/Pictures
mkdir ~/Projects
mkdir ~/School
mkdir ~/Videos
# -------------------
cd /etc/nixos/
sudo nixos-rebuild switch --flake '.#<host>'
```
> You will also have to copy over ~/.secrets. The SSH identity is no longer
> a manual copy -- it's decrypted from `hosts/common/users/mrgeotech/secrets/ssh.yaml`
> via sops-nix on rebuild; see "SSH key setup & migration" below.

## SSH key setup & migration

SSH auth (servers and GitHub alike) uses one Ed25519 identity, sops-encrypted
in `hosts/common/users/mrgeotech/secrets/ssh.yaml` and decrypted to
`~/.ssh/id_ed25519` on rebuild -- see `home/common/core/cli/ssh.nix` for the
client config (it also enables post-quantum-hybrid key exchange) and
`hosts/common/users/mrgeotech/default.nix` for the sops wiring. A systemd
service derives `~/.ssh/id_ed25519.pub` from that private key automatically
on every rebuild, so it can never go stale.

The same key signs commits (`home/common/core/cli/git.nix`, `gpg.format =
ssh`), so GitHub shows commits as "Verified" -- but that requires
registering the public key with GitHub **twice**, under two separate
sections of Settings > SSH and GPG keys:

- **Authentication Key** -- lets you push/pull over SSH.
- **Signing Key** -- lets GitHub verify commit signatures.

The same `~/.ssh/id_ed25519.pub` content goes in both; adding it as one
does not automatically add it as the other.

Decrypting *any* secret in this repo (the SSH key included) requires the
age private key at `~/.config/sops/age/keys.txt` matching the recipient in
`.sops.yaml`. That file is deliberately **not** in the repo -- it's the one
thing every machine needs copied to it out of band.

### Brand new setup (no existing age key anywhere)

Only needed once, ever -- e.g. bootstrapping this whole scheme for the
first time, or after the age key is confirmed lost with no backup (see
"Recovering from a lost age key" below).

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Take the public key it prints (`age1...`) and put it in `.sops.yaml`'s
`keys:` list, then generate and install the SSH key per
`hosts/common/users/mrgeotech/secrets/README.md`.

### Adding another machine (reuse the existing identity)

This is the normal case -- same SSH key and same secrets everywhere, just
like the four hosts in this flake already share one identity.

1. Securely copy the **existing** `~/.config/sops/age/keys.txt` from a
   machine that already works to the new one, at the same path, mode
   `600`. "Securely" means scp/an encrypted USB drive/a password manager --
   never paste it through anything that logs or a chat tool.
2. Clone this repo and `sudo nixos-rebuild switch --flake '.#<host>'`.

That's it -- no new keys to generate. The same `~/.ssh/id_ed25519` shows up
on the new machine because it's the same encrypted secret, decrypted with
the same age key.

### Rotating the SSH key

To replace the key everywhere (e.g. you suspect it leaked) without
touching the age identity:

```sh
ssh-keygen -t ed25519 -a 100 -C "<your GitHub email>" -f /tmp/id_ed25519 -N ""
{
  echo "id_ed25519: |"
  sed 's/^/  /' /tmp/id_ed25519
} > /tmp/ssh-secret.yaml
mv /tmp/ssh-secret.yaml hosts/common/users/mrgeotech/secrets/ssh.yaml
sops encrypt --in-place hosts/common/users/mrgeotech/secrets/ssh.yaml
rm /tmp/id_ed25519*
```

Commit and push, then on every machine: `git pull && sudo nixos-rebuild
switch --flake '.#<host>'`. Register the new public key with GitHub (as
**both** an Authentication Key and a Signing Key -- see above) and any
servers' `authorized_keys` *before* removing the old one from them, so you
don't lock yourself out mid-rotation.

### Recovering from a lost age key

If `~/.config/sops/age/keys.txt` doesn't exist anywhere and there's no
backup, every secret encrypted to the old recipient (not just the SSH key)
is permanently unrecoverable -- there is no way around generating a new
age identity and re-creating each secret's plaintext from scratch:

1. Generate a new age key (see "Brand new setup" above) and update the
   `keys:` entry in `.sops.yaml`.
2. For each file under `secrets/`, replace its content and re-encrypt with
   `sops encrypt --in-place <file>` (you're providing fresh plaintext,
   not decrypting the old one -- that's the part that's unrecoverable).
3. Copy the new `keys.txt` to every machine and rebuild each one.

## Acknowledgements

- [Dileep Kishore's nix config](https://github.com/dileep-kishore/nixos-hyprland) The framework my NixOS distro is based off of
- [EmergentMind's nix config](https://github.com/EmergentMind/nix-config): Structure, reference and some documentation
- [Misterio77's nix config](https://github.com/Misterio77/nix-config): Structure and reference
- [VimJoyer](https://github.com/vimjoyer): Whose YouTube videos aided me in beginning with Nix and persevering through challenges
