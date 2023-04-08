{
  system = _: {
    nix.settings = {
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      substituters = [
        "https://cuda-maintainers.cachix.org"
      ];
    };
  };
}
