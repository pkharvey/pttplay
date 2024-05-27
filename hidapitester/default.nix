{ lib
, hidapi
, udev
, pkg-config
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hidapitester";
  version = "unstable-2020-05-20";

  src = fetchFromGitHub {
    owner = "todbot";
    repo = "hidapitester";
    rev = "9e2ccf1118fda629a122d70f04ab2155caa9f4fd";
    hash = "sha256-6Wq45RIDTkJLbMjzmogumyrfYuS3ib4ygYRewLr0+E4=";
  };

  nativeBuildInputs = [ hidapi udev pkg-config ];

  installPhase = ''
    mkdir -p $out/bin
    cp hidapitester $out/bin
  '';

  meta = with lib; {
    description = "Simple command-line program to test HIDAPI";
    homepage = "https://github.com/todbot/hidapitester";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pkharvey ];
    mainProgram = "hidapitester";
    platforms = platforms.all;
  };
}
