{utils, pkgs, config, ...}: let
  inherit (utils) resolveHostname domains;
in {
  os.microvm.vms.vm0.autostart = false;
  os.microvm.vms.vm0.restartIfChanged = false;

  os.environment.systemPackages = [
    config.setupVM.vms.vm0.config.config.microvm.declaredRunner
  ];

  # TODO: still not working...
  os.security.wrappers.player_binary_suid = {
    source = "${config.setupVM.vms.vm0.config.config.microvm.declaredRunner}/bin/microvm-run";
    owner = "root";
    group = "root";
    # setuid = true;
    permissions = "u+rx,g+rx,o+rx";
    capabilities = "cap_net_admin+ep";
  };

  setupVM = {
    vms = {
      vm0 = {
        gateway = null;
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
          # TODO make wine exit instantly instead of showing a crash window
          os.systemd.services.taskAndShutdown = {
            description = "Service that performs a task and then shuts down the system";

            after = [ "network.target" ];

            serviceConfig = {
              Type = "oneshot";
              ExecStart = let
                runUntilText = pkgs.writers.writePython3Bin "run_until_text" {} (builtins.readFile ./test.py);
              in pkgs.writeShellScript "bot-gd" ''
                set +e # Don't exit on error
                export WINEDLLOVERRIDES="XInput1_4.dll=n,b;mscoree=d;winemono=d;winemenubuilder.exe=d"
                export WINEDEBUG=+warn
                export WLR_BACKENDS=headless
                export WINEPREFIX=/home/vm0/geometry-dash/.wine
                export XDG_RUNTIME_DIR=/run/user/1000
                export WINARCH=win64
                mkdir -p /run/user/1000
                chown -R vm0:users /run/user/1000
                chmod -R 700 /run/user/1000
                ${pkgs.sudo}/bin/sudo -Eu vm0 env -C /home/vm0/geometry-dash ${pkgs.cage}/bin/cage ${runUntilText}/bin/run_until_text -- "fixme:dbghelp_msc:dump" "${pkgs.wineWowPackages.stable}/bin/wine" ./GeometryDash.exe
                echo Powering off...
                echo o >/proc/sysrq-trigger
                echo Done
              '';
              # RemainAfterExit = true;
              # ExecStop = "${pkgs.systemd}/bin/systemctl poweroff";
            };

            wantedBy = [ "multi-user.target" ];
          };

          os.networking.nftables.tables.allow = {
            family = "inet";
            content = ''
              chain input {
                type filter hook input priority 0; policy accept;
                meta mark set 88 # Accept all
              }
            '';
          };

          os.boot.kernelModules = [ "drm" "qxl" "bochs_drm" ];

          os.microvm.qemu.extraArgs = [
            "-device" "virtio-gpu-gl"
            "-display" "egl-headless,rendernode=/dev/dri/renderD128"
            # "-spice" "port=5902,disable-ticketing=on"
          ];

          os.environment.systemPackages = with pkgs; [
            wineWowPackages.stable
          ];

          os.microvm.shares = [
            {
              source = "/home/flafy/Games/data/windows/geometry-dash";
              mountPoint = "/home/vm0/geometry-dash";
              tag = "gd";
              proto = "9p";
            }
          ];

          os.hardware.graphics.enable = true;
          os.microvm.graphics.enable = true;
          os.microvm.mem = 1024;
          os.microvm.vcpu = 2;
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
          os.networking.nftables.tables.allow = {
            family = "inet";
            content = ''
              chain input {
                type filter hook input priority 0; policy accept;
                meta mark set 88 # Accept all
              }
            '';
          };

          # os.environment.systemPackages = [
          #   config.setupVM.vms.vm0.config.config.microvm.declaredRunner
          # ];

          # os.security.wrappers.suid_binary = {
          #   source = config.setupVM.vms.vm0.config.config.microvm.declaredRunner;
          #   owner = "root";
          #   group = "root";
          #   mode = "u+s,g+x";
          # };

          os.system.stateVersion = "23.11";
          hm.home.stateVersion = "23.11";
        };
      };
    };
  };
}
