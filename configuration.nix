{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  unstable = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable){ config = import ./nixpkgs-config.nix; };
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
  secrets = (import ./secrets.nix);
in
{
  nix = {
    extraOptions = '''';
  };

  nixpkgs.config = import ./nixpkgs-config.nix;

  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        devices = [ "nodev" ];
        efiSupport = true;
        enable = true;
        extraEntries = ''
          menuentry "Windows" {
            insmod part_gpt
            insmod fat
            insmod search_fs_uuid
            insmod chain
            search --fs-uuid --set=root 4424-E13F
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
        version = 2;
      };
    };
    # supportedFilesystems = [ "ntfs" ];
  };

  environment.sessionVariables = rec {
    CHROME_EXECUTABLE = "chromium"; # For Flutter
  };
  
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;

    useDHCP = false;
    interfaces = {
      wlp3s0.useDHCP = true;
      enp4s0.useDHCP = true;
    };

    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  hardware = {
    bluetooth.enable = true;
    opentabletdriver.enable = true;
    opengl.enable = true;
    pulseaudio.enable = true;
    
    nvidia = {
      modesetting.enable = true;
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services = {
    openssh.enable = true;
    printing.enable = true;
    flatpak.enable = true;

    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.lightdm = {
        enable = true;
      };

      libinput = {
        enable = true;
        mouse = {
          accelSpeed = "-0.78";
          accelProfile = "flat";
        };
      };

      videoDrivers = [ "nvidia" ];
    };
  };

  sound.enable = true;
  time.timeZone = "Israel";
  
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    # gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  users.users.flafydev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

 home-manager.users.flafydev = {pkgs, lib, ...}: {
    nixpkgs.config = import ./nixpkgs-config.nix;

    home.packages = with pkgs; [
      syncplay
      qbittorrent
      android-studio
      discord 
      krita
      scrcpy
      nodejs-16_x
      yarn
    ] ++ (with unstable; [
      chromedriver
      google-chrome
      chromium # For Flutter's web debugger
      dart
      flutter
      polymc
      element-desktop
      gimp
      hplip
    ]);
    
    dconf = {
      enable = true;
      settings = let 
        inherit (lib.hm.gvariant) mkTuple;
      in {
        "org/gnome/desktop/input-sources" = {
          per-window = false;
          sources = [ (mkTuple ["xkb" "il"]) (mkTuple ["xkb" "us"]) ];
          xkb-options = ["terminate:ctrl_alt_bksp" "grp:caps_toggle"];
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "aztaskbar@aztaskbar.gitlab.com"
            "Hide_Activities@shay.shayel.org"
            "blur-my-shell@aunetx"
            "sound-output-device-chooser@kgshank.net"
          ];
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = -0.78;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          two-finger-scrolling-enabled = true;
        };
      };
    };
        
    programs = {
      git = {
        enable = true;
        userName  = "FlafyDev";
        userEmail = "flafyarazi@gmail.com";
        extraConfig = {
          safe.directory = "*";
          credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        };
      };
      
      mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          mpris
          autoload
        ];
      };
    };
  };

  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  fonts.fonts = with pkgs; [
    # segoe-ui
  ];

  environment.systemPackages = with pkgs; [
    nano
    wget
    firefox
    parted
    gparted
    dig
    vscode
    btop
    git
    qbittorrent
    neofetch
    pfetch
    unzip
    gh
    ulauncher
    filezilla
    gnome.gnome-tweaks
    gnome.dconf-editor
    xclip
    fish
    pciutils
    nvidia-offload
    xdotool
    dotnet-sdk
    # woeusb
    # cmake
    # gnome.gtk
    # libsForQt5.kwalletmanager
  ] ++ (with unstable.gnomeExtensions; [
    app-icons-taskbar
    hide-activities-button
    blur-my-shell
    sound-output-device-chooser
  ]);

  system.stateVersion = "21.11";
}
