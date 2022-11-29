![Shellcheck](https://github.com/ojkastl/export_files_from_m3u8_playlist/workflows/Shellcheck/badge.svg)

# Export files from a m3u8 playlist into a folder

This script creates a folder, named after the playlist it was given, and copies all files referenced in the playlist into that folder.

It accepts files with Unix or DOS/Windows line endings. Currently only files with a m3u8 extension are supported.

## Usage

```bash
export_files_from_m3u8_playlist.sh [-h] [-v] [-l] [-s] playlist_file.m3u8

-h => show this help
-v => enable verbose copying
-l => enable hardlinking instead of copying
-s => name target file according to playlist position
      first entry 'nothing_compares.mp3' becomes '01_nothing_compares.mp3'
      or '001_nothing_compares.mp3' etc. depending on the total number of
      entries in the playlist
```

## Examples

```bash
$ ./export_files_from_m3u8_playlist.sh my_gorgeous_playlist.m3u8
[...]
$ ls -1 ./my_gorgeous_playlist/
'04 Wait And Bleed.mp3'
'06 Purple Rain.mp3'
'09 Brothers In Arms.mp3'
'16 Nothing Compares 2 U.mp3'
$
```

The script does preserve the original order, if you use the `-s` options:

```bash
$ ./export_files_from_m3u8_playlist.sh -s my_gorgeous_playlist.m3u8
[...]
$ ls -1 ./my_gorgeous_playlist/
'01_16 Nothing Compares 2 U.mp3'
'02_06 Purple Rain.mp3'
'03_04 Wait And Bleed.mp3'
'04_09 Brothers In Arms.mp3'
$
```

In case you want to hardlink the files instead of copying, use the `-l` option.

Verbose output of the copy command can be achieved by using the `-v` option.

## License

GPL 3.0 or later

## Author Information

I am Johannes Kastl, reachable via git@johannes-kastl.de.
