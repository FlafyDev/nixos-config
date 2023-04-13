{
  inputs = {
    nixpkgs-gimp.url = "github:jtojnar/nixpkgs/gimp-meson";
    guifetch.url = "github:flafydev/guifetch";
    listen-blue.url = "github:flafydev/listen_blue";
    webcord.url = "github:SpacingBat3/webcord";
    webcord.flake = false;
  };

  add = {
    nixpkgs-gimp,
    guifetch,
    listen-blue,
    webcord,
    ...
  }: {
    overlays = _: [
      guifetch.overlays.default
      listen-blue.overlays.default
      (_final: prev: let
        pkgs = import nixpkgs-gimp {
          inherit (prev) system;
        };
      in {
        gimp-dev = pkgs.gimp;
        webcord = let
          src = webcord;
          # Because fetchzip is dumb and doesn't recognize the crx as zip.
          vencordExtension =
            prev.runCommand "vencord-extension" {
              # I don't know how reproducible the url is...
              VENCORD_CRX_URL = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=109.0&x=id%3Dcbghhgpcnddeihccjmnadmkaejncjndb%26installsource%3Dondemand%26uc";
              sha256 = prev.lib.fakeHash;
              outputHash = "sha256-lovKwzBa4IMKDZ4TR6lv9pzWV7Vjm1FXG8ZRv4dZ9IM=";
              outputHashAlgo = "sha256";
              outputHashMode = "recursive";
              nativeBuildInputs = with prev; [curl p7zip];
              downloadToTemp = false;
            } ''
              export TEMP="$(mktemp -d)"
              curl -k "$VENCORD_CRX_URL" -L -o vencord.crx
              mkdir -p "$out"
              7z x vencord.crx -o"$out" -y
              rm -rf "$out/_metadata"
            '';
        in
          prev.webcord.overrideAttrs (old: {
            inherit src;
            version = "git";
            patchPhase = ''
              runHook prePatch
              sed -i "361i session.defaultSession.loadExtension(\"${vencordExtension}\").then(() => console.log(\"Vencord loaded.\"));" "sources/code/common/main.ts"
              sed -i "4i \ \ \ \ \ \ \ \ \"ignoreDeprecations\": \"5.0\"," "tsconfig.json"
              runHook postPatch
            '';
            npmDeps = old.npmDeps.overrideAttrs (_old: {
              inherit src;
              outputHash = "sha256-Svkv6RiJrteCsZOn4prUMYguc4cuCktlCxb5yq63Fzw=";
            });
          });
      })
    ];
  };

  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      gnome.eog
      # guifetch
      # listen-blue
      mate.engrampa
      cinnamon.nemo.out
      # gnome.nautilus
      scrcpy
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      gnome.gnome-font-viewer
      # libreoffice
      krita
      libsForQt5.kdenlive
      gparted
      qdirstat
      pavucontrol
      obs-studio
      lxde.lxrandr
      gimp-dev
      webcord
      element-desktop
      lutris
      android-studio
      prismlauncher
    ];
  };
}
