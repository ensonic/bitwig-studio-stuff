#!/bin/bash

# eg. "<project-dir>/exported/<date>/Master.wav"
input="$1"

dir=$(dirname "${input}")
ds=$(echo "${dir}" | rev | cut -d'/' -f 1 | rev)
year=$(echo ${ds} | cut -c1-4)
month=$(echo ${ds} | cut -c5-6)
day=$(echo ${ds} | cut -c7-8)
base=$(echo "${dir}" | rev | cut -d'/' -f 3 | rev | cut -d'.' -f2)
output="${dir}/${base}"
prj_dir=$(dirname $(dirname "${dir}"))

tags="title=${base},artist=ensonic,datetime=(datetime)${year}-${month}-${day}"

if [ ! -f "${output}.${ds}.ogg" ]; then
  echo "encode: ${output}.${ds}.ogg"
  gst-launch-1.0 -q \
    filesrc location="${input}" ! \
    wavparse ! \
    progressreport update-freq=1 ! \
    taginject tags="${tags}" ! \
    audioconvert ! \
    vorbisenc ! oggmux ! \
    filesink location="${output}.${ds}.ogg"
fi
if [ ! -f "${output}.${ds}.mp3" ]; then
  echo "encode: ${output}.${ds}.mp3"
  gst-launch-1.0 -q \
    filesrc location="${input}" ! \
    wavparse ! \
    progressreport update-freq=1 ! \
    taginject tags="${tags}" ! \
    audioconvert ! \
    lamemp3enc ! id3v2mux ! \
    filesink location="${output}.${ds}.mp3"
    
    #if [ -e "${prj_dir}/cover.jpg" ]; then
      # lame --ti "${prj_dir}/cover.jpg" "${output}.${ds}.mp3"
      # TODO: nned to tmp mv the cur output
      # ffmpeg -i input.mp3 -i "${prj_dir}/cover.jpg" -map_metadata 0 -map 0 -map 1 "${output}.${ds}.mp3"
      # eyeD3 --add-image="${prj_dir}/cover.jpg":FRONT_COVER "${output}.${ds}.mp3"
    #fi
fi
if [ ! -f "${output}.${ds}.mp4" -a -f "${prj_dir}/cover.jpg" ]; then
  echo "encode: ${output}.${ds}.mp4"
  # imagefreeze seems to no eos?
  #gst-launch-1.0 -e -q -v \
  #  mp4mux name=mux ! filesink location="${output}.${ds}.mp4" \
  #  \
  #  filesrc location="${input}" ! \
  #  wavparse ! \
  #  progressreport update-freq=1 ! \
  #  taginject tags="${tags}" ! \
  #  audioconvert ! \
  #  faac ! queue ! mux. \
  #  \
  #  filesrc location="${prj_dir}/cover.jpg" ! \
  #  jpegdec ! \
  #  videoconvert ! \
  #  imagefreeze ! \
  #  'video/x-raw,framerate=1/1' ! \
  #  x264enc ! queue ! mux.
    
  # https://superuser.com/questions/1041816/combine-one-image-one-audio-file-to-make-one-video-using-ffmpeg
  ffmpeg -r 1 -loop 1 -i "${prj_dir}/cover.jpg" -i "${input}" \
    -c:v libx264 -tune stillimage -pix_fmt yuv420p -vf scale=1280:720 \
    -c:a aac -b:a 192k \
    -shortest \
    -metadata "title=${base}" \
    -metadata "author=ensonic" \
    -metadata "year=${year}" \
    "${output}.${ds}.mp4"
fi

