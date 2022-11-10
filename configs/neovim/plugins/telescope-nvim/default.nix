pkgs:
with pkgs.vimPlugins; [
  telescope-file-browser-nvim
  {
    type = "lua";
    plugin = telescope-nvim;
    config = builtins.readFile ./config.lua;
  }
]
