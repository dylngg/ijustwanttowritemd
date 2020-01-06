#!/bin/bash
# Publishes markdown into web pages.

print_help() {
    cat <<EOF
usage: publish.sh <page-dir> [flags ...]

Publishes the markdown in a given directory to a html page by prepending a
header.html and appending a footer.html (by default found in the page's
directory and if not found, it's parent directory). Optionally, key-value pair
(key=value) metadata can be used in html and markdown files by using a "\$key"
syntax, where the key can be found in the page directory's .meta file.

optional flags:
    -d, --dir               Override the header and footer html directory.
    -h, --help              Show this help output.

Default directory setup:
    Things should look like this if the -d flag is not given:
    ./
        page-name/
            page-name.md
            page-name.meta
            index.html (after ./publish.sh page-name)
            header.html (optional, overrides ../header.html)
            footer.html (optional, overrides ../footer.html)
        header.html
        footer.html
EOF
    exit
}

die() {
    echo "$1" > /dev/stderr
    exit 1
}

pagedir="$1"
parent_pagedir="`dirname $pagedir`"
if [ "$pagedir" == "" ]; then
    die "No page directory given"
elif [ "$pagedir" == "--help" ] || [ "$pagedir" == "-h" ]; then
    print_help
elif [[ $pagedir == -* ]]; then
    die "No page directory given (must be the first argument)"
elif [ ! -d "$pagedir" ]; then
    die "Page directory '$pagedir' is not a directory"
fi

# A bit ugly, but needed for portable way to get short and long options
while getopts "hd:-:" "arg"; do
    case $arg in
        h) print_help;;
        d) parent_pagedir="$OPTARG";;
        -) LONG_OPTARG="${OPTARG#*=}"
            case $OPTARG in
                help) print_help;;
                dir=?*) parent_pagedir="$LONG_OPTARG";;
                dir*)
                    echo "No arg for --$OPTARG option" > /dev/stderr
                    exit 2
                    ;;
                '') break;;
                *)
                    echo "Illegal option --$OPTARG" > /dev/stderr
                    exit 2
                    ;;
            esac;;
        \?) exit 2;;
    esac
done
shift $((OPTIND-1))

pagename="`basename $pagedir`"
md_filepath="$pagedir/$pagename.md"
if [ ! -f "$md_filepath" ]; then
    die "no markdown file '$pagename.md' found in $pagedir"
fi

header_filepath="$pagedir/header.html"
footer_filepath="$pagedir/footer.html"
html_filepath="$pagedir/index.html"
if [ ! -f $header_filepath ]; then
    header_filepath="$parent_pagedir/header.html"
    if [ ! -f $header_filepath ]; then
        die "'header.html' not found in $pagedir"
    fi
elif [ ! -f $footer_filepath ]; then
    footer_filepath="$parent_pagedir/footer.html"
    if [ ! -f $footer_filepath ]; then
        die "'footer.html' not found in $pagedir"
    fi
fi

cat $header_filepath > $html_filepath
./Markdown.pl $md_filepath >> $html_filepath
cat $footer_filepath >> $html_filepath

meta_filepath="$pagedir/$pagename.meta"
if [ ! -f "$md_filepath" ]; then
    exit 0
fi

while read line; do
    id="`echo $line | cut -d '=' -f 1`"
    value="`echo $line | cut -d '=' -f 2`"
    # Replace $id with value
    sed -i '' -E 's|\$'"$id"'|'"$value"'|g' $html_filepath
done < $meta_filepath
