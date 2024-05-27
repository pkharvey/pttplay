# pttplay

`cosplay.sh` is a command line tool that takes a media file and plays its audio
content to a radio transceiver with a CM108 PTT interface.  It can be used for
automatic ident, allstar nodes, repeater control, etc.  Default PTT delay and
GPIO number are chosen to work well with the BF-888S and the commonly found
homebrew CM108 mod with an NPN transistor to drive the PTT.  Transmit will be
postponed until the channel is clear by reading the COS signal from the radio
transceiver.  GPL-3.0 license.

`cm108` is a command line GPIO tool for CMedia CM108 and CM119 audio devices.
It's a small adaptation of [Dire Wolf][1]'s cm108 driver to compile with very
few dependencies and to take options to set GPIO pins.  GPL-2.0 license.

`hidapitester` is a command line program to access HID API functions.  It is
required to read the COS status line, which will be wired to `VOL DN` pin as
commonly used for homebrew USB audio interfaces.  GPL-3.0 license.

# Building

    $ nix-build --expr 'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./default.nix {}'

# Installing

    TODO

# Using

## Print Attached Devices

    $ result/bin/cosplay.sh

## Usage example

    $ result/bin/cosplay.sh hw:3 /dev/hidraw6 callsign.mp3

# Limitations

- COS must be wired to `VOL DN`.  Other combinations not tested.  The string
comparison with `gethidreport()` may need to be adjusted if COS is wired
differently.


 [1]: https://github.com/wb2osz/direwolf
 [2]: https://github.com/todbot/hidapitester
