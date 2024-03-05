{
  buildGo120Module,
  fetchFromGitHub,
  olm,
}:
buildGo120Module rec {
  pname = "mautrix-gmessages";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "gmessages";
    rev = "v${version}";
    hash = "sha256-xKOHJU2QBdzdjeXGTk+WCF7JteknVhIgfyRyQP+oy8Y=";
  };

  buildInputs = [olm];

  vendorHash = "sha256-n766FoR2QJaKpaohz66948Mp0ZUu9O68EMzhXyAhA5o=";

  excludedPackages = ["./libgm"];

  doCheck = false;
}
