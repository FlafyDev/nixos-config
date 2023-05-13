{
  inputs = {
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {
    nix-doom-emacs,
    emacs-overlay,
    ...
  }: {
    homeModules = [nix-doom-emacs.hmModule];
    overlays = _: [
      emacs-overlay.overlays.emacs
      #   (final: prev: {
      #     nix-doom-emacs = nix-doom-emacs.packages.${final.system}.default;
      #   })
    ];
  };

  # system = {pkgs, ...}: {
  # environment.systemPackages = with pkgs; [
  #   nix-doom-emacs
  # ];
  # };

  home = {
    pkgs,
    inputs,
    ...
  }: {
    programs.doom-emacs = {
      enable = true;
      # emacsPackage = pkgs.emacsPgtk;
      emacsPackage = pkgs.emacs;
      doomPrivateDir = ./doom.d;
      # doomPrivateDir = toString (pkgs.linkFarm "my-doom-packages" [
      #   # straight needs a (possibly empty) `config.el` file to build
      #   {
      #     name = "config.el";
      #     path = pkgs.emptyFile;
      #   }
      #   {
      #     name = "init.el";
      #     path = ./doom.d/init.el;
      #   }
      #   {
      #     name = "packages.el";
      #     path = pkgs.writeText "(package! inheritenv)";
      #   }
      #   # {
      #   #   name = "modules";
      #   #   path = ./my-doom-module;
      #   # }
      # ]);
    };
    # home.packages = with pkgs; [
    #   emacsPgtk
    # ];
    # doomPrivateDir
  };
}
