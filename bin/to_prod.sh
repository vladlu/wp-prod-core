#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
devSystem_ROOT="$SCRIPTPATH/.."
project_ROOT="$devSystem_ROOT/../.."

rules_dir="$devSystem_ROOT/.rules.d"

lock="locks/prod"
unlock="locks/dev"


cd $devSystem_ROOT


if [ -d "webpack/node_modules" ]; then
    if [ ! -f "$lock" ]; then
        touch "$lock"
        rm -f "$unlock"

        bin/rules_parser.sh "$rules_dir"



        # mkdir

        if [ -f "$rules_dir/mkdir.tsv" ]; then
            while IFS='' read -r filepath
            do
                mkdir -p "$project_ROOT/$(dirname "$filepath")"
            done < "$rules_dir/mkdir.tsv"
        fi


        # Renaming

        if [ -f "$rules_dir/maybe_rename.tsv" ]; then
            while IFS=$'\t' read -r from to
            do
                if [[ "$from" != "dev/"* ]] && [[ "$to" != "dev/"* ]]; then
                    mv "$project_ROOT/$to" "$project_ROOT/$from"
                fi
            done < "$rules_dir/maybe_rename.tsv"
        fi



        if [ -f "$rules_dir/substitute.tsv" ]; then
            while IFS=$'\t' read -r dev prod file
            do
                sed -i '' -e "s/$dev/$prod/g" "$project_ROOT/$file"
            done < "$rules_dir/substitute.tsv"
        fi


        if [ -f "$rules_dir/new_dir.tsv" ]; then
            while IFS=$'\t' read -r dir
            do
                mkdir -p "$project_ROOT/$dir"
            done < "$rules_dir/new_dir.tsv"
        fi


        if [ -f "$rules_dir/copy.tsv" ]; then
            while IFS=$'\t' read -r from to
            do
                cp "$project_ROOT/$from" "$project_ROOT/$to"
            done < "$rules_dir/copy.tsv"
        fi


        cd webpack
        node start.js


        # Workaround for css file names from webpack

        cd "$SCRIPTPATH"


        if [ -f "$rules_dir/webpack.tsv" ]; then
            while IFS=$'\t' read -r to from
            do
                if [[ $to == *".css" ]]; then
                    mv "$project_ROOT/$to.css" "$project_ROOT/$to"
                fi
            done < "$rules_dir/webpack.tsv"
        fi


    else
        echo -e "\nIt's already prod!\n"
    fi
else
    echo -e "\nwebpack/node_modules is not found! Add it by running \"npm install\" in \"webpack\" directory.\n"
fi