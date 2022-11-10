{username ? ""}: let
  sshPath = "/secrets/ssh/${username}";
in {
  system = _: {
    programs.ssh = {
      startAgent = true;
    };
  };

  home = _: {
    programs.ssh = {
      enable = true;

      userKnownHostsFile = "${sshPath}/known_hosts";

      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = ["${sshPath}/id_github"];
        };
      };
    };
  };
}
