-- Transparent age encryption for *.priv / *.me files, using the same SSH
-- identity as the rest of this repo (see hosts/common/users/mrgeotech and
-- home/common/core/cli/ssh.nix) instead of a separate age key. Files with
-- these extensions are ciphertext on disk at all times; only the in-memory
-- buffer is ever plaintext. Assumes a passphrase-less identity -- age gets
-- no TTY when run from inside Neovim's job control, so a passphrase prompt
-- would just fail.

local identity = vim.fn.expand("~/.ssh/id_ed25519")
local recipient = vim.fn.expand("~/.ssh/id_ed25519.pub")
local patterns = { "*.priv", "*.me" }

local function harden_buffer()
  vim.opt_local.swapfile = false
  vim.opt_local.backup = false
  vim.opt_local.undofile = false
end

local function set_inner_filetype(path)
  local inner = path:gsub("%.priv$", ""):gsub("%.me$", "")
  local ft = vim.filetype.match({ filename = inner })
  if ft then
    vim.bo.filetype = ft
  end
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadCmd" }, {
  pattern = patterns,
  callback = function(args)
    local path = args.match
    harden_buffer()
    set_inner_filetype(path)

    if vim.fn.filereadable(path) == 0 or vim.fn.getfsize(path) <= 0 then
      vim.bo.modified = false
      return
    end

    if vim.fn.filereadable(identity) == 0 then
      vim.notify("crypt: SSH identity not found at " .. identity, vim.log.levels.ERROR)
      vim.bo.readonly = true
      return
    end

    local lines = vim.fn.systemlist({ "age", "--decrypt", "-i", identity, path })
    if vim.v.shell_error ~= 0 then
      vim.notify(
        "crypt: age failed to decrypt " .. path .. " (exit " .. vim.v.shell_error .. ")",
        vim.log.levels.ERROR
      )
      vim.bo.readonly = true
      return
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.modified = false
  end,
})

vim.api.nvim_create_autocmd("BufWriteCmd", {
  pattern = patterns,
  callback = function(args)
    local path = args.match
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local content = table.concat(lines, "\n") .. "\n"

    vim.fn.system({ "age", "--encrypt", "--armor", "-R", recipient, "-o", path }, content)
    if vim.v.shell_error ~= 0 then
      vim.notify(
        "crypt: age failed to encrypt " .. path .. " (exit " .. vim.v.shell_error .. ")",
        vim.log.levels.ERROR
      )
      return
    end

    vim.bo.modified = false
  end,
})
