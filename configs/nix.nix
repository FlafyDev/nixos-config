{
  system = {
    pkgs,
    nixpkgs,
    ...
  }: {
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
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
        substituters = [
          "https://hyprland.cachix.org"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };

  home = {pkgs, ...}: {
    programs.nix-index.enable = true;
  };
}
