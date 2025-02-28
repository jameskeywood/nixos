{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.james = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "james";
    home.homeDirectory = "/home/james";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')

      # script for dwm status bar
      (pkgs.writeShellScriptBin "status" ''
        while true
        do
          CON=''$(nmcli | grep -o "[^ ]*''$" -m 1)
          STR=''$(cat /proc/net/wireless | grep wlp3s0 | awk '{print int(''$3)}')
          BLU=''$(bluetoothctl devices Connected | cut -d' ' -f3-)
          BRI=''$(light)
          VOL=''$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o [0-9].[0-9][0-9])
          BAT=''$(cat /sys/class/power_supply/BAT0/capacity)
          xsetroot -name " ''$(date) | CON:''${CON} ''${STR} | BLU:''${BLU[0]} | BRI:''${BRI} | VOL:''${VOL} | BAT:''${BAT}% "
          sleep 1
        done
      '')

      # script for converting files into pdfs
      (pkgs.writeShellScriptBin "conpdf" ''
        if [ "''$#" -ne 1 ]; then
          echo "Usage: conpdf <file_to_convert>"
          exit 1
        fi

        FILE="''$1"
        
        if [ ! -f "''$FILE" ]; then
          echo "Error: File '$FILE' not found."
          exit 1
        fi

        soffice --headless --convert-to pdf --outdir . "''$FILE"
      '')

      # script for playing brown noise
      (pkgs.writeShellScriptBin "noise" ''
        sox -n -d synth -1 brownnoise vol 0.02
      '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/james/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      # EDITOR = "emacs";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Git config
    programs.git = {
      enable = true;
      userName = "p38360jk";
      userEmail = "james.keywood@student.manchester.ac.uk";
    };

    # Vim config
    programs.vim = {
      enable = true;
      # plugins = with pkgs.vimPlugins; [ vim-airline ];
      # settings = { ignorecase = true; };
      extraConfig = ''
        set tabstop=4
        set shiftwidth=4
        syntax on
        set smarttab
      '';
    };

    # Zathura config
    programs.zathura = {
      enable = true;
      options = { default-bg = "#EEE8D5"; };
    };

  };
}
