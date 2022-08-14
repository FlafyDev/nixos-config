pkgs: {
  type = "lua";
  plugin = pkgs.vimPlugins.sniprun;
  config = builtins.readFile ./config.lua;
}
