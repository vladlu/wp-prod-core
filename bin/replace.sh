#!/usr/bin/env bash

##
# A core that implements expansions functionality. 
#
# Just parses for the passed text and replaces it with another passed text in the passed file.
##

set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


from="$1"
to="$2"
file="$3"
                                    # Escaping.                                  # Escaping.
sed -i.bak -e "s/$(echo $from | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $to | sed -e 's/[\/&]/\\&/g')/g" "$file"
rm "$file.bak"
