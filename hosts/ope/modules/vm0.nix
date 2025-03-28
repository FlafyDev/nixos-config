{utils, ...}: let
  inherit (utils) resolveHostname domains;
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
          # # Redirect to vm0 all tcp 8080 packets the host receives
          # tcp dport 8080 dnat ip to ${resolveHostname "vm.vm0"}
        '';
        config = {
          os.system.stateVersion = "23.11";
          hm.home.stateVersion = "23.11";
        };
      };
      vm1 = {
        gateway = "home";
        inputRules = ''
          # Accept all packets from vm1 to host
          iifname vm1 meta mark set 88
        '';
        forwardRules = ''
          # Accept all packets from host to vm1
          oifname vm1 meta mark set 89
          # Accept all packets from vm1 to the host
          iifname vm1 meta mark set 89
        '';
        config = {
          os.system.stateVersion = "23.11";
          hm.home.stateVersion = "23.11";
        };
      };
    };
  };
}
