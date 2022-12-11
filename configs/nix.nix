{
  inputs.nix = {
    url = "github:flafydev/nix";
  };

  add = {nix, ...}: {
    overlays = _: [
      (_final: prev: {
        nix = nix.packages.${prev.system}.default;
      })
    ];
  };

  system = {nixpkgs, ...}: {
    programs.command-not-found.enable = false;

    nix = {
      registry.nixpkgs.flake = nixpkgs;
      nixPath = [
        "nixpkgs=${nixpkgs}"
      ];
      # package = pkgs.nix.overrideAttrs(o: {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "flafydev";
      #     repo = "nix";
      #     rev = "882995b9c5d8214646d4cee884b7fa2ee8375cc7";
      #     sha256 = "sha256-ryB/fIr6uJNCrgAWQuS3PIogfRoDMcZ3UykOFDLMAlg=";
      #   };
      # });
      # package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        substituters = [
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };

  home = _: {
    programs.nix-index.enable = true;
  };
}
