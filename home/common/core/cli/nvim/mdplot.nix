{ config, pkgs, ... }:

let
  # TODO: Make it take latex functions directly
  mdplot = pkgs.writeScriptBin "mdplot" ''
#!/usr/bin/env python3
import sys
import numpy as np
import matplotlib.pyplot as plt
import re

out = sys.argv[1]
args = sys.argv[2:]

# Extract functions and optional domain
funcs = []
domain = [-10, 10]  # default

for a in args:
    m = re.match(r"x=([-\d.]+):([-\d.]+)", a)
    if m:
        domain = [float(m.group(1)), float(m.group(2))]
    else:
        funcs.append(a)

# Automatic domain detection helper
def auto_trim(x, y, tol=1e-2):
    dy = np.abs(np.diff(y))
    idx = np.where(dy > tol)[0]
    if len(idx) == 0:
        return x, y
    start, end = idx[0], idx[-1]+1  # ensure same length
    return x[start:end+1], y[start:end+1]

x = np.linspace(domain[0], domain[1], 1000)
colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]

# Make numpy functions available in eval
safe_dict = {k: getattr(np, k) for k in dir(np) if not k.startswith("_")}
safe_dict["x"] = x

# Common EE and math functions
def u(t):
    return np.where(t >= 0, 1, 0)

def delta(t, dt=None):
    if dt is None:
        dt = t[1]-t[0] if len(t) > 1 else 1.0
    d = np.zeros_like(t)
    idx = np.argmin(np.abs(t))  # closest to t=0
    d[idx] = 1/dt
    return d

def sgn(t):
    return np.sign(t)

def rect(t):
    return np.where(np.abs(t) <= 0.5, 1, 0)

def tri(t):
    return np.maximum(1 - np.abs(t), 0)

def pw(*args):
    """
    Piecewise function for plotting:
    pw(f1, c1, f2, c2, ..., fn)
    - fi can be scalars, expressions using x, or numpy arrays
    - ci is a boolean array or expression using x
    - The last argument is the "else" case if the number of args is odd
    """
    x = safe_dict["x"]
    result = np.zeros_like(x, dtype=float)

    # Determine if last arg is default
    if len(args) % 2 == 1:
        default = args[-1]
        pairs = args[:-1]
    else:
        default = 0
        pairs = args

    assigned = np.zeros_like(result, dtype=bool)

    # Helper to evaluate and broadcast
    def eval_and_broadcast(val):
        if isinstance(val, str):
            y = eval(val, {"__builtins__": {}}, safe_dict)
        else:
            y = np.array(val)
        if y.shape != x.shape:
            y = np.full_like(x, y, dtype=float)
        return y

    # Apply each condition
    for f, c in zip(pairs[::2], pairs[1::2]):
        y = eval_and_broadcast(f)
        mask = eval_and_broadcast(c).astype(bool)
        mask &= ~assigned
        result[mask] = y[mask]
        assigned[mask] = True

    # Apply default to remaining
    y = eval_and_broadcast(default)
    result[~assigned] = y[~assigned]

    return result

# Add to safe_dict
safe_dict.update({
    "u": u,
    "delta": delta,
    "sgn": sgn,
    "rect": rect,
    "tri": tri,
    "pw": pw,
    # aliases for convenience
    "heaviside": u,
})

plt.figure()
for i, f in enumerate(funcs):
    y = eval(f, {"__builtins__": {}}, safe_dict)
    # auto trim if no custom domain
    if domain == [-10, 10]:
        x_trim, y_trim = auto_trim(x, y)
    else:
        x_trim, y_trim = x, y
    plt.plot(x_trim, y_trim, label=f, color=colors[i % len(colors)])

plt.legend()
plt.grid(True)
plt.savefig(out, dpi=200)
plt.close()
  '';
in
{
  home.packages = with pkgs; [
    (python3.withPackages(py-pkgs: with py-pkgs; [
      numpy
      matplotlib
      #sympy
      #lark
    ]))
    mdplot
  ];

  programs.neovim = {
    enable = true;

    extraLuaConfig = ''
      local function plot_md()
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local fname = vim.fn.expand("%:t:r")
        local imgdir = "Images"
      
        vim.fn.mkdir(imgdir, "p")
      
        local count = 0
        for _, l in ipairs(lines) do
          if l:match("%!%[.*%]%(" .. imgdir) then
            count = count + 1
          end
        end
      
        for i, l in ipairs(lines) do
          if l:match("^!plot") then
            local fns = {}
            for f in l:gmatch("{(.-)}") do
              table.insert(fns, f)
            end
      
            -- capture optional [x=start:end]
            local domain_arg = l:match("%[(x=[^%]]+)%]") or ""
      
            local img = string.format("%s/%s_%d.png", imgdir, fname, count)
            local cmd = { "mdplot", img }
            vim.list_extend(cmd, fns)
            if domain_arg ~= "" then
              table.insert(cmd, domain_arg)
            end
      
            vim.fn.system(cmd)
      
            local alt = table.concat(fns, ", ")
            lines[i] = string.format("![Graph of function(s)](%s)", img)
            count = count + 1
          end
        end
      
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      end

      vim.api.nvim_create_user_command("MDPlot", plot_md, {})

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.md",
        callback = plot_md,
      })
    '';
  };
}
