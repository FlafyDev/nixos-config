{
  home = { pkgs, ... }@args: let 
    settings = import ./config.nix args;
    style = import ./style.nix args;
  in {
    home.packages = with pkgs; [
      python39Packages.requests
    ];
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        patchPhase = ''
          substituteInPlace src/modules/wlr/workspace_manager.cpp --replace "zext_workspace_handle_v1_activate(workspace_handle_);" "const std::string command = \"${pkgs.hyprland}/bin/hyprctl dispatch workspace \" + name_; system(command.c_str());"
        '';
      });

      inherit settings style;
    };
  };
}
