{ username }: let 
  sshPath = "/secrets/ssh/${username}";
in {
  system = { ... }: {
    programs.ssh = {
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
