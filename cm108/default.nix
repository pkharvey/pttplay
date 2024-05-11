{ lib
, libusb
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "cm108";
  version = "unstable-2020-05-09";

  src = fetchFromGitHub {
    owner = "twilly";
    repo = "cm108";
    rev = "ca260ba20bc4966816db05b42d47be587c80e219";
    hash = "sha256-bBGf8YSELPtK1LOM0rto6SMoO98cZNoWNUtBKyDcAHc=";
  };

  nativeBuildInputs = [ libusb ];

  installPhase = ''
    mkdir -p $out/bin
    cp cm108 $out/bin
  '';

  meta = with lib; {
    description = "CM108/119 GPIO CLI Tool";
    homepage = "https://github.com/twilly/cm108";
    license = licenses.gpl2;
    maintainers = with maintainers; [ pkharvey ];
    mainProgram = "cm108";
    platforms = platforms.all;
  };
}
