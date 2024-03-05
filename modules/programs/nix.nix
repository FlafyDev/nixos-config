{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let

  combinedManager = (builtins.fetchTarball {
    url = "https://github.com/flafydev/combined-manager/archive/c9cc0428a15d01417f96015f88fd874233b9cc42.tar.gz";
    sha256 = "sha256:188nwnr9vg4wwd98zm0fvwqwyraisaqqkxxlx1qm0x02pnbr904h";
  });
  cfg = config.programs.nix;
  inherit (lib) mkEnableOption mkIf mkMerge mapAttrs;
  package =
    if !cfg.cm-patch
    then inputs.nix-super.packages.${pkgs.system}.default
    else
      pkgs.nixVersions.nix_2_16.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ (
            map
            (file: "${combinedManager}/nix-patches/${file}")
            (lib.attrNames (lib.filterAttrs (_: type: type == "regular") (builtins.readDir "${combinedManager}/nix-patches")))
          );
      });
in {
  options.programs.nix = {
    enable = mkEnableOption "nix";
    patch = mkEnableOption "patch";
    cm-patch = mkEnableOption "combined-manager-patch" // {default = true;};
  };

  config = mkMerge [
    {
      inputs = {
        nix-super = {
          url = "github:privatevoid-net/nix-super";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-index-database = {
          url = "github:Mic92/nix-index-database";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    # (mkIf (cfg.enable && !cfg.cm-patch) {
    #   os.nixpkgs.overlays = [
    #     (_final: prev: {
    #       ;
    #     })
    #   ];
    # })
    # (mkIf (cfg.enable && cfg.cm-patch) {
    #   os.nixpkgs.overlays = [
    #     (_final: prev: {
    #       nix = ;
    #     })
    #   ];
    # })
    (mkIf cfg.enable {
      osModules = [
        inputs.nix-index-database.nixosModules.nix-index
      ];
      hmModules = [
        inputs.nix-index-database.hmModules.nix-index
      ];
      os.nix = {
        enable = true;
        package = mkIf cfg.patch package;

        # buildMachines = [
        #   {
        #     system = "x86_64-darwin";
        #     sshUser = "root";
        #     sshKey = "/root/.ssh/ope_to_mac";
        #     maxJobs = 4;
        #     hostName = "mac1-guest";
        #     # protocol = "ssh-ng";
        #     # supportedFeatures = ["nixos-test" "benchmark" "kvm" "big-parallel"];
        #   }
        # ];
        distributedBuilds = true;

        registry = mapAttrs (_name: value: {flake = value;}) (with inputs; {
          inherit nixpkgs;
          default = nixpkgs;
        });
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
        ];
          # builders = ssh://root@mac1-guest?ssh-key=/home/flafy/.ssh/ope_to_mac&remote-program=/nix/var/nix/profiles/default/bin/nix-store x86_64-darwin
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings = {
          auto-optimise-store = true;
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          substituters = [
            "https://nix-community.cachix.org"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      };

      os.programs.command-not-found.enable = false;
      hm.programs.nix-index.enable = true;
    })
  ];
}
