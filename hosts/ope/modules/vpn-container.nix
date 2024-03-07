{pkgs, ...}: {
  #
  # # Mane
  # networking.forwardPorts.${utils.resolveHostname "ope.wg_vps"} = {
  #   tcp = ["5000"];
  #   masquerade = false;
  # };
  # networking.allowedPorts.tcp."5000" = ["0.0.0.0"];

  # This
  # networking.forwardPorts."10.10.15.11".tcp = ["5000"];

  #  # Lan
  #   networking.allowedPorts.tcp."5000" = [(resolveHost "ope.lan1")];
  #   networking.forwardPorts."10.10.15.11".masquerade = true;

  # Wireguard
  # os.networking.wireguard.interfaces.wg_vps =  let
  #   ip = "${pkgs.iproute2}/bin/ip";
  # in {
  #   interfaceNamespace = "vpn";
  #   socketNamespace = "init";
  #   preSetup = ''
  #     ${ip} netns add vpn || true
  #
  #     ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
  #     ${ip} link set vethvpn0 netns vpn || true
  #     ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
  #     ${ip} netns exec vpn ip addr add 10.10.15.11/24 dev vethvpn0 || true
  #     ${ip} link set vethhost0 up || true
  #     ${ip} netns exec vpn ip link set vethvpn0 up || true
  #   '';
  # }

  # Creates the namespace instead of wireguard doing it.
  networking.vpnNamespace = {
    vpn = {
      container = "maneVpn"; # Sets its network namespace and gets the IP address from the container localAddress
      vpnHost = "mane";
      vpnWgInterface = "wg_vps"; # Gets ip from ope.wg_vps and sets wireguard preSetup.
      lanForward = true;
      ports = {
        tcp = ["5000"];
        udp = ["5000"];
      };
    };
  };

  containers.maneVpn = {
    autoStart = true;
    # extraFlags = ["--network-namespace-path=/run/netns/vpn"];
    # hostAddress = "10.10.15.10";
    # localAddress = "10.10.15.11";

    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = toString (pkgs.writeText "resolv.conf" ''
          nameserver 9.9.9.9
          nameserver 1.1.1.1
        '');
        isReadOnly = true;
      };
    };

    config = {lib, ...}: {
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
