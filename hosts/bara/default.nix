{
  pkgs,
  inputs,
  config,
  lib,
  utils,
  ssh,
  ...
}: let
  inherit (utils) domains getHostname;
  pkgsBara = import inputs.nixpkgs-bara {
    inherit (pkgs) system;
  };
in {
  imports = [
    ./hardware
  ];

  hm.home.stateVersion = "23.11";
  users.main = "phone";
  users.host = "bara";

  os.services.xserver = {
    enable = true;
    desktopManager.plasma5.mobile.enable = true;
  };


  # os.hardware.opengl.package = pkgsBara.mesa;

  networking.enable = true;
  # networking.allowedPorts.tcp."22" = ["*"];
  os.environment.systemPackages = [
    pkgs.moonlight-qt
    pkgs.v4l-utils
    pkgs.nvtop-msm
    pkgs.firefox
    pkgs.alacritty
    pkgs.mpv
    pkgs.btop
    # pkgs.gpu-screen-recorder
    # pkgs.gpu-screen-recorder-gtk
    # pkgs.sunshine
    pkgs.iperf
    pkgs.libva-utils
    pkgs.ffmpeg-full
    pkgs.wayvnc
    pkgs.pavucontrol
    # pkgs.obs-studio
    pkgs.gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    pkgs.gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    pkgs.gst_all_1.gst-plugins-good
    pkgs.gst_all_1.gst-plugins-bad
    pkgs.gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    pkgs.gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    pkgs.gst_all_1.gst-vaapi
    pkgs.ffmpeg
    (pkgs.callPackage ./sunshine-temp {})

        (pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            # obs-vaapi
            obs-gstreamer
          ];
        })
  ];
  # os.environment.sessionVariables = {
  #   GST_PLUGIN_SYSTEM_PATH = "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/";
  # };

  os.nixpkgs.config.allowUnsupportedSystem = true;
  # hm.programs.obs-studio.enable = true;
  # hm.programs.obs-studio.plugins = with pkgs; [
  #   obs-studio-plugins.obs-gstreamer
  #   # obs-studio-plugins.obs-vkcapture
  #   # obs-studio-plugins.obs-pipewire-audio-capture
  #   # obs-studio-plugins.obs-multi-rtmp
  #   # obs-studio-plugins.obs-move-transition
  # ];

  gtk.enable = true;

  # os.mobile.boot.stage-1.kernel.modules = [
  #   "wireguard"
  # ];
  # os.mobile.boot.stage-1.kernel.modular = true;

  # os.networking.wireguard = {
  #   enable = true;
  #   interfaces = {
  #     wg_private = {
  #       ips = ["10.10.11.12/32"];
  #       privateKeyFile = ssh.bara.bara_wg_private.private;
  #       peers = [
  #         {
  #           publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
  #           allowedIPs = ["10.10.11.10/32"];
  #           endpoint = "${domains.personal}:51821";
  #           persistentKeepalive = 25;
  #         }
  #       ];
  #     };
  #   };
  # };

  os.services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
  display.greetd.enable = true;
  display.greetd.command = "Hyprland";

  os.services.openssh.enable = true;
  os.services.openssh.settings.PermitRootLogin = "yes";
  programs = {
    # ssh = {
    #   enable = true;
    #   sftp.enable = true;
    #
    #   # matchBlocks = {
    #   #   ope-lan = {
    #   #     hostname = getHostname "ope.lan1";
    #   #     identitiesOnly = true;
    #   #     identityFile = [ssh.bara.bara_to_ope.private];
    #   #   };
    #   #   ope-private = {
    #   #     hostname = getHostname "ope.wg_private";
    #   #     identitiesOnly = true;
    #   #     identityFile = [ssh.bara.bara_to_ope.private];
    #   #   };
    #   # };
    #
    #   server = {
    #     enable = true;
    #
    #     # users.${config.users.main}.keyFiles = [
    #     #   # (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
    #     #   ssh.ope.ope_to_bara.public
    #     # ];
    #     # users.root.keyFiles = [
    #     #   # (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
    #     #   ssh.ope.ope_to_bara.public
    #     # ];
    #   };
    # };

    nix.enable = true;
    nix.patch = false;
    # anyrun.enable = true;
    foot.enable = true;
    fish.enable = true;
  };
  # secrets.enable = true;
  # secrets.autoBitwardenSession.enable = true; # TODO: remove redundant
  # bitwarden.enable = true;
  # programs.discord.enable = true;

  display.hyprland = {
    enable = true;
    monitors = [
      "DSI-1,1080x2280@60,0x0,2.5,transform,1"
    ];
    fromNixpkgs = true;
  };

  assets.enable = true;

  themes.themeName = "amoled";
  # fonts.enable = true;

  os.system.stateVersion = "23.11";
}
