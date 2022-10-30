{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npm-buildpackage = {
      url = "github:serokell/nix-npm-buildpackage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    webcord = {
      url = "github:fufexan/webcord-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discocss = {
      url = "github:fufexan/discocss/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yuck-vim = {
      url = "github:elkowar/yuck.vim";
      flake = false;
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
      flake = false;
    };
    flutter-tools-nvim = {
      url = "github:FlafyDev/flutter-tools.nvim";
      flake = false;
    };
    lang-to-docx = {
      url = "github:FlafyDev/lang-to-docx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tofi-rbw = {
      url = "github:FlafyDev/tofi-rbw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bspwm-rounded = {
      url = "github:phuhl/bspwm-rounded";
      flake = false;
    };
    sway-borders = {
      url = "github:fluix-dev/sway-borders";
      flake = false;
    };
    qutebrowser-base16 = {
      url = "github:base16-project/base16-qutebrowser";
      flake = false;
    };
    guifetch = {
      url = "github:flafydev/guifetch";
    };
    neovide = {
      url = "github:barklan/neovide/barklan";
      flake = false;
    };
    listen-blue = {
      url = "github:flafydev/listen_blue";
      # url = "path:/mnt/general/repos/flafydev/music_player";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    cp-maps.url = "github:flafydev/cp-maps";
    firefox-ublock-origin = {
      url = "https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-1.44.4.xpi";
      flake = false;
    };
    firefox-sponsor-block = {
      url = "https://addons.mozilla.org/firefox/downloads/file/4016632/sponsorblock-5.1.1.xpi";
      flake = false;
    };
    firefox-vimium-ff = {
      url = "https://addons.mozilla.org/firefox/downloads/file/4017172/vimium_ff-1.67.2.xpi";
      flake = false;
    };
    firefox-bitwarden = {
      url = "https://addons.mozilla.org/firefox/downloads/file/4018008/bitwarden_password_manager-2022.10.1.xpi";
      flake = false;
    };
    firefox-stylus = {
      url = "https://addons.mozilla.org/firefox/downloads/file/3995806/styl_us-1.5.26.xpi";
      flake = false;
    };
    # nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland"; };
    # # only needed if you use as a package set:
    # # nixpkgs-wayland.inputs.nixpkgs.follows = "cmpkgs";
    # nixpkgs-wayland.inputs.master.follows = "master";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        (import ./profiles/wayland.nix) (import ./systems/laptop) inputs
      );
    };
  };
}
