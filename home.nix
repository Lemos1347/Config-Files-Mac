{ ... }:

{
  home.stateVersion = "26.05";

  home.file.".p10k.zsh".source = ./dotfiles/.p10k.zsh;
  home.file.".tmux.conf".source = ./dotfiles/.tmux.conf;
  home.file.".zprofile".source = ./dotfiles/.zprofile;
  home.file.".zshrc".source = ./dotfiles/.zshrc;

  xdg.configFile = {
    "ghostty/config".source = ./config/ghostty/config;
    "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
    "mise/config.toml".source = ./config/mise/config.toml;
    "skhd/skhdrc".source = ./config/skhd/skhdrc;
    "starship.toml".source = ./config/starship.toml;
    "yabai/yabairc".source = ./config/yabai/yabairc;
  };

  programs.home-manager.enable = true;
}
