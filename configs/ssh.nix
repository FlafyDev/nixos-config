{ username ? "flafy" }: let 
  sshPath = "/secrets/ssh/${username}";
in {
  system = { ... }: {
    ssh = {
      startAgent = true;
    };
  };

  home = { ... }: {
    programs.ssh = {
      enable = true;

      userKnownHostsFile = "${sshPath}/known_hosts";

      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "${sshPath}/id_github" ];
        };
      };
    };
  };
}
