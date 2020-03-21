#!/bin/bash
#
# sample invocation:
# cd "$HOME/Bitwig Studio/Projects"
# find . -type d -a -name exported
# for d in 20200222.NyanGooseHonk/exported/*; do ~/bin/bw-encode.sh $d/Master.wav; done
#
# verify tags:
# gst-launch-1.0 -t \
#   filesrc location=20200222.NyanGooseHonk/exported/20200222/NyanGooseHonk.ogg ! \
#   parsebin ! fakesink
#

# eg. "20200222.NyanGooseHonk/exported/20200222/Master.wav"
input="$1"

dir=$(dirname "${input}")
ds=$(basename "${dir}")
year=$(echo ${ds} | cut -c1-4)
month=$(echo ${ds} | cut -c5-6)
day=$(echo ${ds} | cut -c7-8)
base=$(dirname $(dirname "${dir}") | cut -d'.' -f2)
output="${dir}/${base}"

tags="title=${base},artist=ensonic,datetime=(datetime)${year}-${month}-${day}"

echo "encode: ${output}.${ds}.ogg"
gst-launch-1.0 -q \
  filesrc location="${input}" ! \
  wavparse ! \
  progressreport update-freq=1 ! \
  taginject tags="${tags}" ! \
  audioconvert ! \
  vorbisenc ! oggmux ! \
  filesink location="${output}.${ds}.ogg"

echo "encode: ${output}.${ds}.mp3"
gst-launch-1.0 -q \
  filesrc location="${input}" ! \
  wavparse ! \
  progressreport update-freq=1 ! \
  taginject tags="${tags}" ! \
  audioconvert ! \
  lamemp3enc ! id3v2mux ! \
  filesink location="${output}.${ds}.mp3"
  
