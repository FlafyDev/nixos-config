{
  ...
}: let
in {
  os.services.minio = {
    enable = true;
    dataDir = ["/persist2/var/lib/minio/data"];
    accessKey = "root";
    secretKey = "rootpassword";
    listenAddress = ":9002";
  };
}
