{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  gst_all_1,
  libpulseaudio,
  python3,
  flock,
  pipewire,
}:

let
  doubletake = buildGoModule rec {
    pname = "doubletake";
    version = "unstable-2026-08-24";

    src = fetchFromGitHub {
      owner = "omarroth";
      repo = "doubletake";
      rev = "ae067228d76df011375164814b729932ed55ca2f";
      hash = "sha256-VbB4fue5xROFhxFaZ5frjB+NLpundGQtKK3/GvWkhQg=";
    };

    vendorHash = "sha256-cgvY9MVGe8I3g3Ni2sGucTY6YCyPJ2YnoxxUaYfl1E4=";

    subPackages = [
      "cmd/doubletake"
      "cmd/doubletake-ctl"
      "cmd/doubletake-test-receiver"
    ];

    nativeBuildInputs = [
      pkg-config
      makeWrapper
    ];

    buildInputs = [
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      libpulseaudio
    ];

    postInstall = ''
      for bin in $out/bin/*; do
        wrapProgram "$bin" \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" [
            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-ugly
            gst_all_1.gst-libav
            gst_all_1.gst-vaapi
          ]}" \
          --prefix PATH : ${lib.makeBinPath [
            gst_all_1.gstreamer
            pipewire
          ]}
      done
    '';

    meta = {
      description = "AirPlay screen mirroring sender for Linux (streams to Apple TV, Roku, AirPlay receivers)";
      homepage = "https://github.com/omarroth/doubletake";
      license = lib.licenses.gpl3Only;
      mainProgram = "doubletake";
      platforms = lib.platforms.linux;
    };
  };

  omarchyPlugin = stdenv.mkDerivation rec {
    pname = "omarchy-screen-mirroring";
    version = "1.0.0-unstable-2026-08-31";

    src = fetchFromGitHub {
      owner = "spaceXrace";
      repo = "omarchy-screen-mirroring";
      rev = "8f27a9c14e0eb4d78734d6377ff6143280f731b9";
      hash = "sha256-4NatlGrLjnlo1RBNcdmYM8luhKbdzEEjP4ovK4+tctM=";
    };

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/share/omarchy/plugins/spacexrace.screen-mirroring

      cp -r *.qml *.js manifest.json preview.png $out/share/omarchy/plugins/spacexrace.screen-mirroring/

      cp bin/omarchy-screen-mirroring $out/bin/omarchy-screen-mirroring
      chmod +x $out/bin/omarchy-screen-mirroring

      wrapProgram $out/bin/omarchy-screen-mirroring \
        --prefix PATH : ${lib.makeBinPath [
          doubletake
          python3
          flock
          pipewire
        ]}
    '';

    meta = {
      description = "Omarchy bar widget for mirroring a Linux desktop to compatible receivers";
      homepage = "https://github.com/spaceXrace/omarchy-screen-mirroring";
      license = lib.licenses.mit;
      mainProgram = "omarchy-screen-mirroring";
      platforms = lib.platforms.linux;
    };
  };
in
{
  inherit doubletake omarchyPlugin;
  default = doubletake;
}
