{pkgs, lib, utils, ...}: let
  inherit (utils) domains resolveHostname;
  lan1Mask = "10.0.0.0/24";
in 
{
  networking.enable = true;

  os.networking.nftables.tables = {
    filter = {
      content = ''
        # Check out https://wiki.nftables.org/ for better documentation.
        # Table for both IPv4 and IPv6.
        # Block all incoming connections traffic except SSH and "ping".
        chain input {
          type filter hook input priority 0;
        
          # accept any localhost traffic
          iifname lo accept
        
          # accept traffic originated from us
          ct state {established, related} accept
        
          # ICMP
          # routers may also want: mld-listener-query, nd-router-solicit
          ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept
        
          # allow "ping"
          ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          ip protocol icmp icmp type echo-request accept
        
          # accept incoming ports
          tcp dport 22 accept # SSH
          ## UNUSED: 5000-5999
          ## Nextcloud Lan
          ip saddr ${lan1Mask} tcp dport 5000 accept
        
          # count and drop any other traffic
          counter drop
        }
        
        # Allow all outgoing connections.
        chain output {
          type filter hook output priority 0;
          accept
        }
        
        chain forward {
          type filter hook forward priority 0;
          accept
        }

        chain postrouting {
          type nat hook postrouting priority -100;
          
          # Forwarding incoming trafic from VPN interface to ISP networking
          iifname "vethhost0" snat ip to ${resolveHostname "mera.lan1"}
        }
      '';
      family = "inet";
    };
  };
}


