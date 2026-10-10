return {
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            -- Mason's clangd release does not support Linux ARM64.
            -- Use the installed native clangd when available instead of retrying.
            local platform = vim.uv.os_uname()
            if
                platform.sysname == "Linux"
                and platform.machine == "aarch64"
                and vim.fn.executable("clangd") == 1
            then
                opts.servers.clangd =
                    vim.tbl_deep_extend("force", opts.servers.clangd or {}, { mason = false })
            end
        end,
    },
}
