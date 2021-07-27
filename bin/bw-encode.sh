#!/bin/bash

# * since bws 4.0 it won't create 'exported' anymore
# * we would also default to ~/Music/<Artist>/<Album>/<Track>.<fmt>
# * we could let bws do the encoding and only add album-art and create the mp4

# eg. "<project-dir>/exported/<date>/Master.wav"
input="$1"

dir=$(dirname "${input}")
ds=$(echo "${dir}" | rev | cut -d'/' -f 1 | rev)
year=$(echo ${ds} | cut -c1-4)
month=$(echo ${ds} | cut -c5-6)
day=$(echo ${ds} | cut -c7-8)
base=$(echo "${dir}" | rev | cut -d'/' -f 3 | rev | cut -d'.' -f2)
output="${dir}/${base}"
exp_dir=$(dirname "${dir}")
prj_dir=$(dirname "${exp_dir}")

tags="title=${base},artist=ensonic,datetime=(datetime)${year}-${month}-${day}"

if [ ! -f "${output}.${ds}.ogg" ]; then
  echo "encode: ${output}.${ds}.ogg"
  # use quality setting
  gst-launch-1.0 -q \
    filesrc location="${input}" ! \
    wavparse ! \
    progressreport update-freq=1 ! \
    taginject tags="${tags}" ! \
    audioconvert ! \
    vorbisenc quality=0.7 ! oggmux ! \
    filesink location="${output}.${ds}.ogg"
  #if [ -e "${prj_dir}/cover.jpg" ]; then
  #  tmpfile=$(mktemp /tmp/bw-enc.XXXXXX.ogg)
  #  mv "${output}.${ds}.ogg" "${tmpfile}"
  #  # This makes it a video :/
  #  ffmpeg -i "${tmpfile}" -f jpeg_pipe -i "${prj_dir}/cover.jpg" \
  #    "${output}.${ds}.ogg"
  #  rm "${tmpfile}"
  #fi
  ln -sf "${PWD}/${output}.${ds}.ogg" "${exp_dir}/${base}.ogg"
fi
if [ ! -f "${output}.${ds}.mp3" ]; then
  echo "encode: ${output}.${ds}.mp3"
  gst-launch-1.0 -q \
    filesrc location="${input}" ! \
    wavparse ! \
    progressreport update-freq=1 ! \
    taginject tags="${tags}" ! \
    audioconvert ! \
    lamemp3enc target=bitrate bitrate=256 cbr=true encoding-engine-quality=high ! id3v2mux ! \
    filesink location="${output}.${ds}.mp3"
    
  if [ -e "${prj_dir}/cover.jpg" ]; then
    tmpfile=$(mktemp /tmp/bw-enc.XXXXXX.mp3)
    mv "${output}.${ds}.mp3" "${tmpfile}"
    ffmpeg -i "${tmpfile}" -f jpeg_pipe -i "${prj_dir}/cover.jpg" \
      -map_metadata 0 -map 0 -map 1 -c copy \
      -metadata:s:v comment="Cover (front)" \
      "${output}.${ds}.mp3"
    rm "${tmpfile}"
    # Alternatives:
    # lame --ti "${prj_dir}/cover.jpg" "${output}.${ds}.mp3"
    # eyeD3 --add-image="${prj_dir}/cover.jpg":FRONT_COVER "${output}.${ds}.mp3"
  fi
  ln -sf "${PWD}/${output}.${ds}.mp3" "${exp_dir}/${base}.mp3"
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
  # -c:v libx264 -tune stillimage
  #
  # video too long: https://trac.ffmpeg.org/ticket/5456
  #
  # previously used: scale=1280:720, but the black borders are ugly
  ffmpeg -r 1 -loop 1 -i "${prj_dir}/cover.jpg" -i "${input}" \
    -c:a aac -b:a 192k \
    -r 1 -shortest \
    -c:v vp9 -pix_fmt yuv420p -vf scale=750:750 \
    -metadata "title=${base}" \
    -metadata "author=ensonic" \
    -metadata "year=${year}" \
    -fflags +shortest -max_interleave_delta 500M \
    "${output}.${ds}.mp4"
  ln -sf "${PWD}/${output}.${ds}.mp4" "${exp_dir}/${base}.mp4"
fi

