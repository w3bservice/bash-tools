#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2019-01-02 21:08:12 +0000 (Wed, 02 Jan 2019)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

if [ -z "${PASS:-}" ]; then
    read -s -p 'password: ' PASS
    echo
fi

# doesn't work
#netrc_content="default login $USER password $PASS"

hosts="$(awk '{print $1}' < ~/.ssh/known_hosts 2>/dev/null | sed 's/,.*//' | sort -u)"
netrc_contents="$(for host in $hosts; do cat <<< "machine $host login $USER password $PASS"; done)"

curl --netrc-file <(cat <<< "$netrc_contents") "$@"
