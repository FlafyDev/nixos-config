{
  home = _: {
    programs.helix = {
      enable = true;
      settings = {
        keys = {
          normal = {
            C-s = ":w";
          };
        };

        editor = {
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
        };
      };
    };
  };
}
