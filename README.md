# bitwig-studio-stuff

I am using [Bitwig Studio](https://www.bitwig.com/) under Linux (openSUSE
Tumbleweed and Debian testing). This repo contains tools to sync my bitwig
installations, tools related to bitwig studio and my presets.

## Presets

The esisest way to install the presets is to symlink the foilder.

```shell
ln -s $PWD/presets/ $HOME/Bitwig Studio/Library/Presets/Ensonic-Bitwig-Presets
```

## Tools

To run the tools either cd to the `bin` directory, add the `bin` directory to
your path or symlink the tools into a `bin` directory that is on your path.

```shell
for t in bin/bw*; do test -x $HOME/$t || ln -s $PWD/$t $HOME/$t; done
```

### bw-encode

Right now bitwig studio only exports audio as wav files without any metadata. 
This script encodes such a wav file to mp3/ogg-vorbis and adds metadata.

It uses gstreamer and requires the plugins packages and gst-laumch-1.0.

Sample invocation:

```shell
cd "$HOME/Bitwig Studio/Projects"
find . -type f -a -name Master.wav
for f in $(find . -type f -a -name Master.wav); do bw-encode.sh "$f"; done
```

Verify metadata tags:

```shell
gst-launch-1.0 -t \
  filesrc location=<project-dir>/exported/<data>/<file>.ogg ! \
  parsebin ! fakesink
```

### bw-sync-preset-repos

Pull updates from all preset repos symlinked into the preset dir.

```shell
bw-sync-preset-repos.sh
```
