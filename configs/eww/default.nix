{ wayland }: {
  home = { pkgs, lib, ... }: let
    package = if wayland then pkgs.eww-wayland else pkgs.eww;

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
    
    scripts = with pkgs; [
      (mkPyScript {
        name = "getWorkspaces";
        dependeinces = [

        ] ++ (if wayland then [ hyprland ] else [ i3 wmctrl ]);
      })
      (mkPyScript {
        name = "getBattery";
        pythonLibraries = ps: with ps; [
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
        dependeinces = [
          package
        ] ++ (if wayland then [ hyprland ] else [ i3 systemd ]);
      })
    ];
  in {
    programs.customEww = {
      enable = true;
      package = package;
      scripts = scripts;
      assets = ./assets;
      scss = ./eww.scss;
      yuck = ./eww.yuck;
    };
  };
}

