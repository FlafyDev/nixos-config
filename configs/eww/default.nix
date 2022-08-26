{
  home = { pkgs, lib, ... }: let
    mkPyScript = { name, pythonLibraries ? (ps: []), dependeinces ? [] }:
      pkgs.stdenv.mkDerivation {
        name = name;
        buildInputs = [
          pkgs.makeWrapper
          (pkgs.python310.withPackages pythonLibraries)
        ];
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp ${./scripts + "/${name}.py"} $out/bin/${name}
          chmod +x $out/bin/${name}
          wrapProgram $out/bin/${name} --set PATH ${lib.makeBinPath dependeinces}
        '';
      };
    
    scripts = [
      (mkPyScript {
        name = "getWorkspaces";
        dependeinces = [
          pkgs.hyprland
        ];
      })
      (mkPyScript {
        name = "getBattery";
        pythonLibraries = ps: with ps; [
          psutil
        ];
      })
      (mkPyScript {
        name = "volume";
        dependeinces = with pkgs; [
          pamixer 
          pulsemixer
          pulseaudio
        ];
      })
    ];
  in {
    programs.customEww = {
      enable = true;
      package = pkgs.eww-wayland;
      scripts = scripts;
      assets = ./assets;
      scss = ./eww.scss;
      yuck = ./eww.yuck;
    };
  };
}

