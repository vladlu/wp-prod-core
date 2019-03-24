#!/usr/bin/env bash
set -Eeuo pipefail


from="$1"
to="$2"
file="$3"
                                    # Escaping                                  # Escaping
sed -i.bak -e "s/$(echo $from | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $to | sed -e 's/[\/&]/\\&/g')/g" "$file"
rm "$file.bak"