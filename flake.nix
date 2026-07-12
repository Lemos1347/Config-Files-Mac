{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Stable channel used only for targeted overrides (see the starship
    # overlay below). Remove together with that overlay.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nix-darwin,
      nixpkgs,
      nixpkgs-stable,
    }:
    let
      user = "henriquematias";
      home = "/Users/${user}";

      configuration =
        { pkgs, ... }:
        let
          jetbrainsMonoNerdFont = pkgs.stdenvNoCC.mkDerivation {
            pname = "jetbrains-mono-nerd-font";
            version = "3.4.0";

            src = pkgs.fetchzip {
              url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip";
              hash = "sha256-251gsTXXmfYO+ibrCuWqPtFeYrdokPMOoh2jIx0/RgM=";
              stripRoot = false;
            };

            installPhase = ''
              runHook preInstall

              fontDir="$out/share/fonts/truetype/NerdFonts/JetBrainsMono"
              install -d "$fontDir"
              find "$src" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec install -m444 {} "$fontDir/" \;

              runHook postInstall
            '';
          };

          ohMyZshCustom = pkgs.stdenvNoCC.mkDerivation {
            pname = "oh-my-zsh-custom";
            version = "1";
            dontUnpack = true;

            installPhase = ''
              runHook preInstall

              customDir="$out/share/oh-my-zsh-custom"
              install -d "$customDir/plugins" "$customDir/themes"

              ln -s ${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions \
                "$customDir/plugins/zsh-autosuggestions"
              ln -s ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting \
                "$customDir/plugins/fast-syntax-highlighting"
              ln -s ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k \
                "$customDir/themes/powerlevel10k"

              install -d "$customDir/plugins/zsh-syntax-highlighting"
              printf '%s\n' \
                'source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' \
                > "$customDir/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

              runHook postInstall
            '';
          };

        in
        {
          system.primaryUser = user;
          users.users.${user} = {
            name = user;
            home = /Users/henriquematias;
          };

          security.pam.services.sudo_local = {
            touchIdAuth = true;
            # Reattach tmux/screen sessions to the user bootstrap session so
            # Touch ID works for sudo inside long-lived terminal multiplexers.
            reattach = true;
          };

          # Ensure determinate systems manages installation and updates
          nix.enable = false;

          # Allow unfree (proprietary) packages
          nixpkgs.config.allowUnfree = true;

          # starship 1.26.0 from nixpkgs-unstable fails to link on
          # aarch64-darwin (cctools ld64 crash; fixed upstream in
          # NixOS/nixpkgs#540463 but not yet in the channel). Take starship
          # from stable until the channel catches up, then drop this overlay
          # and the nixpkgs-stable input.
          nixpkgs.overlays = [
            (final: prev: {
              starship = nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.starship;
            })
          ];

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            btop
            ccache
            cmake
            coreutils
            curl
            dfu-util
            fd
            ffmpeg
            flatbuffers
            fzf
            gh
            git
            gnused
            hcp
            htop
            # Active AeroSpace stack: AeroSpace itself is a Homebrew cask, while
            # JankyBorders stays in Nix so its version is pinned by the flake.
            jankyborders
            jq
            lazygit
            postgresql_18
            postgresql_18.lib
            libuv
            llvm
            mise
            ngrok
            ninja
            nixfmt
            oh-my-zsh
            ohMyZshCustom
            pandoc
            poppler
            protobuf
            ripgrep
            # Legacy yabai/skhd stack: uncomment these two packages and the
            # matching service/Home Manager lines below if switching back.
            # skhd
            starship
            stripe-cli
            tmux
            # yabai
            (callPackage ./cypher-shell.nix { })
            (texlive.combine { inherit (texlive) scheme-full; })
          ];

          environment.pathsToLink = [
            "/lib"
            "/share/oh-my-zsh"
            "/share/oh-my-zsh-custom"
          ];

          fonts.packages = [
            jetbrainsMonoNerdFont
          ];

          # GUI apps are managed through Homebrew casks for native /Applications
          # installation and auto-update behavior.
          homebrew = {
            enable = true;
            inherit user;

            # Active AeroSpace stack: keep the tap explicit so the cask comes
            # from the same source as `brew install --cask nikitabobko/tap/aerospace`.
            taps = [
              "nikitabobko/tap"
            ];

            casks = [
              # Active AeroSpace window manager. Installed with Homebrew so the
              # app keeps the upstream cask behavior and update path.
              "aerospace"
              "betterdisplay"
              "dbeaver-community"
              "raycast"
              "spaceman"
              "stats"
              "ubersicht"
            ];

            onActivation = {
              autoUpdate = false;
              cleanup = "none";
              upgrade = false;
            };
          };

          # Active window manager is AeroSpace. It starts JankyBorders from
          # config/aerospace/aerospace.toml.
          #
          # Legacy yabai/skhd stack: uncomment these three lines and the
          # matching packages/Home Manager links if switching back.
          # services.yabai.enable = true;
          # services.skhd.enable = true;
          # launchd.user.agents.skhd.serviceConfig.RunAtLoad = true;

          programs.zsh.enable = false;

          # Active AeroSpace stack: make sure old yabai/skhd launch agents do
          # not keep running after the switch. The files are archived, not deleted.
          system.activationScripts.disableLegacyYabaiSkhd.text = ''
            echo "disabling legacy yabai/skhd launch agents for ${user}..." >&2

            uid="$(id -u ${user})"
            for label in \
              org.nixos.yabai \
              org.nixos.skhd \
              com.koekeishiya.yabai \
              com.koekeishiya.skhd \
              com.asmvik.yabai \
              com.asmvik.skhd; do
              launchctl bootout "gui/$uid/$label" 2>/dev/null || true
            done

            pkill -x -u ${user} yabai 2>/dev/null || true
            pkill -x -u ${user} skhd 2>/dev/null || true

            for plist in \
              ${home}/Library/LaunchAgents/org.nixos.yabai.plist \
              ${home}/Library/LaunchAgents/org.nixos.skhd.plist \
              ${home}/Library/LaunchAgents/com.koekeishiya.yabai.plist \
              ${home}/Library/LaunchAgents/com.koekeishiya.skhd.plist \
              ${home}/Library/LaunchAgents/com.asmvik.yabai.plist \
              ${home}/Library/LaunchAgents/com.asmvik.skhd.plist; do
              if [ -e "$plist" ]; then
                backup="$plist.before-aerospace"
                if [ -e "$backup" ]; then
                  backup="$backup.$(date +%Y%m%d%H%M%S)"
                fi

                mv -f "$plist" "$backup"
                chown ${user}:staff "$backup"
              fi
            done
          '';

          system.activationScripts.miseInstall.text = ''
            echo "installing mise tools for ${user}..." >&2

            mise_config=${home}/.config/nix-darwin-config/config/mise/config.toml
            if [ -f "$mise_config" ]; then
              if ! sudo -u ${user} env HOME=${home} USER=${user} MISE_GLOBAL_CONFIG_FILE="$mise_config" ${pkgs.mise}/bin/mise install; then
                echo "warning: mise install failed; run '${pkgs.mise}/bin/mise install' after checking network/toolchain output" >&2
              fi
            else
              echo "warning: $mise_config not found; skipping mise install" >&2
            fi
          '';

          # Install herdr plugins. herdr itself is a mise tool (see
          # config/mise/config.toml); `mise exec` resolves the managed binary
          # regardless of backend install layout, installing it first if
          # missing. Plugins are pinned to security-audited commits — bump a
          # ref only after reviewing the new commits.
          system.activationScripts.herdrPluginInstall.text = ''
            echo "installing herdr plugins for ${user}..." >&2

            mise_config=${home}/.config/nix-darwin-config/config/mise/config.toml
            herdr_exec() {
              sudo -u ${user} env HOME=${home} USER=${user} MISE_GLOBAL_CONFIG_FILE="$mise_config" \
                ${pkgs.mise}/bin/mise exec herdr -- herdr "$@"
            }

            # vim-herdr-navigation: seamless ctrl+hjkl between herdr panes and
            # vim splits. Keybinds live in config/herdr/config.toml; the editor
            # side is ~/.config/nvim/after/plugin/herdr_nav.lua (lemos-nvim repo).
            if ! herdr_exec plugin list 2>/dev/null | grep -q "vim-herdr-navigation"; then
              if ! herdr_exec plugin install paulbkim-dev/vim-herdr-navigation \
                --ref 53e318c772c4d3b7fbd904ac43bcf3e5b5d8b244 --yes; then
                echo "warning: herdr plugin install failed; retry manually with 'herdr plugin install paulbkim-dev/vim-herdr-navigation --yes'" >&2
              fi
            fi
          '';

          # Legacy yabai/skhd migration helper. Keep commented while AeroSpace
          # is active; uncomment only when actively migrating brew-managed yabai/skhd again.
          # system.activationScripts.archiveBrewWindowManagerLaunchAgents.text = ''
          #   echo "archiving stale Homebrew yabai/skhd LaunchAgents for ${user}..." >&2
          #
          #   for plist in \
          #     ${home}/Library/LaunchAgents/com.koekeishiya.yabai.plist \
          #     ${home}/Library/LaunchAgents/com.koekeishiya.skhd.plist \
          #     ${home}/Library/LaunchAgents/com.asmvik.yabai.plist \
          #     ${home}/Library/LaunchAgents/com.asmvik.skhd.plist; do
          #     if [ -e "$plist" ]; then
          #       mv -f "$plist" "$plist.before-nix-darwin"
          #       chown ${user}:staff "$plist.before-nix-darwin"
          #     fi
          #   done
          # '';

          system.activationScripts.tmuxPluginManager.text = ''
            echo "configuring tmux plugin manager for ${user}..." >&2

            install -d -m 0755 -o ${user} -g staff ${home}/.tmux/plugins
            if [ -d ${home}/.tmux/plugins/tpm/.git ]; then
              sudo -u ${user} env HOME=${home} USER=${user} git -C ${home}/.tmux/plugins/tpm pull --ff-only
            elif [ ! -e ${home}/.tmux/plugins/tpm ]; then
              sudo -u ${user} env HOME=${home} USER=${user} git clone https://github.com/tmux-plugins/tpm ${home}/.tmux/plugins/tpm
            else
              echo "warning: ${home}/.tmux/plugins/tpm exists but is not a git checkout; leaving it unchanged" >&2
            fi
          '';

          system.activationScripts.archiveManualOhMyZsh.text = ''
            echo "archiving manual oh-my-zsh install for ${user}..." >&2

            old=${home}/.oh-my-zsh
            backup=${home}/.oh-my-zsh.before-nix-darwin

            if [ -d "$old" ] && [ ! -L "$old" ]; then
              if [ -e "$backup" ]; then
                backup="$backup.$(date +%Y%m%d%H%M%S)"
              fi

              mv "$old" "$backup"
              chown -R ${user}:staff "$backup"
              echo "moved $old to $backup" >&2
            fi
          '';

          system.defaults = {
            ".GlobalPreferences" = {
              "com.apple.mouse.scaling" = 1.0;
            };

            CustomUserPreferences = {
              NSGlobalDomain = {
                # Active AeroSpace stack: recommended by AeroSpace so windows can
                # be dragged by gesture from anywhere in the window.
                "com.apple.mouse.linear" = true;
              };

              "com.raycast.macos" = {
                "NSStatusItem VisibleCC raycastIcon" = false;
                raycastGlobalHotkey = "Command-49";
                raycastPreferredWindowMode = "compact";
                raycastShouldFollowSystemAppearance = true;
              };

              "dev.jaysce.Spaceman" = {
                displayStyle = 2;
                SUEnableAutomaticChecks = true;
                SUSendProfileInfo = false;
              };

              "eu.exelban.Stats" = {
                Battery_notifications_high = "";
                Battery_notifications_low = "low";
                Battery_state = false;
                CPU_barChart_position = 3;
                CPU_label_position = 1;
                CPU_lineChart_position = 2;
                CPU_mini_color = "utilization";
                CPU_mini_position = 0;
                CPU_pieChart_position = 4;
                CPU_state = true;
                CPU_tachometer_position = 5;
                CPU_widget = "mini";
                Disk_state = false;
                GPU_barChart_position = 3;
                GPU_label_position = 0;
                GPU_lineChart_position = 2;
                GPU_mini_position = 1;
                GPU_state = true;
                GPU_tachometer_position = 4;
                GPU_widget = "";
                LaunchAtLoginNext = true;
                Network_state = false;
                RAM_barChart_position = 3;
                RAM_label_position = 1;
                RAM_lineChart_position = 2;
                RAM_memory_position = 5;
                RAM_mini_color = "pressure";
                RAM_mini_position = 0;
                RAM_pieChart_position = 4;
                RAM_tachometer_position = 6;
                RAM_text_position = 7;
                RAM_widget = "mini";
                Sensors_barChart_position = 2;
                Sensors_label_position = 1;
                Sensors_mini_position = 3;
                Sensors_stack_position = 0;
                Sensors_state = true;
                Sensors_widget = "sensors";
                dockIcon = false;
                "sensor_Average CPU" = true;
                "sensor_Fastest fan" = true;
                telemetry = false;
              };

              "pro.betterdisplay.BetterDisplay" = {
                SUAutomaticallyUpdate = true;
                SUEnableAutomaticChecks = true;
                SUSendProfileInfo = false;
                dockInsertRecentsOnStartupWhenHidden = false;
                hideMenuIcon = true;
                menuLevelBlueLight = "less";
                menuLevelBrightness = "less";
                menuLevelCheckForUpdates = "less";
                menuLevelColorDepth = "more";
                menuLevelColorMode = "more";
                menuLevelColorProfile = "more";
                menuLevelConfigProtection = "more";
                menuLevelContrast = "hide";
                menuLevelDDCAdjustments = "more";
                menuLevelDDCInput = "more";
                menuLevelDisplayConnect = "less";
                menuLevelDisplayDisconnect = "more";
                menuLevelDisplayMode = "more";
                menuLevelDisplaysAndVirtualScreens = "less";
                menuLevelGroups = "less";
                menuLevelImageAdjustments = "more";
                menuLevelManageDisplay = "more";
                menuLevelManageVirtualScreen = "more";
                menuLevelMirror = "more";
                menuLevelMove = "more";
                menuLevelPIP = "more";
                menuLevelQuit = "less";
                menuLevelRefreshRate = "more";
                menuLevelResolution = "less";
                menuLevelRotation = "more";
                menuLevelSettings = "less";
                menuLevelStream = "more";
                menuLevelToggles = "more";
                menuLevelVideoFilterWindow = "less";
                menuLevelVirtualScreenConnect = "less";
                menuLevelVirtualScreenDisconnect = "more";
                menuLevelVolume = "more";
                menuLevelXDRPreset = "more";
                onboardingMenuIcon = false;
                onboardingMoreIcon = false;
                onboardingSettingsIcon = false;
                showAdditionalPrivacySettings = true;
                showAdvancedMenuCustomization = true;
                showSettingsDetails = true;
                toolsMenuCollapsed = true;
              };
            };

            NSGlobalDomain = {
              AppleEnableSwipeNavigateWithScrolls = true;
              AppleInterfaceStyle = "Dark";
              InitialKeyRepeat = 20;
              KeyRepeat = 1;
              NSAutomaticCapitalizationEnabled = true;
              NSAutomaticDashSubstitutionEnabled = true;
              NSAutomaticPeriodSubstitutionEnabled = true;
              NSAutomaticQuoteSubstitutionEnabled = true;
              # Active AeroSpace stack: official nix-darwin option for
              # `defaults write -g NSWindowShouldDragOnGesture -bool true`.
              NSWindowShouldDragOnGesture = true;
              "com.apple.springing.delay" = 0.5;
              "com.apple.springing.enabled" = true;
              "com.apple.swipescrolldirection" = true;
              "com.apple.trackpad.forceClick" = false;
            };

            dock = {
              autohide = true;
              autohide-delay = 0.0;
              autohide-time-modifier = 0.4;
              launchanim = true;
              mru-spaces = false;
              orientation = "bottom";
              show-recents = false;
              showAppExposeGestureEnabled = true;
              showMissionControlGestureEnabled = true;
              tilesize = 45;
              wvous-bl-corner = 13;
              wvous-br-corner = 14;
            };

            finder = {
              CreateDesktop = true;
              FXPreferredViewStyle = "Nlsv";
              ShowExternalHardDrivesOnDesktop = true;
              ShowHardDrivesOnDesktop = false;
              ShowMountedServersOnDesktop = true;
              ShowRemovableMediaOnDesktop = true;
            };

            screencapture = {
              location = "~/Downloads";
              target = "file";
            };

            trackpad = {
              Clicking = true;
              Dragging = false;
              TrackpadRightClick = true;
              TrackpadThreeFingerDrag = true;
              TrackpadThreeFingerHorizSwipeGesture = 0;
              TrackpadThreeFingerTapGesture = 0;
              TrackpadThreeFingerVertSwipeGesture = 0;
            };
          };

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."MacBook-Pro-de-Henrique" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "before-home-manager";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    };
}
