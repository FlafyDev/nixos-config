{
  system = { pkgs, ... }: {
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };
}
