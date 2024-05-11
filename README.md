# pttplay

`pttplay.sh` is a command line tool that takes a media file and plays its audio
content to a radio transceiver with a CM108 PTT interface.  It can be used for
automatic ident, allstar nodes, repeater control, etc.  Default PTT delay and
GPIO number are chosen to work well with the BF-888S and the commonly found
homebrew CM108 mod with an NPN transistor to drive the PTT.

`cm108` is a command line GPIO tool for CMedia CM108 and CM119 audio devices.
It's a small adaptation of [Dire Wolf][1]'s cm108 driver to compile with very
few dependencies and to take options to set GPIO pins.

# Building

    $ nix-build --expr 'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./default.nix {}'

# Installing

    TODO

# Using

## Print Attached Devices

    $ result/bin/pttplay.sh

## Usage example

    $ result/bin/pttplay.sh hw:3,0 /dev/hidraw6 callsign.mp3


 [1]: https://github.com/wb2osz/direwolf
