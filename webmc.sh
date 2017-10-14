#!/bin/bash

#cp webmc.sh /usr/local/bin/webmc && chmod +x /usr/local/bin/webmc

FFMPEG=$(which ffmpeg)

usage(){
	echo "usage: $0 -i <input> -o <output> [-t title] [-a artist] [-f fontsize] [-r resolution] [-d duration]"
	echo "usage: fontsize is a ttf ppt, default: 24"
	echo "usage: resolution format is WEIGHTxHEIGHT, default: 600x200"
	echo "usage: duration is a seconds, defaults to duration of input audio"
	echo "example: $0 -i music.mp3 -t \"The Song Name\" -a \"A Composer\" -f 32 -d 600 -o video.webm"
}

while getopts ":h?i:o:t:a:f:r:d:b:" opt; do
  case $opt in
    i)
      input=$OPTARG
      ;;
    o)
      output=$OPTARG
      ;;
    t)
      title=$OPTARG
      ;;
    a)
      artist=$OPTARG
      ;;
    f)
      fontsize=$OPTARG
      ;;
    r)
      resolution=$OPTARG
      ;;
    d)
      duration=$OPTARG
      ;;
    b)
      bitrate=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    \? | h | *)
      usage; exit 2
      ;;
  esac
done

[ -z "$input" ] && echo "error: input file is mandatory. -h for help" >&2 && exit 1
[ -z "$output" ] && echo "error: output file is mandatory. -h for help" >&2 && exit 1

#defaults
[ -z $fontsize ] && fontsize=24
[ -z $resolution ] && resolution='600x200'
title=`ffprobe -i "$input" -show_entries format_tags=title -v quiet -of csv="p=0"`
artist=`ffprobe -i "$input" -show_entries format_tags=artist -v quiet -of csv="p=0"`
duration=`ffprobe -i "$input" -show_entries format=duration -v quiet -of csv="p=0"`
bitrate=`ffprobe -i "$input" -show_entries stream=bit_rate -v quiet -of csv="p=0"`

[ -z "$title" ] && echo -ne "\n\n\n\033[0;31mwarning: title is empty\033[0m\n\n\n" >&2 && sleep 0.5
[ -z "$artist" ] && echo -ne "\n\n\n\033[0;31mwarning: artist is empty\033[0m\n\n\n" >&2 && sleep 0.5


"$FFMPEG" -f lavfi -i color=c=black:s="${resolution}" -i "${input}" -vf drawtext=text="${title}
${artist}:fontsize=${fontsize}:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" -r 0.5 -t "$duration" -b:a "$bitrate" -hide_banner -y -f webm ${output}
