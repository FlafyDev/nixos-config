{ config, lib, nixpkgs, home-manager, ...}:

let
  # home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  nvidia-offload = nixpkgs.writeShellScriptBin "nvidia-offload" ''
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
    package = nixpkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  
  nixpkgs.config = import ./nixpkgs-config.nix;

  imports = [
    ./hardware-configuration.nix
    # (import "${home-manager}/nixos")
    home-manger.nixosModule
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
    supportedFilesystems = [ "ntfs" ];
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
    printing = {
      enable = true;
      drivers = [
        nixpkgs.hplip
      ];
    };

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
  
  environment.gnome.excludePackages = (with nixpkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with nixpkgs.gnome; [
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

    home.stateVersion = "21.11";

    home.packages = with pkgs; [
      proton-caller
      sqlitebrowser
      libreoffice
      syncplay
      qbittorrent
      discord 
      krita
      nodejs-16_x
      yarn
      polymc
      element-desktop
      gimp
      vlc
      libsForQt5.kdenlive
      libstrangle
      # Flutter
      chromedriver
      google-chrome
      chromium 
      dart
    ];

    dconf = {
      enable = true;
      settings = let 
        inherit (lib.hm.gvariant) mkTuple mkUint32;
      in {
        "org/gnome/desktop/input-sources" = {
          per-window = false;
          sources = [ (mkTuple ["xkb" "us"]) (mkTuple ["xkb" "il"]) ];
          xkb-options = ["terminate:ctrl_alt_bksp" "grp:caps_toggle"];
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "aztaskbar@aztaskbar.gitlab.com"
            "Hide_Activities@shay.shayel.org"
            "blur-my-shell@aunetx"
            "sound-output-device-chooser@kgshank.net"
            "gtktitlebar@velitasali.github.io"
            "clipboard-indicator@tudmotu.com"
            "windowIsReady_Remover@nunofarruca@gmail.com"
            "mprisindicatorbutton@JasonLG1979.github.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
          ];
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = -0.78;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          two-finger-scrolling-enabled = true;
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
          picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
          primary-color = "#3465a4";
        };
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          color-scheme = "prefer-dark";
        };
        "apps/guake/general" = {
          gtk-prefer-dark-theme = true;
        };
        "apps/guake/style/background" = {
          transparency = 90;
        };
        "org/gnome/desktop/peripherals/keyboard" = {
          delay = mkUint32 226;
        };
      };
    };
        
    programs = {
      vscode = {
        enable = true;
        package = pkgs.vscode-fhs;
      };

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
        config = {
          vo = "gpu";
          profile = "gpu-hq";
          hwdec = "auto";
          force-window = true;
          ytdl-format = "bestvideo+bestaudio";
          cache-default = 4000000;
          volume-max = 200;
          fs = true;
          screen = 0;
          save-position-on-quit = true;
        };
        bindings = {
          UP = "add volume 2";
          DOWN = "add volume -2";
          WHEEL_UP = "add volume 2";
          WHEEL_DOWN = "add volume -2";
          "ctrl+pgup" = "playlist-next";
          "ctrl+pgdwn" = "playlist-prev"; 
        };
        scripts = with pkgs.mpvScripts; [
          mpris
          autoload
        ];
      };
    };
  };

  programs = {
    dconf.enable = true;
    adb.enable = true;
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
    guake
    woeusb
    cmake
    clang
    ninja
    pkg-config
    gtk3
    python3
  ] ++ (with pkgs.gnomeExtensions; [
    gtk-title-bar
    app-icons-taskbar
    hide-activities-button
    blur-my-shell
    sound-output-device-chooser
    clipboard-indicator
    window-is-ready-remover
    mpris-indicator-button
    bluetooth-quick-connect
  ]);

  system.stateVersion = "21.11";
}
