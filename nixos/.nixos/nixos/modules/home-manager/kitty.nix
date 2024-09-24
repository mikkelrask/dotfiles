{ pkgs ? import <nixpkgs> {} }:

{
  # Kitty configuration
  programs.kitty = {
    enable = true;

    config = ''
      include ${pkgs.base16-schemes}/share/themes/tokyo-night-storm.conf
      font_size        14
      disable_ligatures never
      italic_font      auto
      bold_font        auto
      bold_italic_font auto

      select_by_word_characters :@-./_~?&=%+#

      scrollback_pager less +G -R
      hide_window_decorations true
      background_opacity 0
      background_blur 100

      term             xterm-kitty
      open_url_modifiers ctrl
      open_url_with default
      window_margin_width 8
    '';
  };
}

