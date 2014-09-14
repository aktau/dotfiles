#!/bin/bash

set -e
set -u

dopatch () {
    echo -n "Applying $1..."
    if ! git am -q < "$1" >/dev/null 2>&1; then
        echo "FAILED"
        git am --abort
    else
        echo "OK"
    fi
}

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPTDIR"

dir=".vim/bundle/vim-fugitive"
pushd "$dir" > /dev/null
    for patch in "$SCRIPTDIR/patches/$dir/"*.patch; do
        dopatch "$patch"
    done
popd > /dev/null
