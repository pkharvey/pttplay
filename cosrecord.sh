#!/usr/bin/env bash

HW_VOLUME_PLAYBACK_LEVEL=14
HW_VOLUME_RECORD_LEVEL=35
POLL_INTERVAL=0.2

print_help() {
    echo "Usage: $0 ADEVICE HID_DEVICE MEDIA_FILE"
    echo "  ADEVICE                       ALSA device name of the interface, e.g. \"hw:2\""
    echo "  HID_DEVICE                    HID device name that will control the PTT, e.g. \"/dev/hidraw3\""
    echo "  MEDIA_FILE                    File to store audio recorded over the air"
    echo "                                When MEDIA_FILE is -, write standard output"
    echo "                                with format s16le, mono, 44100 kHz audio"
    echo
    cm108 -p
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_help
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -lt 3 ]]; then
    echo "Error: Missing required arguments"
    print_help
fi

ADEVICE="$1"
HID_DEVICE="$2"
MEDIA_FILE="$3"

gethidreport() {
    hidapitester -q --open "$HID_DEVICE" -t 0 --open -l 3 --read-input-report 0
}

aplay -q -D "$ADEVICE" -t wav /dev/zero        # test and fail early if can't access audio h/w
amixer -q -D "$ADEVICE" set Speaker "$HW_VOLUME_PLAYBACK_LEVEL"
amixer -q -D "$ADEVICE" set Speaker on
amixer -q -D "$ADEVICE" set Mic "$HW_VOLUME_RECORD_LEVEL"
amixer -q -D "$ADEVICE" set 'Auto Gain Control' on
amixer -q -D "$ADEVICE" set Mic unmute

trap "kill 0" EXIT

if [ "$(gethidreport)" != " 00 00 00" ]
then
    echo "Waiting for carrier..." >&2
    sleep $POLL_INTERVAL
fi

while [ "$(gethidreport)" != " 00 00 00" ]; do sleep $POLL_INTERVAL; done

echo "Recording..." >&2

set +e                                      # make sure failures don't prevent killing the arecord process

if [ "$MEDIA_FILE" = "-" ]; then
    arecord -D "$ADEVICE" -f S16_LE -t wav -r 44100 -c 1 -N &
else
    arecord -D "$ADEVICE" -f S16_LE -t wav -r 44100 -c 1 -N "$MEDIA_FILE" &
fi

while [ "$(gethidreport)" = " 00 00 00" ]; do
    sleep $POLL_INTERVAL
    while [ "$(gethidreport)" = " 00 00 00" ]; do
        sleep $POLL_INTERVAL
        while [ "$(gethidreport)" = " 00 00 00" ]; do
            sleep $POLL_INTERVAL
        done
    done
done

