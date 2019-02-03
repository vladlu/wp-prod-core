#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
wp_prod_ROOT="$SCRIPTPATH/.."
project_ROOT="$wp_prod_ROOT/../.."

rules_dir="$wp_prod_ROOT/.rules.d"

lock="locks/dev"
unlock="locks/prod"


cd $wp_prod_ROOT


if [ ! -f "$lock" ]; then
    touch "$lock"
    rm -f "$unlock"


    # Renaming back

    if [ -f "$rules_dir/maybe_rename.tsv" ]; then
        while IFS=$'\t' read -r from to
        do
            if [[ "$from" != "dev/"* ]] && [[ "$to" != "dev/"* ]]; then
                mv "$project_ROOT/$from" "$project_ROOT/$to"
            fi
        done < "$rules_dir/maybe_rename.tsv"
    fi


    # Substitute

    if [ -f "$rules_dir/substitute.tsv" ]; then
        while IFS=$'\t' read -r dev prod file
        do
            sed -i '' -e "s/$prod/$dev/g" "$project_ROOT/$file"
        done < "$rules_dir/substitute.tsv"
    fi


    rm -rf "$rules_dir"
else
    echo -e "\nIt's already dev!\n"
fi
