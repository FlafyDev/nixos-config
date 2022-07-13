{ config, lib, pkgs, modulesPath, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };
}