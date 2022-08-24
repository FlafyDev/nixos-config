let 
  overlays = { ... }@inputs: [
    inputs.nur.overlay 
    inputs.npm-buildpackage.overlays.default
    inputs.hyprland.overlays.default
    (final: prev:
      let 
        inherit (prev) callPackage fetchFromGitHub;
      in {
        writers = prev.writers // {
          writePython310Bin = name: prev.writers.makePythonWriter prev.python310 prev.python310Packages "/bin/${name}";
        };
        betterdiscord-asar = callPackage ./modules/betterdiscord/asar.nix { };
        mpvScripts = prev.mpvScripts // {
          modern-x-compact = callPackage ./modules/mpv/scripts/modern-x-compact.nix { };
        };
        betterdiscordThemes = {
          solana = callPackage ./modules/betterdiscord/themes/solana.nix { };
          float = callPackage ./modules/betterdiscord/themes/float.nix { };
          frosted-glass-green = callPackage ./modules/betterdiscord/themes/frosted-glass-green { };
        };
        rofiThemes = {
          sideNavy = callPackage (import ./utils/mk-rofi-theme.nix {
            type = 3;
            style = 9;
            colorScheme = "navy";
          }) { };
        };
        webcord = inputs.webcord.packages.${prev.system}.default;
        discord-open-asar = prev.discord.override { withOpenASAR = true; };
        discord-electron-openasar = prev.callPackage ./modules/discord.nix {
          inherit (prev.discord) src version pname;
          openasar = prev.callPackage "${inputs.nixpkgs}/pkgs/applications/networking/instant-messengers/discord/openasar.nix" {};
          binaryName = "Discord";
          desktopName = "Discord";

          webRTC = true;
          enableVulkan = true;

          extraOptions = [
            "--disable-gpu-memory-buffer-video-frames"
            "--enable-accelerated-mjpeg-decode"
            "--enable-accelerated-video"
            "--enable-gpu-rasterization"
            "--enable-native-gpu-memory-buffers"
            "--enable-zero-copy"
            "--ignore-gpu-blocklist"
          ];
        };
        vimPlugins = prev.vimPlugins // {
          yuck-vim = prev.vimUtils.buildVimPluginFrom2Nix {
            pname = "yuck-vim";
            version = "2022-06-20";
            src = inputs.yuck-vim;
            meta.homepage = "https://github.com/elkowar/yuck.vim";
          };
        };
        i3-alternating-layout = callPackage ./modules/i3-alternating-layout.nix { };
        mpvpaper = callPackage ./modules/mpvpaper.nix { };
        mpv-unwrapped-stable = prev.mpv-unwrapped;
        mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs (prev: {
          version = "2022-08-21";
          src = fetchFromGitHub {
            owner = "mpv-player";
            repo = "mpv";
            rev = "37aea112c15958052bcc6d0582593edf3bfead8f";
            sha256 = "tlti/usreOBYWgTMDNsdKOL4Xa3TPeqcx9hUkLdYmN0=";
          };
        });
      }
    )
  ];
in {
  modules = { ... }@inputs: [
    inputs.hyprland.nixosModules.default
    ({ ... }: {
      nixpkgs.overlays = overlays inputs; 
    })
  ];

  homeModules = { ... }@inputs: [
    inputs.hyprland.homeManagerModules.default
    inputs.discocss.hmModule
    ./modules/mpv/hm-mpv-fonts.nix
    ./modules/betterdiscord/hm.nix
    ./modules/hm-custom-eww.nix
  ];
}
