-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                          WezTerm Configuration                               ║
-- ║                                                                              ║
-- ║  Clean and minimal with Catppuccin Mocha theme                              ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local wezterm = require("wezterm")

return {
    default_prog = { '/opt/homebrew/bin/fish', '-l' },

    -- Cursor
    default_cursor_style = "BlinkingBlock",
    
    -- Font
        -- Use the bundled JetBrains Mono font and let WezTerm's built-in
    -- Nerd Font Symbols fallback handle the icons.
    font = wezterm.font("JetBrains Mono"),
    font_size = 13,
    line_height = 1,
    
    -- Theme - Built-in Catppuccin Mocha
    color_scheme = "Catppuccin Mocha",
    
    -- Window
    window_background_opacity = 0.92,
    macos_window_background_blur = 30,
    window_decorations = "RESIZE",
    window_padding = {
        left = 30,
        right = 30,
        top = 30,
        bottom = 30,
    },
    
    -- Tab bar
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    
    -- Performance
    animation_fps = 120,
    max_fps = 120,
    front_end = "WebGpu",
    webgpu_power_preference = "HighPerformance",
    
    -- Misc
    automatically_reload_config = true,
    audible_bell = "Disabled",
    adjust_window_size_when_changing_font_size = false,
    
    -- Keybindings
    keys = {
        {
            key = 'q',
            mods = 'CTRL',
            action = wezterm.action.ToggleFullScreen,
        },
        {
            key = "'",
            mods = 'CTRL',
            action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
        },
    },
    
    mouse_bindings = {
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
    },
}
