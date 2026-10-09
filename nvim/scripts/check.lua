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
    -- Run: nvim --headless '+luafile scripts/check.lua'
    local temp = vim.fn.tempname()
    vim.fn.mkdir(temp, "p")
    local function run(args)
        local result = vim.system(args, { cwd = temp, text = true }):wait(20000)
        assert(result.code == 0, result.stderr or vim.inspect(result))
        return result.stdout
    end
    local function check()
        vim.wait(1000)
        assert(vim.g.mapleader == " ", "Space leader missing")
        assert(vim.o.shiftwidth == 4 and vim.o.tabstop == 4, "Indent settings missing")
        assert(vim.fn.maparg("jk", "i") ~= "", "Insert escape mapping missing")
        assert(vim.fn.maparg("<leader>e", "n") ~= "", "Explorer mapping missing")
        run({ "git", "init", "-q" })
        run({ "git", "symbolic-ref", "HEAD", "refs/heads/main" })
        vim.fn.writefile({ "int main(){return 0;}" }, temp .. "/sample.cpp")
        vim.fn.writefile({ "build/" }, temp .. "/.gitignore")
        run({ "git", "add", "." })
        run({
            "git",
            "-c",
            "user.name=Neovim Check",
            "-c",
            "user.email=nvim-check@example.invalid",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "-qm",
            "Fixture",
        })
        vim.cmd.cd(vim.fn.fnameescape(temp))
        vim.cmd.edit(vim.fn.fnameescape(temp .. "/sample.cpp"))
        vim.wait(2000)
        local conform = require("conform")
        assert(conform.get_formatter_info("clang-format", 0).available, "clang-format unavailable")
        assert(
            vim.wait(30000, function()
                return #vim.lsp.get_clients({ bufnr = 0, name = "clangd" }) > 0
            end, 100),
            "clangd did not attach"
        )
        assert(vim.treesitter.get_parser(0, "cpp"):parse()[1], "C++ parser failed")
        assert(vim.treesitter.query.get("cpp", "highlights"), "C++ highlight query missing")
        require("blink.cmp")
        local original = "int main(){int x=1;return x;}"
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { original })
        local mapping = vim.fn.maparg("<leader>mp", "n", false, true)
        assert(type(mapping.callback) == "function", "Formatting mapping missing")
        mapping.callback()
        assert(
            vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= original,
            "Manual formatting failed"
        )
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { original })
        vim.cmd.write()
        assert(vim.fn.readfile(temp .. "/sample.cpp")[1] ~= original, "Format on save failed")
        assert(
            vim.wait(15000, function()
                return vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.changed ~= nil
            end, 100),
            "Gitsigns did not attach"
        )
        require("nvim-tree.api").tree.open()
        local project = require("nvim-tree.git").get_project(temp)
        assert(
            project and project.files[temp .. "/sample.cpp"] == " M",
            "Explorer Git status missing"
        )
        require("nvim-tree.api").tree.close()
        vim.cmd.edit(vim.fn.fnameescape(temp .. "/.gitignore"))
        assert(vim.bo.filetype == "gitignore", "Gitignore filetype missing")
        assert(vim.treesitter.get_parser(0, "gitignore"):parse()[1], "Gitignore parser failed")
        assert(
            vim.treesitter.query.get("gitignore", "highlights"),
            "Gitignore highlighting missing"
        )
        io.stdout:write(
            "PASS: Aaron settings, clangd, completion, C++/Git parsers, formatting, and Git status\n"
        )
    end
    local ok, err = xpcall(check, debug.traceback)
    -- Do not save an integration-test session into the user's session directory.
    if package.loaded.persistence then
        require("persistence").stop()
    end
    vim.cmd("silent! %bwipeout!")
    vim.fn.delete(temp, "rf")
    if not ok then
        io.stderr:write(err .. "\n")
        vim.cmd("cquit 1")
    else
        vim.cmd("qa!")
    end
end, 100)
