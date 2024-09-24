{ lib, config, pkgs, ... }:

let 
  cfg = config.main-user;
in

{
  options.main-user = {
    enable
      = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "mr";
      description = ''
        username
      '';
    };
  };

  config = lib.mkIf cfg.enable{
    users.users.${cfg.userName} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      initialPassword = "toor";
      extraGroups = [ "wheel" "docker" ];
      packages = with pkgs; [
        bat
        bitwarden-desktop
	brave
        cava
        doas
        eza
        fd
        figma-linux
        flatpak
        gnome-software
	gnome-boxes
        heroic
        hyprland
        hyprlock
        hyprpaper
        kitty
        mpv
        neofetch
        nodejs_22
        ranger
        steam
        stow
        swaynotificationcenter
        sxiv
        tmux
        trayscale
        waybar
        wofi
        yarn
        android-tools
        btop
        clang
        docker
        file
        fprintd
        libfprint
        libfprint-2-tod1-vfs0090
        fzf
        git
        gnumake
        neovim
        pavucontrol
        pcmanfm
        pipx
        plexamp
        pstree
        python3
        python311Packages.pip
        ripgrep
        unclutter
        unzip
        usbutils
        vim
        wget
	zed-editor
        zsh
        vscode
      ];
    };
  };
}
