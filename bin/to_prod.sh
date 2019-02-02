#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH/.."

lock="locks/prod"
unlock="locks/dev"

rules_dir='.rules.d'

if [ -d "webpack/node_modules" ]; then
    if [ ! -f "$lock" ]; then
        touch "$lock"
        rm -f "$unlock"

        ../utilities/rules_parser "$rules_dir"



        # mkdir

        if [ -f "$rules_dir/mkdir.tsv" ]; then
            while IFS='' read -r filepath
            do
                mkdir -p "../$(dirname "$filepath")"
            done < "$rules_dir/mkdir.tsv"
        fi


        # Renaming

        if [ -f "$rules_dir/maybe_rename.tsv" ]; then
            while IFS=$'\t' read -r from to
            do
                if [[ "$from" != "dev/"* ]] && [[ "$to" != "dev/"* ]]; then
                    mv "../$to" "../$from"
                fi
            done < "$rules_dir/maybe_rename.tsv"
        fi



        if [ -f "$rules_dir/substitute.tsv" ]; then
            while IFS=$'\t' read -r dev prod file
            do
                sed -i '' -e "s/$dev/$prod/g" ../"$file"
            done < "$rules_dir/substitute.tsv"
        fi


        if [ -f "$rules_dir/new_dir.tsv" ]; then
            while IFS=$'\t' read -r dir
            do
                mkdir -p "../$dir"
            done < "$rules_dir/new_dir.tsv"
        fi


        if [ -f "$rules_dir/copy.tsv" ]; then
            while IFS=$'\t' read -r from to
            do
                cp "../$from" "../$to"
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
                    mv "../$to.css" "../$to"
                fi
            done < "$rules_dir/webpack.tsv"
        fi


    else
        echo -e "\nWhoops. It's already prod!\n"
    fi
else
    echo -e "\nwebpack/node_modules is not found! Add it by running \"npm install\" in \"webpack\" directory.\n"
fi