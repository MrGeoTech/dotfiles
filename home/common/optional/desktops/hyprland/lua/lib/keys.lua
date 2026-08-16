-- lib/keys.lua ---------------------------------------------------------------
-- Small helpers so the bind file reads like a keymap table instead of a wall
-- of hl.bind() calls. Loaded with autoLoad = false; required explicitly.
--
--   local keys = require("lib.keys")

local M = {}

--- Vim direction letters -> Hyprland direction names.
--- Iterate with M.each_dir() when you need a deterministic order.
M.dirs = { h = "left", j = "down", k = "up", l = "right" }

--- Deterministic h,j,k,l order (pairs() over M.dirs is unordered).
M.dir_order = { "h", "j", "k", "l" }

--- Unit vectors for resize/move deltas, same letters.
M.vecs = {
  h = { x = -1, y = 0 },
  j = { x = 0, y = 1 },
  k = { x = 0, y = -1 },
  l = { x = 1, y = 0 },
}

--- Call fn(letter, direction, vector) for h, j, k, l in that order.
function M.each_dir(fn)
  for _, letter in ipairs(M.dir_order) do
    fn(letter, M.dirs[letter], M.vecs[letter])
  end
end

--- Bind a list of { "KEY", dispatcher } pairs under a shared modifier.
--- Returns the list of bind handles, in case you want to toggle them later.
---
---   keys.map(mods.main, {
---     { "T", hl.dsp.exec_cmd("ghostty") },
---     { "Q", hl.dsp.window.close() },
---   })
function M.map(mod, binds, opts)
  local handles = {}
  local prefix = (mod and mod ~= "") and (mod .. " + ") or ""
  for i, b in ipairs(binds) do
    handles[i] = hl.bind(prefix .. b[1], b[2], opts)
  end
  return handles
end

return M
