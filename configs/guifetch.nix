{
  inputs = {
    guifetch = {
      url = "github:flafydev/guifetch";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {guifetch, ...}: {
    overlays = _: [guifetch.overlays.default];
  };

  system = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      guifetch
    ];
  };

  home = { pkgs, theme, lib, ... }: let 
    image = if theme == "Halloween" then "${pkgs.assets}/logos/nixween.png" else null;
  in {
    xdg.configFile."guifetch/guifetch.toml".text = ''
      background_color = 0x2600000F
    '' + ( if (image != null) then ''os_image = "${image}"'' else "");
  };
}
