#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
wp_prod_ROOT="$SCRIPTPATH/.."
project_ROOT="$wp_prod_ROOT/../../.."

rules_dir="$wp_prod_ROOT/.rules.d"


cd $wp_prod_ROOT


do_the_stuff() {
    if [ ! -d "locks" ]; then
        mkdir "locks"
    fi

    type="$(head -1 "$wp_prod_ROOT/../rules")" # "plugin" or "theme"


    bin/rules_parser.sh "$rules_dir" "$project_ROOT"


    # Installs additional node modules

    if [ -f "$rules_dir/install.tsv" ]; then
        while IFS=$'\t' read -r modulename
        do
            if [ ! -f "locks/$modulename" ]; then
                echo -e "\nIntalling $modulename module\n"

                npm install --prefix webpack "$modulename"


                touch "locks/$modulename" # Locks the module to not install it again
            fi
        done < "$rules_dir/install.tsv"
    fi



    # mkdir

    if [ -f "$rules_dir/mkdir.tsv" ]; then
        while IFS='' read -r filepath
        do
            mkdir -p "$project_ROOT/$(dirname "$filepath")"
        done < "$rules_dir/mkdir.tsv"
    fi



    # Copy

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



    # Adds theme metadata to the beginning of the minified style.css because cssnano removes all the comments.

    if [ "$type" = "theme" ] && [ -f "$rules_dir/has_style_css" ]; then
        regex="(\/\*)((.|\n)*?)Theme Name:((.|\n)*?)Author:((.|\n)*?)(\*\/)"
        theme_metadata=$(pcregrep -Mo "$regex" "$project_ROOT/style.dev.css")

        echo -e "$theme_metadata\n$(cat "$project_ROOT/style.css")" > "$project_ROOT/style.css"
    fi



    # Deletes generated rules

    rm -rf "$rules_dir"
}


if [ -x "$(command -v pcregrep)" ]; then
    if [ -d "webpack/node_modules" ]; then
        do_the_stuff
    else
        read -p "node_modules not found. Install them? (y/n) " -n 1 -r
        echo # new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            npm install --prefix "webpack/"
            do_the_stuff
        fi
    fi
else
    RED='\033[0;31m'
    NC='\033[0m'

    echo -e >&2 "\n${RED}pcregrep${NC} not found. Install it! \nTerminated.\n"
    exit 1
fi
