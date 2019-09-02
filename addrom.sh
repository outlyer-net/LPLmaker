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
CoreLibs[0]="DETECT" # or e.g. "snes9x_libretro.so"
CoreNames[0]="DETECT" # or e.g. "Snes9x"
PlaylistNames[0]="Nintendo - Super Nintendo Entertainment System"
SupportedExtensions[0]="smc fig sfc gd3 gd7 dx2 bsx swc"
ScanZips[0]=1

RomDirs[1]="NES"
CoreLibs[1]="DETECT" # or e.g. "nestopia_libretro.so"
CoreNames[1]="DETECT" # or e.g. "Nestopia"
PlaylistNames[1]="Nintendo - Nintendo Entertainment System"
SupportedExtensions[1]="nes"
ScanZips[1]=1

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

# Prints a playlist entry.
# The format is:
# Path
# Label
# Core library path (or DETECT)
# Core name (or DETECT)
# CRC
# Database
print_rom_entry() {
  local SystemIndex="$1"
  local RomPath="$2"
  local RomTitle="$3"
  echo $RomPath
  echo $RomTitle
  if [[ "${CoreLibs[$SystemIndex]}" != 'DETECT' ]]; then
    echo $CoresDir/${CoreLibs[$SystemIndex]}
  else
    echo DETECT
  fi
  echo ${CoreNames[$SystemIndex]}
  echo 0\|crc
  echo "${PlaylistNames[$SystemIndex]}".lpl
}

while [ -n "${RomDirs[$x]}" ]; 
  do
    pushd "$RomsDir/${RomDirs[$x]}" > /dev/null
    echo "======================================================================"
    echo "${PlaylistNames[$x]}"
    echo "======================================================================"

    echo "Writing playlist now..."

    SupportedExtensions[$x]=$(echo ${SupportedExtensions[$x]} | sed -r 's/^| / \*\./g')
    PlayList="$RetroArchDir/playlists/${PlaylistNames[$x]}".lpl
    :> "$PlayList"
    for f in ${SupportedExtensions[$x]}
      do
      [ -f "$f" ] || continue
        print_rom_entry $x "$RomsDir/${RomDirs[$x]}/$f" "${f%%.*}" >> "$PlayList"
      done
      # Scan zips for supported ROMs?
      if [[ "${ScanZips[$x]}" -eq 1 ]]; then
        for zip in *.zip ; do
          [[ -f "$zip" ]] || continue
          # Test file contents against known extensions
          while read CompressedFile ; do
            print_rom_entry "$x" "$RomsDir/${RomDirs[$x]}/$zip#$CompressedFile" "${CompressedFile%%.*}"
          done < <(zipinfo -1 "$zip" | grep -E "$SupportedExtensionsRE") >> "$PlayList"
        done
      fi
    echo
    echo "$PlayList"

    echo
    popd > /dev/null

    x+=1
  done