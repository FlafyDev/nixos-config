{
  system = { pkgs, nixpkgs, ... }: {
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
}
