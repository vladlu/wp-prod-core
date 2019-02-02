#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH/.."

lock="locks/dev"
unlock="locks/prod"

rules_dir='.rules.d'


if [ ! -f "$lock" ]; then
    touch "$lock"
    rm -f "$unlock"


    # Renaming back

    if [ -f "$rules_dir/maybe_rename.tsv" ]; then
        while IFS=$'\t' read -r from to
        do
            if [[ "$from" != "dev/"* ]] && [[ "$to" != "dev/"* ]]; then
                mv "../$from" "../$to"
            fi
        done < "$rules_dir/maybe_rename.tsv"
    fi



    if [ -f "$rules_dir/substitute.tsv" ]; then
        while IFS=$'\t' read -r dev prod file
        do
            sed -i '' -e "s/$prod/$dev/g" ../"$file"
        done < "$rules_dir/substitute.tsv"
    fi


    rm -rf "$rules_dir"
else
    echo -e "\nWhoops. It's already dev!\n"
fi
