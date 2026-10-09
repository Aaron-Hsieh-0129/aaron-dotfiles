-- Wait for VimEnter/VeryLazy before checking the complete configuration.
vim.defer_fn(function()
    -- lazy.nvim waits for UIEnter; headless installers/checks have no UI attached.
    if not vim.g.did_very_lazy then
        vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
        assert(
            vim.wait(10000, function()
                return vim.g.did_very_lazy
            end, 50),
            "Lazy startup timed out"
        )
    end
    -- Called by bootstrap.sh; all downloaded artifacts stay in Neovim's data directory.
    local function install()
        vim.wait(1000)
        require("mason")
        local registry = require("mason-registry")
        local names = {
            "clangd",
            "lua-language-server",
            "pyright",
            "ruff",
            "neocmakelsp",
            "stylua",
            "shfmt",
            "clang-format",
            "black",
            "isort",
            "prettier",
            "cmakelang",
            "cmakelint",
        }
        local failed = {}
        registry.refresh(function()
            for _, name in ipairs(names) do
                local package = registry.get_package(name)
                if not package:is_installed() and not package:is_installing() then
                    package:install(
                        nil,
                        vim.schedule_wrap(function(success)
                            if not success then
                                failed[name] = true
                            end
                        end)
                    )
                end
            end
        end)
        local done = vim.wait(600000, function()
            if next(failed) then
                return true
            end
            for _, name in ipairs(names) do
                if not registry.get_package(name):is_installed() then
                    return false
                end
            end
            return true
        end, 250)
        for _, name in ipairs(names) do
            assert(
                registry.get_package(name):is_installed(),
                "Tool installation failed: " .. name .. "; see :MasonLog"
            )
        end
        assert(done, "Tool installation timed out; see :MasonLog")
        vim.wait(1000)
        local TS = require("nvim-treesitter")
        local opts = LazyVim.opts("nvim-treesitter")
        TS.install(opts.ensure_installed):wait(600000)
        LazyVim.treesitter.get_installed(true)
        for _, name in ipairs(opts.ensure_installed) do
            assert(
                LazyVim.treesitter.get_installed()[name],
                "Parser installation failed: " .. name .. "; see :TSLog"
            )
        end
        io.stdout:write(
            "PASS: language servers, formatters, and configured Treesitter parsers installed\n"
        )
    end
    local ok, err = xpcall(install, debug.traceback)
    if not ok then
        io.stderr:write(err .. "\n")
        vim.cmd("cquit 1")
    else
        vim.cmd("qa!")
    end
end, 100)
