{inputs, ...}: {
  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  osModules = [inputs.microvm.nixosModules.host];

  # os.systemd.services."microvm-tap-interfaces@test-microvm.service" = {
  #   # set network namespace
  #   serviceConfig = {
  #     NetworkNamespacePath = "vpn";
  #   };
  # };


  os.systemd.network.networks."10-lan" = {
    matchConfig.Name = ["enp14s0" "vm-*"];
    networkConfig = {
      Bridge = "br0";
    };
  };

  os.systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  os.systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["10.0.0.42/24"];
      Gateway = "10.0.0.138";
      DNS = ["10.0.0.138"];
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };


  os.microvm = {
    # host.useNotifySockets = true;
    vms.test-microvm = {
      autostart = true;
      restartIfChanged = true;
      config = {
        users.users.root = {
          group = "root";
          password = "itsfine";
          isSystemUser = true;
        };

        services.openssh = {
          enable = true;
          startWhenNeeded = true;
          settings.PermitRootLogin = "yes";
        };
        # systemd.sockets.sshd = {
        #   socketConfig = {
        #     ListenStream = [
        #       "vsock:1337:22"
        #     ];
        #   };
        # };
        systemd.network.enable = true;
        networking.useNetworkd = false;
        networking.firewall.enable = false;

        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            Address = ["10.0.0.11/24"];
            Gateway = "10.0.0.138";
            DNS = ["10.0.0.138"];
            IPv6AcceptRA = true;
            DHCP = "no";
          };
        };

        microvm = {
          # vsock.cid = 1337;
          interfaces = [ 
            {
              type = "tap";
              id = "vm-test1";
              mac = "02:00:00:00:00:01";
            }
          #   {
          #   type = "tap";
          #
          #   # interface name on the host
          #   id = "vm-a1";
          #
          #   # Ethernet address of the MicroVM's interface, not the host's
          #   #
          #   # Locally administered have one of 2/6/A/E in the second nibble.
          #   mac = "02:00:00:00:00:01";
          # }
          ]; 
          shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];
        };
      };
    };
  };
}
