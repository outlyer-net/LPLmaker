#!/bin/bash

# Script originally written by u/ShiftyAxel on reddit for windows, rewritten in bash for linux.

# Set to wherever your retroarch directory is (contains paylists folder, cores folder, etc.), typically in ~/.config/retroarch
RetroArchDir="$HOME/.config/retroarch"
RomsDir="$HOME/Roms"

# If you use core updater change this to home/username/.config/retroarch/cores/
CoresDir="/usr/lib/libretro"

# Example of how to setup a SNES and NES playlist.
# Can use "DETECT" instead of corelibs and corename, as well as playlist name if unsure

x=0
RomDirs[$x]="SNES"
CoreLibs[$x]="DETECT" # or e.g. "snes9x_libretro.so"
CoreNames[$x]="DETECT" # or e.g. "Snes9x"
PlaylistNames[$x]="Nintendo - Super Nintendo Entertainment System"
SupportedExtensions[$x]="smc fig sfc gd3 gd7 dx2 bsx swc"
ScanZips[$x]=1

x+=1
RomDirs[$x]="NES"
CoreLibs[$x]="DETECT" # or e.g. "nestopia_libretro.so"
CoreNames[$x]="DETECT" # or e.g. "Nestopia"
PlaylistNames[$x]="Nintendo - Nintendo Entertainment System"
SupportedExtensions[$x]="nes"
ScanZips[$x]=1

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

get_rom_count() {
  local globs="$1"
  local scanzips="$2"
  local uncompressed=$(ls $globs 2>/dev/null | wc -l)
  local compressed=0
  if [[ "$scanzips" -eq 1 ]]; then
    compressed=$(ls *.zip 2>/dev/null | wc -l)
  fi
  echo $(( $uncompressed + $compressed ))
}

# progress(current index, total, current file name)
progress() {
  local index=$1
  local total=$2
  local current="$3"
  # Trim to at most 64 characters
  printf "[%d/%d] - %-64s\r" $index $total "${current:0:63}" >&2
}

while [ -n "${RomDirs[$x]}" ];  do
  pushd "$RomsDir/${RomDirs[$x]}" > /dev/null
  echo "======================================================================"
  echo "${PlaylistNames[$x]}"
  echo "======================================================================"

  echo "Writing playlist now..."

  SupportedExtensions[$x]=$(echo ${SupportedExtensions[$x]} | sed -r 's/^| / \*\./g')
  PlayList="$RetroArchDir/playlists/${PlaylistNames[$x]}".lpl
  :> "$PlayList"

  FileCount=$(get_rom_count "${SupportedExtensions[$x]}" "${ScanZips[$x]}")
  declare -i FileNum=1
  for f in ${SupportedExtensions[$x]} ; do
    [ -f "$f" ] || continue
    progress $FileNum $FileCount "$f"
    print_rom_entry $x "$RomsDir/${RomDirs[$x]}/$f" "${f%%.*}"
    FileNum+=1
  done  >> "$PlayList"
  # Scan zips for supported ROMs?
  if [[ "${ScanZips[$x]}" -eq 1 ]]; then
    for zip in *.zip ; do
      [[ -f "$zip" ]] || continue
      # Test file contents against known extensions
      progress $FileNum $FileCount "$zip"
      while read CompressedFile ; do
        print_rom_entry "$x" "$RomsDir/${RomDirs[$x]}/$zip#$CompressedFile" "${CompressedFile%%.*}"
      done < <(zipinfo -1 "$zip" | grep -E "$SupportedExtensionsRE")
      FileNum+=1
    done
  fi >> "$PlayList"
  printf '\r%80s' '' >&2 # Clear the progress output
  echo
  echo "$PlayList"

  echo
  popd > /dev/null

  x+=1
done