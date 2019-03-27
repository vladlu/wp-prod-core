#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo >&2 "ERROR on line $LINENO ($(tail -n+$LINENO $0 | head -n1)). Terminated."' ERR


SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
wp_prod_ROOT="$SCRIPTPATH/.."
project_ROOT="$wp_prod_ROOT/../.."

rules_dir="$wp_prod_ROOT/.rules.d"

lock="locks/prod"
unlock="locks/dev"


cd $wp_prod_ROOT


do_the_stuff() {
    if [ ! -f "$lock" ]; then
        touch "$lock"
        rm -f "$unlock"

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


        # Renaming

        if [ -f "$rules_dir/maybe_rename.tsv" ]; then
            while IFS=$'\t' read -r from to
            do
                if [[ "$from" != "dev/"* ]] && [[ "$to" != "dev/"* ]]; then
                    mv "$project_ROOT/$to" "$project_ROOT/$from"
                fi
            done < "$rules_dir/maybe_rename.tsv"
        fi



        # Substitute

        if [ -f "$rules_dir/substitute.tsv" ]; then
            while IFS=$'\t' read -r dev prod file
            do
                bin/replace.sh "$dev" "$prod" "$project_ROOT/$file"
            done < "$rules_dir/substitute.tsv"
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



        # Adds theme metadata to the beginning of the minified style.css, because cssnano removes all comments.

        if [ -f "$rules_dir/has_style_css" ]; then
            regex="(\/\*)((.|\n)*?)Theme Name:((.|\n)*?)Author:((.|\n)*?)(\*\/)"
            theme_metadata=$(pcregrep -Mo "$regex" "$project_ROOT/style.dev.css")

            echo -e "$theme_metadata\n$(cat "$project_ROOT/style.css")" > "$project_ROOT/style.css"
        fi
    else
        echo -e "\nIt's already prod!\n"
    fi
}


if [ -x "$(command -v pcregrep)" ]; then
    if [ -d "webpack/node_modules" ]; then
        do_the_stuff
    else
        read -p "webpack/node_modules is not found. Install it? (y/n) " -n 1 -r
        echo # new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            npm install --prefix "webpack/"
            do_the_stuff
        fi
    fi
else
    RED='\033[0;31m'
    NC='\033[0m'

    echo -e "\n${RED}pcregrep${NC} not found. Install it! \n\n Aborted."
fi
