{pkgs, ...}: {
  networking.forwardPorts."10.10.15.11".tcp = ["5000"];
  networking.forwardPorts."10.10.15.11".masquerade = true;
  networking.allowedPorts.tcp."5000" = ["*"];

  containers.testcon = {
    autoStart = true;
    extraFlags = ["--network-namespace-path=/run/netns/vpn"];
    hostAddress = "10.10.15.10";
    localAddress = "10.10.15.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = toString (pkgs.writeText "resolv.conf" ''
          nameserver 9.9.9.9
          nameserver 1.1.1.1
        '');
        isReadOnly = true;
      };
    };

    config = {
      lib,
      ...
    }: {
      services = {
        games = {
          badTimeSimulator = {
            enable = true;
            hostname = "0.0.0.0";
            port = 5000;
          };
        };
      };

      networking = {
        enable = true;
      };

      os.system.stateVersion = "23.11";
      os.networking.useHostResolvConf = lib.mkForce false;
    };
  };
}
