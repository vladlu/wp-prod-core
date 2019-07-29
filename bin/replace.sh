#!/usr/bin/env bash

##
# A core that implements replacement (deprecated) and expansions functionality. 
#
# Just parses the passed file(name), and replace there one passed text with another one.
#
# @param $1 Replace from.
# @param $2 Replace to.
# @param $3 A file to make the replacement.
##

set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


from="$1"
to="$2"
file="$3"
                                    # Escaping.                                  # Escaping.
sed -i.bak -e "s/$(echo "$from" | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo "$to" | sed -e 's/[\/&]/\\&/g')/g" "$file"
rm "$file.bak"
