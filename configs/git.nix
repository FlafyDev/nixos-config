{
  system = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      gh
    ];
  };

  home = {pkgs, ...}: {
    programs.git = {
      enable = true;
      userName = "FlafyDev";
      userEmail = "flafyarazi@gmail.com";
      extraConfig = {
        safe.directory = "*";
        credential.helper = "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
      };
    };
  };
}
