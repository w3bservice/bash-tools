#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2018-01-12 19:13:34 +0000 (Fri, 12 Jan 2018)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Script to find a hanging mount point on Linux (often caused by NFS)

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
#srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage(){
    echo "${0##*/} [ --include <posix_regex> ] [ --exclude <posix_regex> ]
"
}

include_regex=".*"
exclude_regex=""

until [ $# -lt 1 ]; do
    case $1 in
        -i|--include) include_regex="$2"
                      shift
                      ;;
        -e|--exclude) exclude_regex="$2"
                      shift
                      ;;
         *) usage
            ;;
    esac
    shift
done

if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: this only runs on Linux"
    exit 1
fi

if ! [ -f /proc/mounts ]; then
    echo "Error: /proc/mounts not found"
    exit 1
fi

# TODO: switch to awk to filter output just mountpoint
awk '{print $2}' /proc/mounts |
egrep -v ' cgroup ' |
egrep "$include_regex" |
egrep "$exclude_regex" |
while read mountpoint; do
    [ -d "$mountpoint" ] || continue
    if [ "$mountpoint" = "/proc" \
      -o "$mountpoint" = "/sys" \
      -o "$mountpoint" = "/dev" \
      -o "${mountpoint:0:6}" = "/proc/" \
      -o "${mountpoint:0:5}" = "/sys/" \
      -o "${mountpoint:0:5}" = "/dev/" ]; then
        continue
    fi
    echo -n "$mountpoint:  "
    ls -l "$mountpoint" &>/dev/null
    echo "OK"
done
echo "Finished"
