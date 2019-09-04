# LPLmaker

This will take roms and add them to a playlist for [RetroArch](https://www.retroarch.com) to use when they don't auto add because of CRC checking.

Note the generated playlist will be automatically rewritten by RetroArch in the current format.

## Configuration

You can adjust the behaviour of the script by creating a configuration file, an example on which to base it is provided.
The script will look for a configuration file named `lplmaker.conf` on both `~/.config/` and the directory from which it is invoked, and will load both if found (`./lplmaker.conf` will be loaded after `~/.config/lplmaker.conf`, so it can be used to override some values).

For each playlist to be generated, the following fields **must** be defined:

- `RomDirs`: The directory, relative to RomsDir, where ROMs for this playlist are located.
- `CoreLibs`: The library name for the appropriate core, usually `{name}_libretro.so`.
              Using `DETECT` will make RetroArch try to detect appropriate cores and let you pick.
- `CoreNames`: The name of the core. Use `DETECT` to let RetroArch adjust it.
- `PlaylistNames`: The name of the playlist.
                   Will be used as the filename (with `.lpl` extension) and displayed in the UI.
- `SupportedExtensions`: A space-separated list of valid extensions for this playlist.

And the following fields **can** be defined:

- `ScanZips`: (Optional) Set to 1 to look inside zip files for the extensions above.
            The core must have support for zipped ROM loading.
            Requires the `zipinfo` command.
- `QueryMame`: (Optional) Set to 1 to query MAME for the ROM title (only makes sense on arcade ROMs).
               Requires the `mame` command.

### Zip file scanning

Zip files can be added to the playlists in two ways: either adding zip to list of extensions (SupportedExtensions), or enabling zip file scanning (ScanZips).

The latter is a better option in most cases, the exception being arcade systems.

## About

This is a modified version of the Bash script created by [@jsbursik](https://github.com/jsbursik), which in turn was derived from the script written by u/ShiftyAxel on reddit.
