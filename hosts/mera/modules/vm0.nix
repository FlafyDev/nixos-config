{utils, config, ...}: let
  inherit (utils) resolveHostname;
in {
  setupVM = {
    vms = {
      vm0 = {
        gateway = "vpn";
        inputRules = ''
          # Accept all packets from vm0 to host
          iifname vm0 meta mark set 88
        '';
        forwardRules = ''
          # Accept all packets from host to vm0
          oifname vm0 meta mark set 89
          # Accept all packets from vm0 to the host
          iifname vm0 meta mark set 89
        '';
        extraPrerouting = ''
          # Redirect to vm0 all tcp 80 packets the host receives
          iifname != "vm0" tcp dport 80 dnat ip to ${resolveHostname "vm.vm0"}
          iifname != "vm0" tcp dport 443 dnat ip to ${resolveHostname "vm.vm0"}
        '';
        config = {
          os.networking.nftables.tables.allow = {
            family = "inet";
            content = ''
              chain input {
                type filter hook input priority 0; policy accept;
                meta mark set 88 # Accept all
              }
            '';
          };

          os.microvm.mem = 1024; # 1024 MB
          os.microvm.vcpu = 2;
          os.system.stateVersion = "23.11";
          hm.home.stateVersion = "23.11";
        };
      };
    };
  };
}
