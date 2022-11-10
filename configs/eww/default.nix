{
  add = _: {
    homeModules = [./hm-custom-eww.nix];
  };

  home = {
    pkgs,
    lib,
    ...
  }: let
    package = pkgs.eww-wayland;

    mkPyScript = {
      name,
      pythonLibraries ? (_ps: []),
      dependeinces ? [],
      isolate ? true,
    }:
      pkgs.stdenv.mkDerivation {
        inherit name;
        buildInputs = [
          pkgs.makeWrapper
          (pkgs.python310.withPackages pythonLibraries)
        ];
        unpackPhase = "true";
        installPhase = let
          wrap =
            if isolate
            then "wrapProgram $out/bin/${name} --set PATH ${lib.makeBinPath dependeinces}"
            else "wrapProgram $out/bin/${name} --suffix PATH : ${lib.makeBinPath dependeinces}";
        in ''
          mkdir -p $out/bin
          cp ${./scripts + "/${name}.py"} $out/bin/${name}
          chmod +x $out/bin/${name}
          ${wrap}
        '';
      };

    dependencies = with pkgs; [
      coreutils
      bash
      (mkPyScript {
        name = "getWorkspaces";
        isolate = false;
        dependeinces = [
          wmctrl
        ];
      })
      (mkPyScript {
        name = "getBattery";
        pythonLibraries = ps:
          with ps; [
            psutil
          ];
      })
      (mkPyScript {
        name = "volume";
        dependeinces = [
          pamixer
          pulsemixer
          pulseaudio
        ];
      })
      (mkPyScript {
        name = "saveBattery";
        isolate = false;
        dependeinces = [
          package
        ];
      })
    ];
  in {
    programs.customEww = {
      enable = true;
      inherit package dependencies;
      assets = ./assets;
      scss = ./eww.scss;
      yuck = ./eww.yuck;
    };
  };
}
