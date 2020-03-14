#!/bin/bash
# Updates a Atom 1.0 feed.

print_help() {
    cat <<EOF
usage: feed.sh <web-dir>

Updates a Atom 1.0 feed.xml in the given directory (by default the current
directory). The site data is pulled from feed.meta, which contains key-value
pairs (key=value) and the entry data is generated from the sub-directories. If
.meta files are found in those subdirectories, that metadata is added to the
corresponding entry.

The site data must contain a link key-value pair used as the base url
(e.g. link=https://planet.kernel.org/), as well as a title key-value pair.

Web directory setup:
    Things should look like this in the web directory:
    ./
        feed.meta
        entry1/
            entry1.meta
            ...

        entry2/
            entry2.meta
            ...
EOF
    exit
}

die() {
    echo "$1" > /dev/stderr
    exit 1
}

webdir="$1"
if [ "$webdir" == "--help" ] || [ "$webdir" == "-h" ]; then
    print_help
elif [ "$webdir" == "" ]; then
    webdir="`pwd`"
elif [ ! -d "$webdir" ]; then
    die "Web directory is not a directory: $webdir"
fi

feed_meta="$webdir/feed.meta"
if [ ! -f "$feed_meta" ]; then
    die "No feed.meta in web directory: $feed_meta"
fi
# Define pads for pretty indenting
pad="  "
pad2="$pad$pad"

# Create the feed
feed="$webdir/feed.xml"
echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $feed
echo "<feed xmlns=\"http://www.w3.org/2005/Atom\">" >> $feed
echo "$pad<generator uri=\"https://github.com/dylngg/ijustwanttowritemd\">" >> $feed
echo "$pad<updated>`date -u '+%Y-%m-%dT%H:%M:%SZ'`</updated>" >> $feed

# FIXME: Add support for generator, icon, logo and optional feed elements
has_link=false
has_title=false
while read line; do
    id="`echo $line | cut -d '=' -f 1 | tr '[:upper:]' '[:lower:]'`"
    value="`echo $line | cut -d '=' -f 2-`"
    case "$id" in
        "link")
            has_link=true
            weblink="${value%/}"
            feedlink="$weblink/`basename $feed`"
            echo "$pad<id>$feedlink</id>" >> $feed
            echo "$pad<link rel=\"self\" href=\"$feedlink\"/>" >> $feed
            echo "$pad<link rel=\"alternative\" href=\"$weblink\"/>" >> $feed
            ;;
        "title")
            has_title=true
            echo "$pad<title>$value</title>" >> $feed
            ;;
        "author")
            echo "$pad<author>" >> $feed
            echo "$pad2<name>$value</name>" >> $feed
            echo "$pad</author>" >> $feed
            ;;
        *)
            echo "$pad<$id>$value</$id>" >> $feed
            ;;
    esac
done < "$feed_meta"

if ! $has_link; then
    rm $feed
    die "No 'link' key found in meta file: $feed_meta"
elif ! $has_title; then
    rm $feed
    die "No 'title' key found in meta file: $feed_meta"
fi

for entry_dir in $webdir/*; do
    if [ ! -d "$entry_dir" ]; then
        continue
    fi
    echo "$pad<entry>" >> $feed

    entry_name="`basename $entry_dir`"
    entry_meta="$entry_dir/$entry_name.meta"
    has_title=false
    if [ -f "$entry_meta" ]; then
        while read line; do
            id="`echo $line | cut -d '=' -f 1 | tr '[:upper:]' '[:lower:]'`"
            value="`echo $line | cut -d '=' -f 2-`"
            if [ "$id" = "title" ]; then
                has_title=true
            fi
            echo "$pad2<$id>$value</$id>" >> $feed
        done < "$entry_meta"
    fi

    if ! $has_title; then
        echo "$pad2<title>$entry_name</title>" >> $feed
    fi

    echo "$pad2<id>$weblink/$entry_name</id>" >> $feed
    echo "$pad2<link rel=\"alternative\" href=\"$weblink/$entry_name\"></id>" >> $feed
    echo "$pad2<updated>`date -r $entry_dir -u '+%Y-%m-%dT%H:%M:%SZ'`</updated>" >> $feed
    echo "$pad</entry>" >> $feed
done

echo "</feed>" >> $feed
