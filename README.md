# nix-omarchy-screen-mirroring

Nix flake and NixOS module packaging for **Screen Mirroring** using [`omarroth/doubletake`](https://github.com/omarroth/doubletake) and the [`spaceXrace/omarchy-screen-mirroring`](https://github.com/spaceXrace/omarchy-screen-mirroring) widget.

## Features

- **AirPlay Mirroring Sender**: Stream your Wayland or X11 desktop to Apple TV, Roku, and AirPlay-compatible smart TVs.
- **Hardware Acceleration**: Automatic H.264/HEVC encoding via VA-API, NVENC, or software encoders.
- **Wayland Screencasting**: Full integration with PipeWire and `xdg-desktop-portal`.
- **Declarative NixOS Firewall**: Opens doubletake's timing/audio UDP port range `60000:60010` declaratively without requiring UFW or Polkit prompts.

## Quick Run

```bash
# Discover and stream directly using doubletake CLI
nix run github:deepwatrcreatur/nix-omarchy-screen-mirroring -- -target <receiver-ip>
```

## NixOS Module Usage

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-omarchy-screen-mirroring.url = "github:deepwatrcreatur/nix-omarchy-screen-mirroring";
  };

  outputs = { self, nixpkgs, nix-omarchy-screen-mirroring, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        nix-omarchy-screen-mirroring.nixosModules.default
        {
          services.omarchy-screen-mirroring = {
            enable = true;
            openFirewall = true; # Opens UDP 60000:60010
          };
        }
      ];
    };
  };
}
```
