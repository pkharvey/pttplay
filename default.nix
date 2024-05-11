{ alsa-utils
, callPackage
, ffmpeg
, file
, cm108 ? callPackage ./cm108 {}
, writeShellApplication
}:

writeShellApplication {
  name = "pttplay.sh";
  runtimeInputs = [ alsa-utils ffmpeg file cm108 ];
  text = builtins.readFile ./pttplay.sh;
}
