#!/bin/bash

# propagate errors even through pipes
set -o pipefail

command -v dos2unix > /dev/null || {
    echo "Command dos2unix not found, aborting..."
    exit 7
} 


[[ "$#" == 1 ]] || {
    echo "Please give playlist name as only argument"
    exit 13
}

playlist_name="$1"

[[ -e "${playlist_name}" ]] || {
    echo "Playlist file ${playlist_name} does not exist, aborting..."
    exit 15
}

echo ""
echo "Working on playlist ${playlist_name}"
playlist_folder_name="${playlist_name%.m3u8}"

echo "Creating the playlist folder ${playlist_folder_name}"
if [[ -d "./${playlist_folder_name}" ]] 
then
    echo "Playlist folder ${playlist_folder_name} already exists"
else
    mkdir "./${playlist_folder_name}" || {
        echo "Error when creating the playlist folder ${playlist_folder_name}"
        exit 17
    }
fi

# 
# grep -v "^#"  => ignore lines like '#EXT-X-RATING:0'
# dos2unix      => remove windows line endings, if present
#
referenced_files="$(grep -v "^#" "${playlist_name}" | dos2unix)"

[[ -n "${referenced_files}" ]] || {
    echo "No referenced files found. Aborting..."
    exit 19    
}

echo "Found referenced files:"
echo "${referenced_files}"
echo ""

while read -r music_file
do

    echo "---"
    echo "Working on ${music_file}"
    if [[ -f "${music_file}" ]] 
    then
        [[ -f "./${playlist_folder_name}/$(basename "${music_file}")" ]] || cp -av "${music_file}" "./${playlist_folder_name}"
    else
        echo "Error, file ${music_file} not found..."
        #exit 21
    fi

done <<< "${referenced_files}"

echo ""

exit 0
