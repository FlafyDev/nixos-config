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
      aliases = {
        slog = ''! git log --pretty=format:"%C(magenta)%h %C(cyan)%C(bold)%ad %C(green)%<(10,trunc)%an%x09%Creset%C(yellow)%s%C(auto)%d%Creset" --date=short --color=always --graph | head -10'';
        slog-all = ''! git log --pretty=format:"%C(magenta)%h %C(cyan)%C(bold)%ad %C(green)%<(10,trunc)%an%x09%Creset%C(yellow)%s%C(auto)%d%Creset" --date=short --color=always --graph --all | head -10'';
        change = ''!f() { git rebase -i HEAD~$1; }; f'';
      };
      extraConfig = {
        safe.directory = "*";
        credential.helper = "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
      };
    };
  };
}
