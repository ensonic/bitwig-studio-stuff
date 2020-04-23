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
fi

