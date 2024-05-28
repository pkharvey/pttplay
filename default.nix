{ pkgs
, alsa-utils
, callPackage
, ffmpeg
, file
, cm108 ? callPackage ./cm108 {}
, hidapitester ? callPackage ./hidapitester {}
, writeShellApplication
}:

let
  inherit (pkgs.buildPackages) symlinkJoin;

  app1 = writeShellApplication {
    name = "cosplay.sh";
    runtimeInputs = [ alsa-utils ffmpeg file cm108 hidapitester ];
    text = builtins.readFile ./cosplay.sh;
  };

  app2 = writeShellApplication {
    name = "cosrecord.sh";
    runtimeInputs = [ alsa-utils file cm108 hidapitester ];
    text = builtins.readFile ./cosrecord.sh;
  };
in
symlinkJoin {
  name = "combined-apps";
  paths = [ app1 app2 ];
}
