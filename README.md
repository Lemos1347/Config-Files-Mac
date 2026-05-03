# Config Files Mac

[![Nix](https://img.shields.io/badge/Nix-flakes-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![nix-darwin](https://img.shields.io/badge/nix--darwin-macOS-000000?logo=apple&logoColor=white)](https://github.com/nix-darwin/nix-darwin)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-enabled-7B42BC)](https://github.com/nix-community/home-manager)
[![Determinate Nix](https://img.shields.io/badge/installer-Determinate%20Nix-blue)](https://github.com/DeterminateSystems/nix-installer)

Personal macOS configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and Homebrew casks.

This repository is currently tailored for:

- User: `henriquematias`
- Host configuration: `MacBook-Pro-de-Henrique`
- Repository path: `~/.config/nix-darwin-config`

Review those values in `flake.nix` before applying it on a different machine.

## What It Manages

- macOS defaults, Dock behavior, keyboard repeat settings, pointer settings, and launchd services.
- Nix packages for CLI tools, development tools, shell tooling, yabai/skhd, tmux, Starship, mise, and fonts.
- Homebrew casks for GUI applications that are better installed through Homebrew.
- Home Manager links for selected dotfiles and selected `~/.config` files.
- oh-my-zsh, plugins, Powerlevel10k availability, tmux TPM, and JetBrains Mono Nerd Font.
- mise global configuration through `MISE_GLOBAL_CONFIG_FILE`.

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | nix-darwin system configuration, packages, services, Homebrew, and Home Manager wiring. |
| `home.nix` | Home Manager file mappings into `$HOME`. |
| `dotfiles/` | Files linked directly into `$HOME`, such as `.zshrc`, `.zprofile`, `.tmux.conf`, and `.p10k.zsh`. |
| `config/` | Managed subset of `~/.config`, including Ghostty, Kitty, mise, skhd, yabai, and Starship. |
| `cypher-shell.nix` | Custom package definition used by the flake. |

## Installation

Install Apple's command line tools if they are not present:

```sh
xcode-select --install
```

Install Nix with the [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer):

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal session, then clone this repository:

```sh
git clone https://github.com/Lemos1347/Config-Files-Mac ~/.config/nix-darwin-config
cd ~/.config/nix-darwin-config
```

Build the configuration first:

```sh
nix build .#darwinConfigurations.MacBook-Pro-de-Henrique.system
```

Apply it:

```sh
sudo ./result/sw/bin/darwin-rebuild switch --flake .#MacBook-Pro-de-Henrique
```

After the first successful switch, future rebuilds can use:

```sh
cd ~/.config/nix-darwin-config
sudo darwin-rebuild switch --flake .#MacBook-Pro-de-Henrique
```

## After Rebuild

Open a new terminal session and check the managed files:

```sh
readlink ~/.zshrc
readlink ~/.config/starship.toml
home-manager generations
```

Install any mise tools declared in `config/mise/config.toml`:

```sh
mise install
```

Check that mise uses the repository config as the global config target:

```sh
echo "$MISE_GLOBAL_CONFIG_FILE"
```

## Local Files

`~/.zshrc.local` is intentionally not managed by Home Manager. Put secrets, machine-specific paths, temporary exports, and local aliases there.

The managed `.zshrc` sources it at the end when present:

```sh
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
```

Some tools try to append shell setup directly to `~/.zshrc`. Because this file is managed by Home Manager, move those additions into one of these places instead:

- `dotfiles/.zshrc` for shared, versioned shell configuration.
- `~/.zshrc.local` for private or machine-specific shell configuration.

The `zshrc` helper opens the managed file in this repository with `$EDITOR`.

## Updating

Update flake inputs:

```sh
nix flake update
```

Apply changes:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix-darwin-config#MacBook-Pro-de-Henrique
```

Commit the resulting configuration changes:

```sh
git status
git add flake.lock flake.nix home.nix dotfiles config
git commit -m "chore: update mac configuration"
```

## References

- [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer)
- [Nix on macOS tutorial by Nixcademy](https://nixcademy.com/posts/nix-on-macos/)
- [nix-darwin manual](https://nix-darwin.github.io/nix-darwin/manual/index.html)
- [Home Manager manual](https://nix-community.github.io/home-manager/)
