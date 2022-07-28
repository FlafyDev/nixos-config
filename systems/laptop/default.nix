modules:

{
  system = "x86_64-linux";
  modules = [
    {
      imports = [
        ./hardware-configuration.nix
        ./system.nix
      ];
    }
  ] ++ modules;
}
