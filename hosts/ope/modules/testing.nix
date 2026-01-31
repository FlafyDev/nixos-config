{ secrets, config, pkgs, ... }:

{
  # packages for administration tasks
  os.environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  os.environment.etc."cni/net.d".enable = false;
  os.services.kubernetes = {
    roles = ["node"];
    masterAddress = "mera.home.flafy.dev";
    easyCerts = true;
    proxy.enable = false;
    flannel.enable = false;

    kubelet = {
      extraOpts = "--fail-swap-on=false";
      kubeconfig = {
        server = "https://mera.home.flafy.dev:6443";
      };
    };
    apiserverAddress = "https://mera.home.flafy.dev:6443";

    # use coredns
    addons.dns.enable = true;
  };
}