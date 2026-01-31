{...}: {
  setupGroups.groups."0" = {
    gateway = "vpn";
    helpers.microvm = "vm0";
    inputRules = {interface, ...}: ''
      # Accept all packets from gp0 to host
      iifname ${interface} meta mark set 88
    '';
    forwardRules = {interface, ...}: ''
      # Accept all packets from host to gp0
      oifname ${interface} meta mark set 89
      # Accept all packets from gp0 to the host
      iifname ${interface} meta mark set 89
    '';
    extraPrerouting = {interface, ips}: ''
      # Redirect to gp0 all tcp 80 packets the host receives
      iifname wg_vps tcp dport 80 dnat ip to ${ips.guest}
      iifname wg_vps tcp dport 443 dnat ip to ${ips.guest}
    '';
  };

  microvm = {
    enable = false;
    vms = {
      vm0 = {
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

          os.microvm.mem = 4096; # 4096 MB
          os.microvm.vcpu = 2;
          os.system.stateVersion = "23.11";
          hm.home.stateVersion = "23.11";
        };
      };
    };
  };
}
