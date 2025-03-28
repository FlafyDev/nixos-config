{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.fonts;
  inherit (lib) mkEnableOption mkIf;
in {
  options.fonts = {
    enable = mkEnableOption "fonts";
  };

  config = let
    fonts = with pkgs; [
      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code

      (pkgs.runCommand "rubik-doodle-shadow-font" {
        FONT = fetchurl {
          url = "https://fonts.gstatic.com/s/rubikdoodletriangles/v1/esDA301BLOmMKxKspb3g-domRuLPeaSn2bTzdLi_slZxgWE.ttf";
          sha256 = "sha256-WoyQnayNmllIEM9UVdvOm2RqI1iVhacNyHg0yXDM1tw=";
        };
      } ''
        mkdir -p $out/share/fonts/truetype
        cp $FONT $out/share/fonts/truetype
      '')

      (pkgs.runCommand "rubik-doodle-shadow-font" {
        FONT = fetchurl {
          url = "https://fonts.gstatic.com/s/rubikdoodleshadow/v1/rP2bp3im_k8G_wTVdvvMdHqmXTR3lEaLyKuZ3KOY7Gw.ttf";
          sha256 = "sha256-mQMvOvo6Dqf43JXox+FUjnY72vhtQQNnh8foZn0x4DQ=";
        };
      } ''
        mkdir -p $out/share/fonts/truetype
        cp $FONT $out/share/fonts/truetype
      '')
      # carlito
      # corefonts
      # source-sans
      # # cantarell-fonts
      # dejavu_fonts
      # source-code-pro # Default monospace font in 3.32
      # source-sans
      maple-mono
      google-fonts
      # noto-fonts
      # noto-fonts-cjk
      # noto-fonts-emoji
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # # dina-font
      # proggyfonts
      # material-icons
      # material-design-icons
      # roboto
      # work-sans
      # comic-neue
      # twemoji-color-font
      # comfortaa
      # inter
      # lato
      # jost
      # lexend
      # iosevka-bin
      # jetbrains-mono
    ];
  in
    mkIf cfg.enable {
      unfree.allowed = ["corefonts"];
      os.fonts = {
        fontDir.enable = true;
        packages = fonts;
      };
      hm.home.packages = fonts;
      hm.fonts.fontconfig.enable = true;
    };
}
