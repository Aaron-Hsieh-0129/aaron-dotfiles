return {
    { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-mocha" } },
    { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
    {
        "nvim-mini/mini.icons",
        opts = {
            extension = {
                hpp = { glyph = "H", hl = "MiniIconsCyan" },
            },
        },
    },
    {
        "nvim-tree/nvim-web-devicons",
        opts = {
            override_by_extension = {
                hpp = { icon = "H", color = "#89dceb", cterm_color = "116", name = "HppHeader" },
            },
        },
    },
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
                preset = { header = "Aaron's Neovim\nPowered by LazyVim" },
            },
        },
    },
}
