# pttplay

`cosplay.sh` is a command line tool that takes a media file (or pipe) and plays
its audio content to a radio transceiver with a CM108 PTT interface.  It can be
used for automatic ident, allstar nodes, repeater control, etc.  Default PTT
delay and GPIO number are chosen to work well with the BF-888S and the commonly
found homebrew CM108 mod with an NPN transistor to drive the PTT.  Transmit will
be postponed until the channel is clear by reading the COS signal from the radio
transceiver.  GPL-3.0 license.

`cosrecord.sh` is a command line tool that waits for an incoming radio
transmission by monitoring the COS signal, starts recording mono audio at 44100
kHz on signal acquisition, then terminates when signal acquisition is lost.
GPL-3.0 license.

[`cm108`][1] is a command line GPIO tool for CMedia CM108 and CM119 audio
devices. It's a small adaptation of [Dire Wolf][2]'s cm108 driver to compile
with very few dependencies and to take options to set GPIO pins.  GPL-2.0
license.

[`hidapitester`][3] is a command line program to access HID API functions.  It
is required to read the COS status line, which will be wired to `VOL DN` pin as
commonly used for homebrew USB audio interfaces.  GPL-3.0 license.

# Building

    $ nix-build --expr 'let pkgs = import <nixpkgs> {}; in pkgs.callPackage ./default.nix {}'

# Installing

TODO

# Using

## Print help and attached devices

    $ result/bin/cosplay.sh
    $ result/bin/cosrecord.sh

## Usage example

### With files

    $ result/bin/cosplay.sh hw:2 /dev/hidraw3 callsign.mp3
    $ result/bin/cosrecord.sh hw:2 /dev/hidraw2 outfile.wav

### With pipes

    $ cat callsign.wav | result/bin/cosplay.sh hw:2 /dev/hidraw3 -
    $ result/bin/cosrecord.sh hw:2 /dev/hidraw3 - | cat >outpiped.wav

### New buffer feature in this version

You can now buffer stdin to a temporary file.  This has the desired effect of
waiting to receive the entire audio stream first before turning on PTT in use
cases where audio is piped around and occasionally blocks for input.

    $ cat callsign.wav | ./result/bin/cosplay.sh -b hw:2 /dev/hidraw2 -

# Limitations

- COS must be wired to `VOL DN`.  Other combinations not tested.  The string
comparison with `gethidreport()` may need to be adjusted if COS is wired
differently.


 [1]: https://github.com/twilly/cm108
 [2]: https://github.com/wb2osz/direwolf
 [3]: https://github.com/todbot/hidapitester
