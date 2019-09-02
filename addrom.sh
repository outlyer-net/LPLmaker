#!/bin/bash

# Script originally written by u/ShiftyAxel on reddit for windows, rewritten in bash for linux.

# Set to wherever your retroarch directory is (contains paylists folder, cores folder, etc.), typically in ~/.config/retroarch
RetroArchDir="$HOME/.config/retroarch"
RomsDir="$HOME/Roms"

# If you use core updater change this to home/username/.config/retroarch/cores/
CoresDir="/usr/lib/libretro"

# Example of how to setup a SNES and NES playlist.
# Can use "DETECT" instead of corelibs and corename, as well as playlist name if unsure

RomDirs[0]="SNES"
CoreLibs[0]="snes9x_libretro.so"
CoreNames[0]="Snes9x"
PlaylistNames[0]="Nintendo - Super Nintendo Entertainment System"
SupportedExtensions[0]="*.smc *.fig *.sfc *.gd3 *.gd7 *.dx2 *.bsx *.swc"

RomDirs[1]="NES"
CoreLibs[1]="nestopia_libretro.so"
CoreNames[1]="Nestopia"
PlaylistNames[1]="Nintendo - Nintendo Entertainment System"
SupportedExtensions[1]="*.nes"

# No need to edit anything beyond this point, unless you don't want it to delete files, go down.

x=0

clear

echo '!!'
echo '!! **** WARNING **** '
echo '!!'
echo '!! The following playlists will be overwritten if they exist.'
echo '!! Back them up now if you'\''d like to do so or they'\''ll be gone.'
echo '!!'
for PlayList in "${PlaylistNames[@]}"; do
  echo "!! - $PlayList"
done
echo '!!'
echo
read -p "Press [Enter] key to continue (or abort with CTRL+C)..."

while [ -n "${RomDirs[$x]}" ]; 
  do
    pushd "$RomsDir/${RomDirs[$x]}" > /dev/null
    echo "======================================================================"
    echo "${PlaylistNames[$x]}"
    echo "======================================================================"

    echo "Writing playlist now..."

    PlayList="$RetroArchDir/playlists/${PlaylistNames[$x]}".lpl
    :> "$PlayList"
    for f in ${SupportedExtensions[$x]}
      do
      [ -f "$f" ] || continue
        (
          echo "$RomsDir/${RomDirs[$x]}/$f"
          echo ${f%%.*}
          echo $CoresDir/${CoreLibs[$x]}
          echo ${CoreNames[$x]}
          echo 0\|crc
          echo "${PlaylistNames[$x]}".lpl
        ) >> "$PlayList"
      done
      echo
      echo "$PlayList"

    echo
    popd > /dev/null

    x+=1
  done