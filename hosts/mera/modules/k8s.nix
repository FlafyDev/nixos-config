{ secrets, ... }:
{
  os.environment.etc."cni/net.d".enable = false;
  os.services.kubernetes = {
    roles = [ "master" ];
    masterAddress = "mera.home.flafy.dev";
    apiserverAddress = "https://mera.home.flafy.dev:6443";
    easyCerts = true;
    proxy.enable = false;
    flannel.enable = false;
    apiserver = {
      securePort = 6443;
      # tokenAuthFile = secrets.k8s-cluster.auth_token;
      advertiseAddress = "10.0.0.41";
      allowPrivileged = true;
      extraSANs = [
        "10.0.0.41"
        "10.10.10.11"
        "mera.wg_vps.flafy.dev"
      ];
    };
    pki.cfsslAPIExtraSANs = [
      "10.0.0.41"
      "10.10.10.11"
      "mera.wg_vps.flafy.dev"
    ];
    clusterCidr = "192.168.88.0/24";

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = ''
      --fail-swap-on=false
      --node-labels=gateway-location=home,role=master
    '';
  };
}
