modules:

{
  system = "x86_64-linux";
  modules = [
    {
      imports = [
        ../../nixpkgs.nix
        ./hardware-configuration.nix
        ./system.nix
        ../../system-configs/nix.nix
      ];
    }
  ] ++ modules;
}
