{secrets, ...}: {
  os.environment.etc."cni/net.d".enable = false;
  os.services.kubernetes = {
    roles = ["node"];
    masterAddress = "mera.wg_vps.flafy.dev";
    easyCerts = true;
    proxy.enable = false;
    flannel.enable = false;

    kubelet.kubeconfig.server = "https://mera.wg_vps.flafy.dev:6443";
    apiserverAddress = "https://mera.wg_vps.flafy.dev:6443";

    apiserver = {
      allowPrivileged = true;
    };
    clusterCidr = "192.168.88.0/24";

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}