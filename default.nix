{ alsa-utils
, callPackage
, ffmpeg
, file
, cm108 ? callPackage ./cm108 {}
, hidapitester ? callPackage ./hidapitester {}
, writeShellApplication
}:

writeShellApplication {
  name = "cosplay.sh";
  runtimeInputs = [ alsa-utils ffmpeg file cm108 hidapitester ];
  text = builtins.readFile ./cosplay.sh;
}
