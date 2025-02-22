{...}: {
  networking.setupVM = {
    enable = true;
    vms = {
      vm0 = {
        gateway = "vps";
        inputRules = ''
          # Accept all incoming(to this PC) packets from the VM
          iifname vm0 meta mark set 88
        '';
        forwardRules = ''
          # Accept all incoming packets to the VM
          oifname vm0 meta mark set 89
          # Accept all outgoing packets from the VM
          iifname vm0 meta mark set 89
        '';
        extraPrerouting = ''
          tcp dport 8080 dnat ip to 10.10.15.2
        '';
      };
    };
  };
}
