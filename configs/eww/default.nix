{ wayland }: {
  home = { pkgs, lib, ... }:
    let
      package = if wayland then pkgs.eww-wayland else pkgs.eww;

      mkPyScript = { name, pythonLibraries ? (ps: [ ]), dependeinces ? [ ], isolate ? true }:
        pkgs.stdenv.mkDerivation {
          name = name;
          buildInputs = [
            pkgs.makeWrapper
            (pkgs.python310.withPackages pythonLibraries)
          ];
          unpackPhase = "true";
          installPhase =
            let
              wrap =
                if isolate
                then "wrapProgram $out/bin/${name} --set PATH ${lib.makeBinPath dependeinces}"
                else "wrapProgram $out/bin/${name} --suffix PATH : ${lib.makeBinPath dependeinces}";
            in
            ''
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
          dependeinces = if wayland then [ ] else [ wmctrl ];
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
          isolate = false;
          dependeinces = [
            package
          ];
        })
      ];
    in
    {
      programs.customEww = {
        enable = true;
        package = package;
        dependencies = dependencies;
        assets = ./assets;
        scss = ./eww.scss;
        yuck = ./eww.yuck;
      };
    };
}

