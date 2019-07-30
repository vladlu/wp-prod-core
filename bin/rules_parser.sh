#!/usr/bin/env bash

##
# Parses the rules. Chews them for another scripts.
#
# @param $1 Directory: Where the rules are located.
# @param $2 Directory: Root of the project.
# @param $3 Type of the project (theme or plugin).
##

set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


rules_dir="$1"
project_ROOT="$2"
type="$3"
awk_delimiter="-F[ \t]*(\t)+[ \t]*"

mkdir "$rules_dir"


if [[ "$type" == "theme" ]]; then
    touch "$rules_dir/theme"

    if [[ -f "$project_ROOT/style.dev.css" ]]; then
        echo -e "style.css\t../../../../style.dev.css" >> "$rules_dir/webpack.tsv"
    fi
elif [[ "$type" == "plugin" ]]; then
    touch "$rules_dir/plugin"
fi


while IFS="" read -r line || [[ -n "$line" ]]
do
    cmd=$(echo "$line" | awk "$awk_delimiter" '{print $1}')
    file="$rules_dir/$cmd.tsv"

    case "$cmd" in
    'copy')

        echo "$line" | awk "$awk_delimiter" '{print $3}'         >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $2 "\t" $3}' >> "$file";;

    'uglifyjs')

        # If the line has 3 columns.
        if [[ $(echo "$line" | awk "$awk_delimiter" '{print $3}') ]]; then
            echo "$line" | awk "$awk_delimiter" '{print $3}' >> "$rules_dir/mkdir.tsv"
        # Otherwise it's assumed that it has 2 columns.
        else
            # Then converts it to 3 columns.
            column1=$(echo "$line" | awk "$awk_delimiter" '{print $1}')
            column2=$(echo "$line" | awk "$awk_delimiter" '{print $2}')
            extension=${column2##*.}
                    # Adds dev before the extension so the origin file will be renamed to it on prod conversion.
            column3="${column2%.$extension}.min.$extension"
            line=$( echo -e "$column1 \t $column2 \t $column3" )
        fi

        echo "$line" | awk "$awk_delimiter" '{print "../../../../" $3 "\t" "../../../../" $2}' >> "$file";;

    'webpack')

        # If the line has 3 columns.
        if [[ $(echo "$line" | awk "$awk_delimiter" '{print $3}') ]]; then
            echo "$line" | awk "$awk_delimiter" '{print $3}' >> "$rules_dir/mkdir.tsv"
        # Otherwise it's assumed that it has 2 columns.
        else
            # Then converts it to 3 columns.
            column1=$(echo "$line" | awk "$awk_delimiter" '{print $1}')
            column2=$(echo "$line" | awk "$awk_delimiter" '{print $2}')
            extension=${column2##*.}
                    # Adds dev before the extension so the origin file will be renamed to it on prod conversion.
            column3="${column2%.$extension}.min.$extension"
            line=$( echo -e "$column1 \t $column2 \t $column3" )
        fi

        echo "$line" | awk "$awk_delimiter" '{print $3 "\t" "../../../../" $2}' >> "$file";;

    'install')

        echo "$line" | awk "$awk_delimiter" '{print $2}' >> "$file";;

    esac
done < "../rules"


# Expansions.

find "$rules_dir" -mindepth 1 -exec 'bin/replace.sh' '\[m\]' 'dev/wp-prod/wp-prod-core/webpack/node_modules' {} \;
