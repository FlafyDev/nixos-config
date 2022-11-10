{
  fetchFromGitHub,
  python310Packages,
}:
with python310Packages;
  buildPythonPackage rec {
    pname = "i3-alternating-layout";
    version = "2022-08-14";

    src = fetchFromGitHub {
      owner = "olemartinorg";
      repo = pname;
      rev = "a0d49f3aaccb3ee222c91a1dffbf418e5b628684";
      sha256 = "d5POf2M16frGT8RzhC2YBhv2PgImo8djra0zJGtBVmE=";
    };

    preBuild = ''
      cat >setup.py <<'EOF'
      from setuptools import setup
      setup(
        name="i3-alternating-layout",
        scripts=[
          "alternating_layouts.py",
        ],
        install_requires=[
          "i3ipc"
        ],
      )
      EOF
    '';

    postInstall = ''
      mv -v $out/bin/alternating_layouts.py $out/bin/i3-alternating-layout
    '';

    propagatedBuildInputs = [i3ipc];
  }
