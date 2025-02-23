{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./main-user.nix
      inputs.home-manager.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dolores"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Amsterdam";

  # Bluetooth?
  hardware.bluetooth.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "da_DK.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "dk";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    hack-font
    noto-fonts-emoji
    fira-code
    fantasque-sans-mono
    fira-code-symbols
    (nerdfonts.override { fonts = [ "Hack" "FantasqueSansMono" "FiraCode" "DroidSansMono" ]; })
  ];
  
  # Home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "mr" = import ./home.nix;
    };
  };
      

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.fprintd.enable = true;

  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Auto Update
  system.autoUpgrade = {
    enable = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    };
  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  main-user.enable = true;
  main-user.userName = "mr";


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     android-tools
     btop
     clang
     docker
     file
     fprintd  
     fzf
     git
     gnumake
     libfprint
     libfprint-2-tod1-vfs0090
     neovim
     pavucontrol
     pcmanfm
     pfetch-rs
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
     zsh
     vscode
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";

  # Docker
  virtualisation.docker.enable = true;

  # DOAS 
  security.doas.enable = true;
  security.sudo.enable = true;
  security.doas.extraRules = [{
   users = ["mr"];
   # Optional, retains environment variables while running commands 
   # e.g. retains your NIX_PATH when applying your config
   keepEnv = true; 
   persist = true;  # Optional, only require password verification a single time
  }];

  programs.zsh.enable = true; 

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.hyprland = {
    enable = true;
  };


  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  system.stateVersion = "24.05"; # Did you read the comment?

  # flake.nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
