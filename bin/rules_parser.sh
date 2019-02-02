#!/usr/bin/env bash


##
# This script adds a newline to the end of all *.tsv files 
# in the specified dir & subdirs if they don't have it.
##

rules_dir=$1
awk_delimiter="-F[ \t]*(\t)+[ \t]*"

mkdir "$rules_dir"


while IFS="" read -r line || [ -n "$line" ]
do
    cmd=$(echo "$line" | awk "$awk_delimiter" '{ print $1}')
    file="$rules_dir/$cmd.tsv"

    case "$cmd" in
    'new_dir')
        echo "$line" | awk "$awk_delimiter" '{print $2}' >> "$file";;
    'substitute')
        echo "$line" | awk "$awk_delimiter" '{print $2 "\t" $3 "\t" $4}' >> "$file";;
    'copy')
        echo "$line" | awk "$awk_delimiter" '{print $3}'         >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $2 "\t" $3}' >> "$file";;
    'uglifyjs')
        echo "$line" | awk "$awk_delimiter" '{print             $4 $3}'                        >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print             $4 $2 "\t"             $4 $3}' >> "$rules_dir/maybe_rename.tsv"
        echo "$line" | awk "$awk_delimiter" '{print "../../../" $4 $3 "\t" "../../../" $4 $2}' >> "$file";;
    'webpack')
        echo "$line" | awk "$awk_delimiter" '{print $4 $3}'                        >> "$rules_dir/mkdir.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $4 $2 "\t"             $4 $3}' >> "$rules_dir/maybe_rename.tsv"
        echo "$line" | awk "$awk_delimiter" '{print $4 $3 "\t" "../../../" $4 $2}' >> "$file";;
    esac
done < "../_devSystem/rules"
