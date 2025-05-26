{ pkgs, wayland, config, stylix, lib, ... }:
let
  waybar_conf_dir = "/home/mr/.config/waybar/egosummiki";
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    hyprpaper & 
    waybar -c ${waybar_conf_dir}/config -s ${waybar_conf_dir}/style.css &
    ${pkgs.trayscale}/bin/trayscale --hide-window &
    ${pkgs.picom}/bin/picom -b &
  '';
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mr";
  home.homeDirectory = "/home/mr";
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "ALT";
      "$terminal" = "kitty";
      "$filemanager" = "pcmanfm";
      "$menu" = "/home/mr/.local/bin/launcher";

      monitor = "eDP-1,1920x1080@60,0x0,1";

      exec-once = ''${startupScript}/bin/start'';

      general = {
	allow_tearing = false;
      };

      input = {
        kb_layout = "dk";
        kb_options = "caps:swapescape";
        follow_mouse = "1";
	touchpad = {
	  natural_scroll = true;
	  disable_while_typing = true;
	};
      };
      gestures = {
	workspace_swipe = true;
      };
      
      decoration = {
	rounding = 5;
	inactive_opacity = 0.8;
	drop_shadow = true;
	      blur = {
		enabled = true;
		size = 10;
	      };
      };

      misc = {
	disable_hyprland_logo = true;	
	disable_splash_rendering = true;
	font_family = "monospace";
      };

      bind = [
        "$mod, T, exec, $filemanager"
        "$mod, RETURN, exec, $terminal"
        "$mod, D, exec, $menu"
        "CTRL $mod, L, exec, hyprlock"
        "$mod, F, fullscreen"
        "$mod SHIFT, X, exit"
        "$mod SHIFT, Q, killactive"
        "$mod, W, exec, flatpak run net.waterfox.waterfox"
        "$mod, V, togglefloating"
        ", PRINT, exec, flameshot"

        # Windows and Focus
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, u"
        "$mod, k, movefocus, d"
        "$mod, l, movefocus, r"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, u"
        "$mod SHIFT, k, movewindow, d"
        "$mod SHIFT, l, movewindow, r"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        )
        9)
      );
    };
  };

}

