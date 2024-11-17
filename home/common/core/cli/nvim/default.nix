{ config, pkgs, lib, ...}: let
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
  home.packages = with pkgs; [
    # Nix packages
    jdt-language-server
    ltex-ls
    lua-language-server
    marksman
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

    extraConfig = ''
      set number relativenumber
      set cc=100
      set conceallevel=2
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
	type = "lua";
	config = builtins.readFile(./lua/markdown.lua);
      }
      nvim-jdtls
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
      vim-wakatime
      vimtex
    ];
  };
}