{ alsa-utils
, callPackage
, ffmpeg
, file
, cm108 ? callPackage ./cm108 {}
, hidapitester ? callPackage ./hidapitester {}
, writeShellApplication
}:

writeShellApplication {
  name = "pttplay.sh";
  runtimeInputs = [ alsa-utils ffmpeg file cm108 hidapitester ];
  text = builtins.readFile ./pttplay.sh;
}
