return {
    { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-mocha" } },
    { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
                preset = { header = "Aaron's Neovim\nPowered by LazyVim" },
            },
        },
    },
}
