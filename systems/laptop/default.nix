{
  systemType = "x86_64-linux";

  system = { pkgs, config, ... }: {
    imports = [
      ./hardware-configuration.nix
    ];

    sound.enable = false;

    nixpkgs.config.allowUnfree = true;

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
      pulseaudio.enable = false;
      
      nvidia = {
        modesetting.enable = true;
        prime = {
          sync.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      opengl = {
        enable = true;
        driSupport = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
      };
    };

    # wake up on external usb devices
    powerManagement.powerDownCommands = ''
      echo enabled > /sys/bus/usb/devices/usb1/power/wakeup
      echo enabled > /sys/bus/usb/devices/usb2/power/wakeup
    '';
    
    # specialisation = {
    #   external-display.configuration = {
    #     system.nixos.tags = [ "external-display" ];
    #     hardware.nvidia.prime.offload.enable = lib.mkForce false;
    #     hardware.nvidia.powerManagement.enable = lib.mkForce false;
    #   };
    # };

    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
      };

      openssh.enable = true;
      blueman.enable = true;
      
      xserver = {
        videoDrivers = [ "nvidia" ];
      };
    };

    system.stateVersion = "21.11";
  };

  home = { pkgs, lib, ... }: let
    patchDesktop = pkg: appName: from: to: lib.hiPrio (pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
      ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
      ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
    '');
  in {
    home.packages = [
      (
        patchDesktop pkgs.chromium "chromium-browser"
        "^Exec=chromium" "Exec=nvidia-offload ${pkgs.chromium}/bin/chromium -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder"
      )

      (patchDesktop pkgs.mpv-unwrapped "mpv" "^Exec=mpv" "Exec=nvidia-offload mpv")
    ];
    # xdg.desktopEntries.chromium = {
    #   name = "Chromium (prime)";
    #   genericName = "Web Browser";
    #   exec = "nvidia-offload chromium %U";
    #   terminal = false;
    #   categories = [ "Application" "Network" "WebBrowser" ];
    #   mimeType = [ "text/html" "text/xml" ];
    # };

    # xdg.desktopEntries.mpv = {
    #   type = "Application";
    #   name = "mpv Media Player (prime)";
    #   genericName = "Multimedia player";
    #   comment = "Play movies and songs";
    #   icon = "mpv";
    #   exec = "nvidia-offload mpv --player-operation-mode=pseudo-gui -- %U";
    #   terminal = false;
    #   categories = [ "AudioVideo" "Audio" "Video" "Player" "TV" ];
    #   mimeType = "application/ogg;application/x-ogg;application/mxf;application/sdp;application/smil;application/x-smil;application/streamingmedia;application/x-streamingmedia;application/vnd.rn-realmedia;application/vnd.rn-realmedia-vbr;audio/aac;audio/x-aac;audio/vnd.dolby.heaac.1;audio/vnd.dolby.heaac.2;audio/aiff;audio/x-aiff;audio/m4a;audio/x-m4a;application/x-extension-m4a;audio/mp1;audio/x-mp1;audio/mp2;audio/x-mp2;audio/mp3;audio/x-mp3;audio/mpeg;audio/mpeg2;audio/mpeg3;audio/mpegurl;audio/x-mpegurl;audio/mpg;audio/x-mpg;audio/rn-mpeg;audio/musepack;audio/x-musepack;audio/ogg;audio/scpls;audio/x-scpls;audio/vnd.rn-realaudio;audio/wav;audio/x-pn-wav;audio/x-pn-windows-pcm;audio/x-realaudio;audio/x-pn-realaudio;audio/x-ms-wma;audio/x-pls;audio/x-wav;video/mpeg;video/x-mpeg2;video/x-mpeg3;video/mp4v-es;video/x-m4v;video/mp4;application/x-extension-mp4;video/divx;video/vnd.divx;video/msvideo;video/x-msvideo;video/ogg;video/quicktime;video/vnd.rn-realvideo;video/x-ms-afs;video/x-ms-asf;audio/x-ms-asf;application/vnd.ms-asf;video/x-ms-wmv;video/x-ms-wmx;video/x-ms-wvxvideo;video/x-avi;video/avi;video/x-flic;video/fli;video/x-flc;video/flv;video/x-flv;video/x-theora;video/x-theora+ogg;video/x-matroska;video/mkv;audio/x-matroska;application/x-matroska;video/webm;audio/webm;audio/vorbis;audio/x-vorbis;audio/x-vorbis+ogg;video/x-ogm;video/x-ogm+ogg;application/x-ogm;application/x-ogm-audio;application/x-ogm-video;application/x-shorten;audio/x-shorten;audio/x-ape;audio/x-wavpack;audio/x-tta;audio/AMR;audio/ac3;audio/eac3;audio/amr-wb;video/mp2t;audio/flac;audio/mp4;application/x-mpegurl;video/vnd.mpegurl;application/vnd.apple.mpegurl;audio/x-pn-au;video/3gp;video/3gpp;video/3gpp2;audio/3gpp;audio/3gpp2;video/dv;audio/dv;audio/opus;audio/vnd.dts;audio/vnd.dts.hd;audio/x-adpcm;application/x-cue;audio/m3u;"; 
    # };

    home.stateVersion = "21.11";
  };
}
