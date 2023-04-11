{
  system = {pkgs, ...}: {
    users.defaultUserShell = pkgs.zsh;
    environment.pathsToLink = ["/share/zsh"];
    programs.zsh.enable = true;
  };

  home = {
    config,
    pkgs,
    ...
  }: {
    programs.nix-index = {
      enableZshIntegration = true;
    };
    programs.starship = {
      enableZshIntegration = true;
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      # enableSyntaxHighlighting = true;
      autocd = true;
      # initExtra = "${pkgs.cp-maps}/bin/cp-maps";
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      envExtra = ''
          export KEYTIMEOUT=0
      '';
      initExtra = ''
        # fixes starship swallowing newlines
        precmd() {
          precmd() {
            echo
          }
        }
        bindkey -v
        bindkey '^R' history-incremental-search-backward
        _cdf () {
          ((CURRENT == 2)) &&
          _files -/ -W /mnt/general/repos/flafydev
        }
      '';
      shellAliases = {
        ll = "ls -lA";
        batp = "bat -P";
      };
      # oh-my-zsh = {
      #   enable = true;
      #   plugins = ["git"];
      #   theme = "robbyrussell";
      # };
      plugins = [
        {
          name = "zsh-autopair";
          file = "zsh-autopair.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
            sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
          };
        }
        {
          name = "zsh-vim-mode";
          file = "zsh-vim-mode.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "softmoth";
            repo = "zsh-vim-mode";
            rev = "1fb4fec7c38815e55bc1b33e7c2136069278c798";
            sha256 = "1dxi18cpvbc96jl6w6j8r6zwpz8brjrnkl4kp8x1lzzariwm25sd";
          };
        }
        {
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma";
            repo = "fast-syntax-highlighting";
            rev = "v1.28";
            sha256 = "106s7k9n7ssmgybh0kvdb8359f3rz60gfvxjxnxb4fg5gf1fs088";
          };
        }
        # {
        #   name = "zsh-history-substring-search";
        #   file = "zsh-history-substring-search.plugin.zsh";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "zsh-users";
        #     repo = "zsh-history-substring-search";
        #     rev = "0f80b8eb3368b46e5e573c1d91ae69eb095db3fb";
        #     sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
        #   };
        # }
      ];
    };
  };
}
