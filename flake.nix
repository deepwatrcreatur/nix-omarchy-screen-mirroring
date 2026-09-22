{
  description = "Nix packaging and NixOS module for Omarchy screen mirroring (doubletake AirPlay sender)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgsSet = pkgs.callPackage ./package.nix { };
      in
      {
        packages = {
          default = pkgsSet.default;
          doubletake = pkgsSet.doubletake;
          omarchy-screen-mirroring = pkgsSet.omarchyPlugin;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgsSet.doubletake}/bin/doubletake";
          };
          doubletake-ctl = {
            type = "app";
            program = "${pkgsSet.doubletake}/bin/doubletake-ctl";
          };
        };
      }
    )
    // {
      nixosModules = {
        default = self.nixosModules.omarchy-screen-mirroring;
        omarchy-screen-mirroring =
          { config, pkgs, ... }:
          {
            imports = [ ./module.nix ];
            services.omarchy-screen-mirroring.package =
              nixpkgs.lib.mkDefault self.packages.${pkgs.system}.doubletake;
          };
      };

      overlays.default = final: prev: {
        doubletake = self.packages.${prev.system}.doubletake;
        omarchy-screen-mirroring = self.packages.${prev.system}.omarchy-screen-mirroring;
      };
    };
}
