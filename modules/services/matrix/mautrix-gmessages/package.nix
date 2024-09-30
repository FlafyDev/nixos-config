{
  buildGo123Module,
  fetchFromGitHub,
  olm,
}:
buildGo123Module rec {
  pname = "mautrix-gmessages";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "gmessages";
    rev = "v${version}";
    hash = "sha256-Qh5jlvHOEtEt1IKfSYQsSWzfCrCoo8zVDCZDUZlPKEw=";
  };

  buildInputs = [olm];

  vendorHash = "sha256-VA+PC7TCEGTXG9yRcroPIVQlA5lzq9GlNRgMNPWTMSg=";

  excludedPackages = ["./libgm"];

  doCheck = false;
}
