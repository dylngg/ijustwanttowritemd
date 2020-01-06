# ijustwanttowritemd

Write markdown. Then publish. Why do static site generators have to be so complicated?

## How?

1. Write your markdown page in a same named directory.
2. Publish. `./publish.sh directory-name`

See `examples/` for an example. You can view it published [here](https://dylngg.github.io/ijustwanttowritemd/examples/catipsum/).

## Styling

The `header.html` and `footer.html` files in the page directory or it's parent directory if not found are just prepended and appended to the markdown html. You can change the styling of the resulting html by adding css and html to those files. See the `examples/` folder.

## Adding Metadata

You can add metadata to the resulting html by creating a `.meta` file (named the same as the markdown file) to the `./publish.sh`. This meta file contains lines of id value pairs separated by a "=" sign. The value will replace every occurence of a `$id` in the resulting html (where `id` is the id in the meta file).

```
title=I just want to write Markdown.
author=Dylan Gardner
```

## The Devil in the Details

```
$ ./publish.sh
usage: publish.sh <page-dir> [flags ...]

Publishes the markdown in a given directory to a html page by prepending a
header.html and appending a footer.html (by default found in the page's
directory and if not found, it's parent directory). Optionally, key-value pair
(key=value) metadata can be used in html and markdown files by using a "$key"
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
```
