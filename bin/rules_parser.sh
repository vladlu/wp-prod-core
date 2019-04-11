#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


rules_dir="$1"
project_ROOT="$2"
awk_delimiter="-F[ \t]*(\t)+[ \t]*"

mkdir "$rules_dir"


while IFS="" read -r line || [ -n "$line" ]
do
    cmd=$(echo "$line" | awk "$awk_delimiter" '{ print $1}')
    file="$rules_dir/$cmd.tsv"

    case "$cmd" in
    'substitute')
        echo "$line" | awk "$awk_delimiter" '{print $2 "\t" $3 "\t" $4}' >> "$file";;
    'copy')
        echo "$line" | awk "$awk_delimiter" '{print $3}'         >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $2 "\t" $3}' >> "$file";;
    'uglifyjs')
        echo "$line" | awk "$awk_delimiter" '{print             $4 $3}'                        >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print             $4 $2 "\t"             $4 $3}' >> "$rules_dir/maybe_rename.tsv"
        echo "$line" | awk "$awk_delimiter" '{print "../../../../" $4 $3 "\t" "../../../../" $4 $2}' >> "$file";;
    'webpack')
        echo "$line" | awk "$awk_delimiter" '{print $4 $3}'                        >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $4 $2 "\t"             $4 $3}' >> "$rules_dir/maybe_rename.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $4 $3 "\t" "../../../../" $4 $2}' >> "$file"

        if [[ $(echo "$line" | awk "$awk_delimiter" '{print $3}') == "style.css" ]]; then
            touch "$rules_dir/has_style_css"
        fi;;
    'install')
        echo "$line" | awk "$awk_delimiter" '{print $2}' >> "$file";;
    esac
done < "../rules"


# Expansions

find "$rules_dir" -mindepth 1 -exec bin/replace.sh '\[m\]' "dev/wp-prod/wp-prod/webpack/node_modules" {} \;
