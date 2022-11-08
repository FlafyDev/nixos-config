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
    services.kmonad = {
      enable = true;
      keyboards = {
        kb = {
          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = true;
            allowCommands = false;
          };
          config = builtins.readFile ./main.kbd;
        };
      };
    };
  };
}
