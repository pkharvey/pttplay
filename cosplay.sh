#!/usr/bin/env bash

PTT_DELAY=0.2    # 200 ms is typical for BF-888S
PTT_GPIO=3
HW_VOLUME_PLAYBACK_LEVEL=14
HW_VOLUME_RECORD_LEVEL=35
POLL_INTERVAL=0.2
BUFFER_STDIN=0   # 0:no 1:yes

print_help() {
    echo "Usage: $0 [OPTION...] ADEVICE HID_DEVICE MEDIA_FILE"
    echo "  -d, --delay <delay>           Set the PTT delay value (default: $PTT_DELAY)"
    echo "  -g, --ptt-gpio <gpio_number>  Set the PTT GPIO number (default: $PTT_GPIO)"
    echo "  -b, --buffer-stdin            Buffer stdin before starting to transmit"
    echo "  ADEVICE                       ALSA device name of the interface, e.g. \"hw:2\""
    echo "  HID_DEVICE                    HID device name that will control the PTT, e.g. \"/dev/hidraw3\""
    echo "  MEDIA_FILE                    File containing audio to play over the air"
    echo "                                When MEDIA_FILE is -, read standard input"
    echo "                                with format s16le, mono, 22050 kHz audio"
    echo
    cm108 -p
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--delay)
            PTT_DELAY="$2"
            shift 2
            ;;
        -g|--ptt-gpio)
            PTT_GPIO="$2"
            shift 2
            ;;
        -b|--buffer-stdin)
            BUFFER_STDIN=1
            shift 1
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

gethidreport() {
    hidapitester -q --open-path "$HID_DEVICE" -t 0 --open -l 3 --read-input-report 0
}

cleanup() {
    cm108 -H "$HID_DEVICE" -P "$PTT_GPIO" -L 0  # key down
}
trap cleanup EXIT

if [ "$MEDIA_FILE" != "-" ]; then
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
fi

aplay -q -D "$ADEVICE" -t wav /dev/zero        # test and fail early if can't access audio h/w
amixer -q -D "$ADEVICE" set Speaker "$HW_VOLUME_PLAYBACK_LEVEL"
amixer -q -D "$ADEVICE" set Speaker on
amixer -q -D "$ADEVICE" set Mic "$HW_VOLUME_RECORD_LEVEL"
amixer -q -D "$ADEVICE" set 'Auto Gain Control' on
amixer -q -D "$ADEVICE" set Mic unmute

if [ "$BUFFER_STDIN" = 1 ]; then
    echo "$0: Waiting to receive entire stream..."
    TEMP_FILE=$(mktemp)
    cat >"$TEMP_FILE"
fi

if [ "$(gethidreport)" = " 00 00 00" ]
then
    echo "$0: Playback will be postponed until the channel is clear..."
    sleep $POLL_INTERVAL
fi

while [ "$(gethidreport)" = " 00 00 00" ]; do sleep $POLL_INTERVAL; done

cm108 -H "$HID_DEVICE" -P "$PTT_GPIO" -L 1  # key up

set +e                                      # make sure failures don't prevent keying down

sleep "$PTT_DELAY"

if [ "$MEDIA_FILE" = "-" ]; then
    if [ "$BUFFER_STDIN" = 1 ]; then
        ffmpeg -hide_banner -f s16le -ar 22050 -ac 1 -i - -f s16le -ac 2 -ar 44100 pipe:1 < "$TEMP_FILE" | aplay -c 2 -r 44100 -f S16_LE -t raw -D "$ADEVICE"
        rm "$TEMP_FILE"
    else
        ffmpeg -hide_banner -f s16le -ar 22050 -ac 1 -i - -f s16le -ac 2 -ar 44100 pipe:1 | aplay -c 2 -r 44100 -f S16_LE -t raw -D "$ADEVICE"
    fi
else
    ffmpeg -hide_banner -i "$MEDIA_FILE" -f s16le -ac 2 -ar 44100 pipe:1 | aplay -c 2 -r 44100 -f S16_LE -t raw -D "$ADEVICE"
fi

cm108 -H "$HID_DEVICE" -P "$PTT_GPIO" -L 0  # key down

