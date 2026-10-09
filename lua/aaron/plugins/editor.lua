return {
    -- Retain the familiar explorer and the Git timeout fix.
    {
        "folke/snacks.nvim",
        opts = { explorer = { enabled = false } },
        keys = {
            { "<leader>e", false },
            { "<leader>E", false },
            { "<leader>fe", false },
            { "<leader>fE", false },
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
        opts = {
            view = { width = 30, relativenumber = true },
            renderer = { indent_markers = { enable = true } },
            filters = { custom = { ".DS_Store" } },
            git = { ignore = false, timeout = 10000 },
        },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer" },
            { "<leader>fe", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
        },
    },
    {
        "akinsho/bufferline.nvim",
        keys = {
            { "<leader>bl", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
            { "<leader>bh", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
        },
    },
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
        },
        keys = {
            { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
            { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
            { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
            { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
        },
    },
}
