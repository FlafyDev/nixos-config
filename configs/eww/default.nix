{
  home = { ... }: {
    programs.eww = {
      enable = true;
      configDir = ./eww;
    };
  };
}
