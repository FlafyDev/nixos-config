{
  system = { pkgs, nixpkgs, ... }: {
    programs.command-not-found.enable = false;

    nix = {
      nixPath = [
        "nixpkgs=${nixpkgs}"
      ];
      # package = pkgs.nixFlakes;
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

  home = { pkgs, ... }: {
    programs.nix-index.enable = true;
  };
}
