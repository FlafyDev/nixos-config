{pkgs, lib, ...}:

{
#   os.networking.nftables = {
#     enable = true;
#     tables = lib.mkForce {};
#     ruleset = lib.mkForce ''
#
#
# # Create the inet table
# table inet filter {
#     # Create chains for input, output, and forward
#     chain input {
#         type filter hook input priority 0; policy accept;
#
#         # Accept established and related connections
#         ct state established,related accept
#
#         # Accept traffic from the WireGuard interface
#         iifname "wg_vps" accept
#
#         # Allow ICMP (ping) for diagnostics
#         ip protocol icmp accept
#         ip6 nexthdr icmpv6 accept
#
#         accept
#     }
#
#     chain output {
#         type filter hook output priority 0; policy accept;
#
#         # Accept established and related connections
#         ct state established,related accept
#
#         # Allow traffic to the WireGuard interface
#         oifname "wg_vps" accept
#
#         accept
#     }
#
#     chain forward {
#         type filter hook forward priority 0; policy drop;
#
#         # Allow forwarding from wg_vps to the local network and vice versa
#         iifname "wg_vps" accept
#         oifname "wg_vps" accept
#
#         # Allow forwarding for established and related connections
#         ct state established,related accept
#     }
# }
#
# # Create the NAT table for IP masquerading
# table inet nat {
#     chain postrouting {
#         type nat hook postrouting priority 100; policy accept;
#
#         # Masquerade for IPv4
#         ip saddr 10.10.10.0/24 oifname "wg_vps" masquerade
#         # Masquerade for IPv6 (if using an IPv6 address range)
#         # Replace <your-ipv6-prefix> with your actual prefix
#         # ip6 saddr <your-ipv6-prefix>::/64 oifname "wg_vps" masquerade
#     }
# }
#
#       # table inet allow_ports {
#       #   chain input {
#       #     type filter hook input priority 0; policy drop;
#       #
#       #     # accept all loopback packets
#       #     iif "lo" accept
#       #     # accept all icmp/icmpv6 packets
#       #     meta l4proto { icmp, ipv6-icmp } accept
#       #     # accept all packets that are part of an already-established connection
#       #     ct state vmap { invalid : drop, established : accept, related : accept }
#       #     # drop new connections over rate limit
#       #     ct state new limit rate over 1/second burst 10 packets drop
#       #
#       #     # accept all DHCPv6 packets received at a link-local address
#       #     ip6 daddr fe80::/64 udp dport dhcpv6-client accept
#       #
#       #     # accept all SSH packets received on a public interface
#       #     tcp dport 22 accept
#       #
#       #     # accept all WireGuard packets received on a public interface
#       #     udp dport 51820 accept
#       #
#       #     # reject with polite "port unreachable" icmp response
#       #     reject
#       #   }
#       #
#       #   chain forward {
#       #     # forward all icmp/icmpv6 packets
#       #     meta l4proto { icmp, ipv6-icmp } accept
#       #
#       #     # forward all HTTP packets for Endpoint B
#       #     ip daddr 192.168.200.22 tcp dport http accept
#       #
#       #     # reject with polite "administratively prohibited" icmp response
#       #     reject with icmpx type admin-prohibited
#       #   }
#       # }
#
#       # table inet forward_ports {
#       #   chain prerouting {
#       #     type nat hook prerouting priority 0 ;
#       #
#       #     tcp dport 4444 dnat ip to 10.10.15.11:22
#       #     tcp dport 47984 dnat ip to 10.10.15.11:47984
#       #     tcp dport 47989 dnat ip to 10.10.15.11:47989
#       #     tcp dport 48010 dnat ip to 10.10.15.11:48010
#       #     tcp dport 47990 dnat ip to 10.10.15.11:47990
#       #     tcp dport 5557 dnat ip to 10.10.15.11:5557
#       #     tcp dport 51797 dnat ip to 10.10.15.11:51797
#       #     udp dport 47998-48000 dnat ip to 10.10.15.11:47998-48000
#       #     udp dport 48002 dnat ip to 10.10.15.11:48002
#       #     udp dport 48010 dnat ip to 10.10.15.11:48010
#       #     udp dport 51797 dnat ip to 10.10.15.11:51797
#       #     tcp dport 5556 dnat ip to 127.0.0.1:5556
#       #   }
#       #
#       #   chain postrouting {
#       #     type nat hook postrouting priority 100 ;
#       #
#       #     ip daddr 10.10.15.11 masquerade
#       #     ip daddr 127.0.0.1 masquerade
#       #   }
#       # }
#
#       # table inet nixos-fw {
#       #   chain rpfilter {
#       #     type filter hook prerouting priority mangle + 10; policy drop;
#       #
#       #     meta nfproto ipv4 udp sport . udp dport { 67 . 68, 68 . 67 } accept comment "DHCPv4 client/server"
#       #     fib saddr . mark . iif oif exists accept
#       #
#       #     jump rpfilter-allow
#       #   }
#       #
#       #   chain rpfilter-allow {
#       #     
#       #   }
#       #
#       #   chain input {
#       #     type filter hook input priority filter; policy drop;
#       #
#       #     iifname { "waydroid0", "lo" } accept comment "trusted interfaces"
#       #
#       #     # Some ICMPv6 types like NDP is untracked
#       #     ct state vmap {
#       #       invalid : drop,
#       #       established : accept,
#       #       related : accept,
#       #       new : jump input-allow,
#       #       untracked: jump input-allow,
#       #     }
#       #
#       #     tcp flags syn / fin,syn,rst,ack log level info prefix "refused connection: "
#       #   }
#       #
#       #   chain input-allow {
#       #     tcp dport { 22, 631, 1-65535 } accept
#       #     udp dport { 631, 5353, 1-65535 } accept
#       #
#       #
#       #     icmp type echo-request  accept comment "allow ping"
#       #
#       #
#       #     icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
#       #     ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"
#       #   }
#       # }
#     '';
#   };
}

