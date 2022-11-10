pkgs:
with pkgs.vimPlugins; [
  luasnip
  {
    type = "lua";
    plugin = nvim-cmp;
    config = builtins.readFile ./config.lua;
  }
]
