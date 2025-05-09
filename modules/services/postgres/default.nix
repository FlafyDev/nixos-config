{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}: let
  inherit
    (lib)
    types
    mkOption
    mkEnableOption
    mkForce
    mkIf
    mapAttrsToList
    concatStringsSep
    filterAttrs
    optionalString
    mkAfter
    ;

  cfg = config.services.postgres;

  combType = types.attrsOf (types.submodule {
    options = {
      networkTrusted = mkOption {
        type = types.bool;
        description = "Whether this combination needs to be able to connect over the network";
        default = false;
      };
      extraSql = mkOption {
        type = types.lines;
        description = "Extra SQL commands to run every DB start";
        default = "";
      };
      initSql = mkOption {
        type = types.lines;
        description = "Extra SQL commands to run on the first DB start";
        default = "";
      };
      autoCreate = mkOption {
        type = types.bool;
        default = true;
        description = "If enabled, this instructs NixOS to auto-create the database";
      };
    };
  });
in {
  options.services.postgres = {
    enable = mkEnableOption "Postgres database";

    dataDir = mkOption {
      type = types.str;
      description = "Where to save the database";
      default = "/var/lib/postgresql";
    };

    extraSql = mkOption {
      type = types.lines;
      description = "Extra SQL commands to run every DB start";
      default = "";
    };
    comb = mkOption {
      type = combType;
      description = "postgres user-database combination configuration";
      default = {};
    };
  };

  config = mkIf cfg.enable {
    # networking.allowedPorts.tcp."5432" = ["*"];
    os.services.postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      dataDir = "${cfg.dataDir}/${osConfig.services.postgresql.package.psqlSchema}";
      enableTCPIP = true;
      port = 5432;
      authentication = ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all 10.0.0.0/24 trust
        host all all 10.10.15.0/24 trust
      '';

      # ensureDatabases =
      #   mapAttrsToList (name: _value: name)
      #   (filterAttrs (_name: value: value.autoCreate) cfg.comb);
      # ensureUsers =
      #   mapAttrsToList (name: _value: {
      #     inherit name;
      #     ensurePermissions = {"DATABASE ${name}" = "ALL PRIVILEGES";};
      #   })
      #   cfg.comb;
      #
      # # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      # authentication = mkForce ''
      #   local all all trust
      #   ${concatStringsSep "\n" (mapAttrsToList (name: value: (optionalString value.networkTrusted
      #     "host ${name} ${name} 127.0.0.1/32 trust"))
      #   cfg.comb)}
      # '';

      initialScript =
        pkgs.writeText "custom-postgres-init.sql"
        (concatStringsSep "\n"
          (mapAttrsToList (_name: value: value.initSql) cfg.comb));
    };

    # os.systemd.services.postgresql.postStart = mkAfter ''
    #   ${concatStringsSep "\n" (mapAttrsToList (name: value: "$PSQL -tAf ${
    #     pkgs.writeText "${name}-custom-postgres-init.sql" ''
    #       \c ${name};
    #       ${value.extraSql}
    #     ''
    #   }") (filterAttrs (_name: value: value.extraSql != "") cfg.comb))}
    # '';
  };
}
