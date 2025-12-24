{ config, pkgs, lib, ...}:
let
  fromGitHub = { owner, repo, rev, sha ? lib.fakeSha256, subdir ? "." }: pkgs.stdenv.mkDerivation {
    pname = repo;
    version = rev;
    src = pkgs.fetchFromGitHub {
      owner = owner;
      repo = repo;
      rev = rev;
      sha256 = sha;
    };
    unpackPhase = ''
      mkdir -p $out
      cp -r ${subdir}/* $out/
    '';
  };

in {
  # https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  home.packages = with pkgs; [
    # Nix packages
    arduino-language-server
    beam27Packages.elixir-ls
    llvmPackages_20.clang-tools
    erlang-language-platform
    glsl_analyzer
    htmx-lsp
    jdt-language-server
    kotlin-language-server
    ltex-ls
    lua-language-server
    marksman
    matlab-language-server
    python312Packages.python-lsp-server
    svls
    typescript-language-server
    verible
    vhdl-ls
    vscode-langservers-extracted
    zls
  ] ++ [
    # GitHub Packages
  ];
  
  home.file.".config/nvim/en.utf-8.add".source = ./en.utf-8.add;
  home.file.".config/nvim/snippets" = {
    source = ./snippets;
    recursive = true;
  };
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    
    viAlias = true;
    vimAlias = true;
    
    extraLuaConfig = ''
      vim.g.mapLeader = "<Space>"

      vim.o.exrc = true
      vim.o.secure = true
    
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.colorcolumn = "100"
      vim.opt.conceallevel = 2
    
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
    
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "html", "css", "lua", "gleam", "nix", "dart" },
        callback = function()
          vim.opt_local.tabstop = 2
          vim.opt_local.shiftwidth = 2
        end,
      })
    
      vim.keymap.set("n", "<leader>e", ":Ex<CR>")
    '';
    
    plugins = with pkgs.vimPlugins; [
      ## Dependencies ##
      cmp-nvim-lsp # lsp-zero-nvim
      {
        plugin = luasnip; # lsp-zero-nvim
        type = "lua";
        config = builtins.readFile(./lua/luasnip.lua);
      }
      nvim-cmp # lsp-zero-nvim
      nvim-lspconfig # lsp-zero-nvim
      plenary-nvim # telescope-nvim, harpoon2

      ## Independent Plugins ##
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = builtins.readFile(./lua/catppuccin.lua);
      }
      cmp_luasnip
      {
        plugin = harpoon2;
        type = "lua";
        config = builtins.readFile(./lua/harpoon2.lua);
      }
      {
        plugin = lsp-zero-nvim;
        type = "lua";
        config = builtins.readFile(./lua/lsp-zero.lua);
      }
      {
        plugin = markdown-preview-nvim;
        type = "viml";
        config = builtins.readFile(./lua/markdown.vim);
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = builtins.readFile(./lua/treesitter.lua);
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile(./lua/telescope.lua);
      }
      {
        plugin = undotree;
        type = "lua";
        config = builtins.readFile(./lua/undotree.lua);
      }
      {
        plugin = vim-fugitive;
        type = "lua";
        config = builtins.readFile(./lua/fugitive.lua);
      }
      nvim-jdtls
      neoconf-nvim
      formatter-nvim
      vim-wakatime
      vimtex
      zoxide-vim
    ];
  };
}
