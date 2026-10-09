return {
    {
        "stevearc/conform.nvim",
        opts = {
            default_format_opts = { timeout_ms = 10000 },
            formatters_by_ft = {
                c = { "clang-format" },
                cpp = { "clang-format" },
                objc = { "clang-format" },
                objcpp = { "clang-format" },
                cuda = { "clang-format" },
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                svelte = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                liquid = { "prettier" },
            },
        },
        keys = {
            {
                "<leader>mp",
                function()
                    LazyVim.format({ force = true })
                end,
                mode = { "n", "x" },
                desc = "Format file or selection",
            },
        },
    },
    {
        "mason-org/mason.nvim",
        opts = {
            PATH = "append",
            ensure_installed = { "clang-format", "black", "isort", "prettier" },
        },
    },
}
