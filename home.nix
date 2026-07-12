{ ... }:

{
  home.stateVersion = "26.05";

  # Avoid evaluating Home Manager's generated options manpage on every rebuild.
  # Current upstream docs generation emits an options.json store-context warning.
  manual.manpages.enable = false;

  home.file.".p10k.zsh".source = ./dotfiles/.p10k.zsh;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".zprofile".source = ./dotfiles/.zprofile;
  home.file.".zshrc".source = ./dotfiles/.zshrc;

  xdg.configFile = {
    # Active AeroSpace stack.
    "aerospace/aerospace.toml".source = ./config/aerospace/aerospace.toml;
    "ghostty/config".source = ./config/ghostty/config;
    "herdr/config.toml".source = ./config/herdr/config.toml;
    "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
    "mise/config.toml".source = ./config/mise/config.toml;
    "starship.toml".source = ./config/starship.toml;

    # Legacy yabai/skhd stack. Keep commented while AeroSpace is active;
    # uncomment these links with the matching flake.nix package/service lines to switch back.
    # "skhd/skhdrc".source = ./config/skhd/skhdrc;
    # "yabai/yabairc".source = ./config/yabai/yabairc;
  };

  programs.home-manager.enable = true;
}
