#!/usr/bin/env bash

DELAY=0.2    # 200 ms is typical for BF-888S
PTT_GPIO=3

print_help() {
    echo "Usage: $0 [-d|--delay <delay>] [-g|--ptt-gpio <gpio_number>] ADEVICE HID_DEVICE MEDIA_FILE"
    echo "  -d, --delay <delay>           Set the PTT delay value (default: $DELAY)"
    echo "  -g, --ptt-gpio <gpio_number>  Set the PTT GPIO number (default: $PTT_GPIO)"
    echo "  ADEVICE                       ALSA device name of the interface, e.g. \"hw:1\""
    echo "  HID_DEVICE                    HID device name that will control the PTT, e.g. \"/dev/hidraw3\""
    echo "  MEDIA_FILE                    File containing audio to play over the air"
    echo
    cm108 -p
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--delay)
            DELAY="$2"
            shift 2
            ;;
        -g|--ptt-gpio)
            PTT_GPIO="$2"
            shift 2
            ;;
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

if [ ! -e "$MEDIA_FILE" ]; then
    echo "Error: File '$MEDIA_FILE' does not exist."
    exit 1
fi

if [ ! -r "$MEDIA_FILE" ]; then
    echo "Error: File '$MEDIA_FILE' is not readable."
    exit 1
fi

file_type=$(file -b --mime-type "$MEDIA_FILE")
if [[ $file_type != audio/* && $file_type != video/* ]]; then
    echo "Error: File '${MEDIA_FILE}' is neither an audio file nor a video file with audio streams."
    exit 1
fi

aplay -D "$ADEVICE" -t wav /dev/zero        # test and fail early if can't access audio h/w
amixer -D "$ADEVICE" set Mic unmute
cm108 -H "$HID_DEVICE" -P "$PTT_GPIO" -L 1  # key up
set +e                                      # make sure failures don't prevent keying down
sleep "$DELAY"
ffmpeg -hide_banner -i "$MEDIA_FILE" -ac 2 -ar 44100 -f wav pipe:1 | aplay -D "$ADEVICE"
cm108 -H "$HID_DEVICE" -P "$PTT_GPIO" -L 0  # key down

