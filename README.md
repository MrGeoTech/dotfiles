<!-- markdownlint-disable -->
<h1 align="center">
    <a name="top" title="nixos-hyprland">
        nixos-hyprland v2
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
    Includes my <a href="https://github.com/nix-community/home-manager" >Home Manager</a> configuration for linux and macos.
    <p><strong>Be sure to <a href="#" title="star">⭐️</a> or <a href="#" title="fork">🔱</a> this repo if you find it useful! 😃</strong></p>
</div>
<!-- markdownlint-restore -->

## Setup

- OS: [NixOS](https://nixos.org)
- Window manager: [Hyprland](https://hyprland.org)
- Status bar: [Waybar](https://github.com/Alexays/Waybar)
- Terminal: [Kitty](https://sw.kovidgoyal.net/kitty/)
- Shell: `Zsh` with plugins managed through [antidote](https://github.com/mattmc3/antidote) with [oh-my-posh](https://ohmyposh.dev/) prompt
- Current theme: [Catppuccin](https://catppuccin.com/)
- Font: [Maple Mono](https://github.com/subframe7536/maple-font)
- Editor: [Neovim](https://neovim.io). Configuration can be found [here](https://github.com/dileep-kishore/neovim)

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

## Installation

### Requirements

- NixOS (I use 24.11)
- Patience
- Knowledge
- Disk space

### Commands
```sh
cd /etc/nixos/
sudo mkdir /shared
sudo chown mrgeotech /shared
sudo nixos-rebuild switch --flake '.#<host>'
```
## Acknowledgements

- [EmergentMind's nix config](https://github.com/EmergentMind/nix-config): Structure, reference and some documentation
- [Misterio77's nix config](https://github.com/Misterio77/nix-config): Structure and reference
- [VimJoyer](https://github.com/vimjoyer): Whose YouTube videos aided me in beginning with Nix and persevering through challenges

## TODO:
- [ ] Update README.md
