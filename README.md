# NixOS Config


> **_NOTE:_** To use this config, you must use [this patch](https://github.com/FlafyDev/nixos-config/blob/main/configs/nix/evaluable-inputs.patch) for Nix.
> It enables the flake's inputs to be a thunk rather than just a set (in this case, use `let in`).
> See [this issue](https://github.com/NixOS/nix/issues/3966) for more info.

## Structure

This configuration doesn't utilize the module system of nix as much as other configurations.
Unlike traditional configurations, where all inputs are contained in the flake.nix,
this configuration stores all of the inputs, overlays, modules, and system/home configs that relate to the same thing in the same file under the `configs` directory.
For example, my [Hyprland config](https://github.com/FlafyDev/nixos-config/blob/main/configs/hyprland.nix) includes the flake input, modules, overlays, and system and home configs. 

Each profile contains a list of configs from the `configs` directory to be installed on the system.

### Config syntax

```nix
# All fields are optional
{
  inputs = {...};

  add = inputs: {
    modules = [...]; 
    homeModules = [...];
    overlays = {...}: [...];
  };

  system = {...}: {...};
  home = {...}: {...};
}
```


### Why

I chose this particular structure to consolidate all the configurations associated with a particular program into a single file.
For instance, in the case of Hyprland, typically Hyprland's flake URL is specified in the flake.nix, followed by module and overlay imports in other files, and then finally utilizing the system and home modules in yet more files.

This leads to scattering of Hyprland related content across several files, which I wanted to avoid.

I would like to point out that I opted for this structure early on in my Nix journey, so it's possible that I might choose a completely different approach if I were to create a configuration again.
It could also be that my decision to use this particular structure may have been influenced by my limited understanding of other structures.
Which is why I welcome discussions on this configuration.

---

##### Archive:
<details>
  <summary>First rice + Reddit post</summary>

[![sscombined](https://user-images.githubusercontent.com/44374434/184814236-0f2b53ed-52de-4cc1-bd93-9dd343bf0f42.png)](https://www.reddit.com/r/unixporn/comments/wor3id/i3_first_time_ricing_i_like_transparency_and_blur/)
</details>


