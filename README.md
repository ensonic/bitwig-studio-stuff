# bitwig-studio-stuff

I am using [Bitwig Studio](https://www.bitwig.com/) under Linux (openSUSE
Tumbleweed and Debian testing). This repo contains tools to sync my bitwig
installations, tools related to bitwig studio and my presets.

## Presets

The esisest way to install the presets is to symlink the foilder.
``` shell
cd $HOME/Bitwig Studio/Library/Presets
ln -s /home/ensonic/projects/audio/bitwig/bitwig-studio-stuff/presets/ Ensonic-Bitwig-Presets
```

## Tools

To run the tools either cd to the `bin` directory, add the `bin` directory to
your path or symlink the tools into a `bin` directory that is on your path.

### bw-encode

Right now bitwig studio only exports audio as wav files without any metadata. 
This script encodes such a wav file to mp3/ogg-vorbis and adds metadata.

