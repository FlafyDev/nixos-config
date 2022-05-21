{ config, pkgs, unstable, home-manager, ... }:

{
  boot.isContainer = true;
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # set $FS_UUID to the UUID of the EFI partition
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

  # boot.supportedFilesystems = [ "ntfs" ];

  environment.sessionVariables = rec {
    CHROME_EXECUTABLE = "google-chrome-stable";
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opentabletdriver.enable = true;

  nixpkgs.config = import ./nixpkgs-config.nix;

  # Set your time zone.
  time.timeZone = "Israel";

  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  # networking.interfaces.wlp3s0.useDHCP = true;

  
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the Plasma 5 Desktop Environment.
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;

    displayManager.gdm = {
      enable = true;
      wayland = false;
    };
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    # layout = "us";
    # xkbOptions = "eurosign:e";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse = {
        accelSpeed = "-0.6";
        accelProfile = "flat";
      };
    };

    # videoDrivers = [ "nvidia" ];
  };

  # hardware.opengl.enable = true;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flafydev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.users.flafydev = {pkgs, ...}: {
    nixpkgs.config = import ./nixpkgs-config.nix;
    
    # nixpkgs.overlays = [
    #   (import (builtins.fetchTarball "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz")).overlay
    # ];

    home.packages = with pkgs; [
      syncplay
      qbittorrent
      android-studio
      flutter
      discord
      google-chrome # For Flutter's web debugger
      krita
      scrcpy
      nodejs-16_x
      yarn
      # polymc
   ];

    programs.git = {
      enable = true;
      userName  = "FlafyDev";
      userEmail = "flafyarazi@gmail.com";
      extraConfig = ''
        [safe]
            directory = *
      '';
    };

    programs.mpv = {
      enable = true;
      scripts = with pkgs.mpvScripts; [
        mpris
        mpv-playlistmanager
      ];
    };

    #programs.gnome-shell = {
    #  enable = true;
    #  extensions = with pkgs.gnomeExtensions; [
    #    # { package = app-icons-taskbar; }
    #    { package = hide-activities-button; }
    #  ];
    #};
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    wget
    firefox
    parted
    gparted
    dig
    vscode
    btop
    # woeusb
    git
    qbittorrent
    neofetch
    pfetch
    unzip
    # cmake
    # gnome.gtk
    gh
    # libsForQt5.kwalletmanager
    ulauncher
    filezilla
    gnome.gnome-tweaks
    gnome.dconf-editor
    # gnomeExtensions.dash-to-dock
    # gnomeExtensions.app-icons-taskbar
    # gnomeExtensions.hide-activities-button
  ];

  services.gnome = {
    gnome-keyring.enable = true;
    gnome-online-accounts.enable = true;
    gnome-online-miners.enable = true;
    tracker.enable = true;
    tracker-miners.enable = true;
  };

  # fonts.fonts = with pkgs; [
  #   segoe-ui
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

