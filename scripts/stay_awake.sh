#!/bin/sh -e
#
# Keep OSX from falling asleep for n hours
# Replaces Caffeine.app for Mojave
# You may want to `alias awake="path/to/stay_awake.sh &"`
#

function cleanup {
    # remove the lockfile after caffeinate exits
    rm $LOCKFILE
}

function usage {
    echo "Usage: $0 [-h HOURS] [-q] [-f]

Keep OSX awake for H hours. Defaults to 5.

    -h: specify a different int hours to stay awake.
    -q: nuke an existing lockfile and exit.
    -f: force. If caffeinate is already running, kill it and start anew.
"
}

while getopts "h:qf" opt; do
    case "$opt" in
        h)
            HOURS=${OPTARG}
            ;;
        q)
            cleanup
            exit 0
            ;;
        f)
            FORCE=1
            ;;
        *)
            usage
            exit 1
    esac
done

HOURS=${HOURS:-5}
FORCE=${FORCE:-0}
SECONDS=`expr $HOURS \* 3600`
UNTIL=`date -v +${HOURS}H`
LOCKFILE="$HOME/.awake"

if [ -f $LOCKFILE ] ; then
    if [ ${FORCE} -ne 1 ] ; then
        cat $LOCKFILE
        exit 0
    fi
    echo "Killing previous caffeinate run..."
    killall caffeinate
    cleanup
fi

echo "Already staying awake until $UNTIL; use -f to force" > $LOCKFILE
echo "Staying awake until $UNTIL"
caffeinate -dimsu -t $SECONDS && say caffeinate done
cleanup
