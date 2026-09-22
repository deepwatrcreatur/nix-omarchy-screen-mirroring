{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.omarchy-screen-mirroring;
in
{
  options.services.omarchy-screen-mirroring = {
    enable = lib.mkEnableOption "Omarchy screen mirroring sender (doubletake)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.doubletake or (pkgs.callPackage ./package.nix { }).default;
      description = "The doubletake package to install.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open the UDP ports (60000:60010) required by doubletake
        for incoming timing and audio traffic.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedUDPPortRanges = lib.mkIf cfg.openFirewall [
      {
        from = 60000;
        to = 60010;
      }
    ];
  };
}
