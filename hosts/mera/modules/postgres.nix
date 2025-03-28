{config, ...}: {
  # os.environment.persistence = {
  #   "/persist2" = {
  #     directories = [
  #       {
  #         directory = "/var/lib/postgresql";
  #         user = "root";
  #         group = "root";
  #       }
  #     ];
  #   };
  # };

  services.postgres = {
    enable = true;
    dataDir = "/persist2/var/lib/postgresql";
  };

  services.postgres.comb = config.setupVM.vms.vm0.config.config.cmConfig.services.postgres.comb;
  services.postgres.extraSql = config.setupVM.vms.vm0.config.config.cmConfig.services.postgres.extraSql;
}
