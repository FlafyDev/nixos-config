{
  home = { pkgs, ... }: with pkgs; let
    mkPyScript = { name, pythonLibraries ? (ps: []), dependeinces ? [] }:
      pkgs.stdenv.mkDerivation {
        name = name;
        buildInputs = [(pkgs.python310.withPackages pythonLibraries)] ++ dependeinces;
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp ${./scripts + "/${name}.py"} $out/bin/${name}
          chmod +x $out/bin/${name}
        '';
      };
    
    scripts = [
      (mkPyScript {
        name = "getWorkspaces";
      })
    ];

    yuck = callPackage ({ stdenv, lib, fetchFromGitHub }:
      stdenv.mkDerivation rec {
        name = "eww.yuck";
        unpackPhase = "true";
        installPhase = ''
          cp ${./eww.yuck} $out
        '';
      }) { };
  in {
    programs.customEww = {
      enable = true;
      package = writeShellScriptBin "eww" ''
        PATH="$PATH:${lib.makeBinPath scripts}"
        exec ${eww-wayland}/bin/eww "$@"
      '';
      scss = ./eww.scss;
      yuck = yuck;
    };
  };
}

