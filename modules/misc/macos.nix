{
  inputs,
  lib,
  config,
  pkgs,
  ssh,
  ...
}:
with lib; let
  cfg = config.assets;
in {
  options.macos = {
    key = mkOption {
      type = types.any;
      description = "The key to ssh login to the root user. Needs .public and .private";
    };
    enable = mkEnableOption "macos";
  };

  config = mkMerge [
    {
      inputs = {
        nixtheplanet.url = "github:matthewcroughan/nixtheplanet";
      };
    }
    (
      mkIf cfg.enable {
        osModules = [inputs.nixtheplanet.nixosModules.macos-ventura];

        os = {
          nix.buildMachines = [
            {
              system = "x86_64-darwin";
              sshKey = ssh.ope.ope_to_mac.private;
              maxJobs = 4;
              hostName = "mac?remote-program=/nix/var/nix/profiles/default/bin/nix-store";
            }
          ];
          programs.ssh.extraConfig = ''
            Host mac
              Hostname 127.0.0.1
              Port 2222
              Compression yes
              User root
              StrictHostKeyChecking no
          '';
          # services.macos-ventura = {
          #   enable = true;
          #   openFirewall = false;
          #   vncListenAddr = "0.0.0.0";
          #   sshPort = 2222;
          #   stateless = false; # Installs nix downloads slowly. Also may want to start and stop the vm quickly
          #   vncDisplayNumber = 2;
          #   autoStart = false;
          #   # extraQemuFlags = ["-nographic"];
          #   package = inputs.nixtheplanet.legacyPackages.${pkgs.system}.makeDarwinImage { diskSizeBytes = 80000000000; };
          # };
          # systemd.services.macos-ventura = {
          #   serviceConfig.TimeoutStartSec = 300;
          #   # TODO: change pub key
          #   postStart = let
          #     sudo-mac-script = pkgs.writeShellScript "sudo-mac-script" ''
          #       echo "admin" | sudo -S bash -c "
          #       $(cat <<'EOF'
          #         if [ ! -e "/nix/var/nix/profiles/default/bin/nix-store" ]; then
          #             sh <(curl -L https://nixos.org/nix/install)
          #         fi
          #         if [ ! -e "/var/root/.ssh/authorized_keys" ]; then
          #           sed -i ''' 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config || true
          #           mkdir -p /var/root/.ssh
          #           echo "${builtins.readFile ssh.ope.ope_to_mac.public}" > /var/root/.ssh/authorized_keys
          #           launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
          #           launchctl load -w /System/Library/LaunchDaemons/ssh.plist
          #         fi
          #       EOF
          #       )"
          #     '';
          #   in
          #     lib.mkAfter ''
          #       sleep 3
          #       ${pkgs.sshpass}/bin/sshpass -p admin ${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=no -p 2222 admin@127.0.0.1 'bash -s' < ${sudo-mac-script}
          #     '';
          # };
        };
      }
    )
  ];
}
