#!/bin/bash
#
# Links the source file into the destination. If the destination is already
# a file, moves it into the backup path.

set -euo pipefail

function die {
    echo "$1" >&2
    exit "${2:-1}"
}

function realpath {
    echo "$(cd "$(dirname "$1")"; pwd)"/"$(basename "$1")"
}

if (( $# != 3 )) ; then
    die "Usage: $0 <src> <dst> <backup-path>"
fi

SRCCOLOR="\033[33m"
ENDCOLOR="\033[0m"

src="$1"
dst="$2"
bck="$3"

[[ -e "$src" ]] || die "Error: $src doesn't exist" 2

if [[ -L "$dst" ]] ; then
    # removing an existing symlink so ln doesn't complain
    rm -f "$dst"
elif [[ -e "$dst" ]] ; then
    # moving an existing file to a backup location
    install -vd "$(dirname "$bck/$dst")"
    mv -v "$dst" "$bck/$dst"
else
    echo "$dst not present"
fi

printf '%b' "${SRCCOLOR}"
ln -sv "$(realpath "$src")" "$dst"
printf '%b' "${ENDCOLOR}"
