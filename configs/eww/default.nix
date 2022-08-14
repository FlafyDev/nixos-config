{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      wmctrl
    ];
    programs.eww = {
      enable = true;
      configDir = ./eww;
    };
  };
}
