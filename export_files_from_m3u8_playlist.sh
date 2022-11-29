#!/bin/bash

# propagate errors even through pipes
set -o pipefail

function usage() {
    echo "Usage:"
    echo "$(basename "$0") [-h] [-v] [-l] [-s] playlist_file.m3u8"
    echo ""
    echo "-h => show this help"
    echo "-v => enable verbose copying"
    echo "-l => enable hardlinking instead of copying"
    echo "-s => name target file according to playlist position"
    echo "      first entry 'nothing_compares.mp3' becomes '01_nothing_compares.mp3'"
    echo "      or '001_nothing_compares.mp3' etc. depending on the total number of"
    echo "      entries in the playlist"
    echo ""
    exit 0
}

# this script requires dos2unix
command -v dos2unix > /dev/null || {
    echo "Command dos2unix not found, aborting..."
    exit 7
} 

# define copy command
cp_command='cp -a'

# parse arguments
while getopts hvls opt
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

        h)
            usage
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

if [[ -d "./${playlist_folder_name}" ]] 
then
    echo "Playlist folder ${playlist_folder_name} already exists"
else
    echo "Creating the playlist folder ${playlist_folder_name}"
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

# store the number of files found
number_of_files="$(wc -l <<<"${referenced_files}")"

if [[ "${number_of_files}" -lt 100 ]]
then
    printf_format_string='%02d'
else
    if [[ "${number_of_files}" -lt 1000 ]]
    then
        printf_format_string='%03d'
    else
        printf_format_string='%04d'
    fi
fi

[[ "${enable_sorting}" == "true" ]] && echo "Copying while keeping the sorting"
list_index=1

# loop over lines from playlist
while read -r music_file
do

    if [[ "${enable_sorting}" == "true" ]]
    then
        # shellcheck disable=SC2059
        prefix="$(printf "${printf_format_string}" "${list_index}" )_"
    else
        prefix=''
    fi

    echo "---"
    echo "Working on ${music_file}"
    # shellcheck disable=SC2059
    [[ "${enable_sorting}" == "true" ]] && echo "Entry number: $(printf "${printf_format_string}" "${list_index}")"

    if [[ -f "${music_file}" ]]
    then
        if [[ -f "./${playlist_folder_name}/${prefix}$(basename "${music_file}")" ]]
        then
            echo "File ${prefix}$(basename "${music_file}") already present"
        else
            # copy file, if not yet present
            ${cp_command} "${music_file}" "./${playlist_folder_name}/${prefix}$(basename "${music_file}")" || {
                echo "Error when copying file ${music_file}"
                exit 23
            }
        fi
    else
        echo "Error, file ${music_file} not found..."
        exit 21
    fi
    list_index=$(( "${list_index}" + 1))

done <<< "${referenced_files}"

echo "---"
echo ""

exit 0
