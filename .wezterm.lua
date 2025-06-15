local wezterm = require 'wezterm';

return {
    window_background_opacity = 0.95,
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = true,
    enable_wayland = true,
    colors = wezterm.get_builtin_color_schemes()["Catppuccin Frappe"],
    exit_behavior = "Close",

    font = wezterm.font("Hack Nerd Font"),
    initial_rows = 40,
    initial_cols = 120,
    window_close_confirmation = 'NeverPrompt'
}
