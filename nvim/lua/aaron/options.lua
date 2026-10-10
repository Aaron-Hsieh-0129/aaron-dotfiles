-- Personal settings; LazyVim loads this before plugin configuration.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = true
local opt = vim.opt
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.wrap = false
opt.swapfile = false
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true

-- SSH yanks reach the client terminal via OSC 52, even with X11 forwarding.
-- Keep a local paste cache: many terminals allow clipboard writes, but not reads.
if vim.env.SSH_CONNECTION then
    local osc52 = require("vim.ui.clipboard.osc52")
    local copies, pastes = {}, {}
    for _, register in ipairs({ "+", "*" }) do
        local contents = { {}, "v" }
        local copy = osc52.copy(register)
        copies[register] = function(lines, regtype)
            contents = { vim.deepcopy(lines), regtype }
            copy(lines)
        end
        pastes[register] = function()
            return vim.deepcopy(contents)
        end
    end
    vim.g.clipboard = {
        name = "OSC 52 (SSH, cached paste)",
        copy = copies,
        paste = pastes,
        cache_enabled = 0,
    }
    opt.clipboard = "unnamedplus"
end

-- User-installed tools live outside the checkout and work across XDG locations.
local tools = vim.fn.stdpath("data"):gsub("[/\\]nvim$", "") .. "/aaron-nvim"
local sep = vim.fn.has("win32") == 1 and ";" or ":"
for _, dir in ipairs({ tools .. "/runtime/bin", tools .. "/bin" }) do
    if vim.fn.isdirectory(dir) == 1 then
        vim.env.PATH = dir .. sep .. vim.env.PATH
    end
end
-- Conda's compiler package may expose only a target-prefixed compiler.
if vim.fn.executable("cc") == 0 and not vim.env.CC then
    local compilers = vim.fn.glob(tools .. "/runtime/bin/*-cc", false, true)
    if #compilers > 0 then
        vim.env.CC = compilers[1]
    end
end
