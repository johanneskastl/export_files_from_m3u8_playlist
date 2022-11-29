#!/bin/bash

# propagate errors even through pipes
set -o pipefail

# this script requires dos2unix
command -v dos2unix > /dev/null || {
    echo "Command dos2unix not found, aborting..."
    exit 7
} 

# define copy command
cp_command='cp -a'

# parse arguments
while getopts vls opt
do
    case ${opt} in
        l)
            # add cp option -l
            cp_command+='l'
        ;;

        v)
            # add cp option -v
            cp_command+='v'
        ;;

        s)
            enable_sorting='true'
        ;;

        *)
            echo "Unknown option, aborting..."
            exit 9
        ;;

    esac
done

# drop all processed options
shift $(( OPTIND - 1 ))

# if there is more than one argument left, abort
[[ "$#" == 1 ]] || {
    echo "Please give playlist name as only argument"
    exit 13
}

# set variable playlist_name to the only remaining argument
playlist_name="$1"

# if the given file does not exist, abort
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

# error out if no files were given inside the playlist
[[ -n "${referenced_files}" ]] || {
    echo "No referenced files found. Aborting..."
    exit 19    
}

echo "Found referenced files:"
echo "${referenced_files}"
echo ""

if [[ "${enable_sorting}" == "true" ]]
then

    echo "Sorting"

else

    # loop over lines from playlist
    while read -r music_file
    do

        echo "---"
        echo "Working on ${music_file}"
        if [[ -f "${music_file}" ]]
        then
            # copy file, if not yet present
            [[ -f "./${playlist_folder_name}/$(basename "${music_file}")" ]] || "${cp_command}" "${music_file}" "./${playlist_folder_name}"
        else
            echo "Error, file ${music_file} not found..."
            exit 21
        fi

    done <<< "${referenced_files}"

fi # if-condition sorting yes/no

echo ""

exit 0
