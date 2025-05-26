{pkgs, secrets, ...}: let
  customPy = pkgs.python3.withPackages (ps: with ps; [
    flask requests pyjwt waitress flask-cors
  ]);
in {
  setupVM.vms.vm0.config = {
    config.os = {
      microvm.shares = [
        {
          source = builtins.dirOf secrets.dpawn-auth.env;
          mountPoint = builtins.dirOf secrets.dpawn-auth.env;
          tag = "dpawn-auth-env";
          proto = "virtiofs";
        }
      ];
      users = {
        users.dpawnserver = {
          description = "dpawn server service user";
          createHome = false;
          # home = cfg.dataDir;
          # homeMode = "770";
          isSystemUser = true;
          group = "dpawnserver";
        };
        groups.dpawnserver = {};
      };
      systemd.services.dpawn-service = {
        after = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        startLimitIntervalSec = 60;
        description = "Start dpawn server.";
        serviceConfig = {
          Restart = "always";
          RestartSec = "10s";
          # username that systemd will look for; if it exists, it will start a service associated with that user
          User = "dpawnserver";
          EnvironmentFile = secrets.dpawn-auth.env;
          ExecStart = let
          in "${customPy}/bin/python ${./dpawn-python.py}";
        };
      };
    };
  };
}