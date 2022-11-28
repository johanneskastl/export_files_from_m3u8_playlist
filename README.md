![Shellcheck](https://github.com/ojkastl/export_files_from_m3u8_playlist/workflows/Shellcheck/badge.svg)

# Export files from a m3u8 playlist into a folder

This script creates a folder, named after the playlist it was given, and copies all files referenced in the playlist into that folder.

Usage:

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

The script does **not** preserve the original order (yet).

License
-------

GPL 3.0 or later

Author Information
------------------

I am Johannes Kastl, reachable via git@johannes-kastl.de.
