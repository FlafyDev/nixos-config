{
  inputs = {
    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {kmonad, ...}: {
    modules = [kmonad.nixosModules.default];
  };

  system = _: {
    nix.settings = {
      trusted-public-keys = [
        "static-haskell-nix.cachix.org-1:Q17HawmAwaM1/BfIxaEDKAxwTOyRVhPG5Ji9K3+FvUU="
      ];
      substituters = [
        "https://static-haskell-nix.cachix.org"
      ];
    };

    services.kmonad = {
      enable = true;
      keyboards = {
        kb-hyperx = {
          device = "/dev/input/by-id/usb-HyperX_Alloy_Elite_HyperX_Alloy_Elite-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = false;
            allowCommands = false;
          };
          config = builtins.readFile ./main.kbd;
        };
        kb-laptop = {
          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = false;
            allowCommands = false;
          };
          config = builtins.readFile ./main.kbd;
        };
      };
    };
  };
}
