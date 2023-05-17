pkgs:
with pkgs.vimPlugins; [
  nvim-dap-ui
  {
    type = "lua";
    plugin = nvim-dap;
    config = builtins.readFile ./config.lua;
  }
]
