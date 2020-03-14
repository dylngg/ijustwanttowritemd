# ijustwanttowritemd

Write markdown. Then publish. Why do static site generators have to be so complicated?

## How?

1. Write your markdown page in a same named directory (`page-name/page-name.md`).
2. Publish. `./publish.sh page-name`
3. _(Optional:)_ Regenerate your Atom 1.0 feed. `./feed.sh .`

See `examples/` for an example. You can view it published [here](https://dylngg.github.io/ijustwanttowritemd/examples/catipsum/).

## Styling

The `header.html` and `footer.html` files in either each page directory or a shared directory (defaulted to the parent page directory if `-d/--dir` is not specified) are prepended and appended to the generated markdown html. You can change the styling of the resulting html by adding css and html to those files.

## Adding Metadata

You can add metadata to the resulting html by creating a `.meta` file (with the same name as the markdown file). This meta file contains lines of id value pairs separated by a "=" sign. The value will replace every occurence of a `$id` in the resulting html (where `id` is the id in the meta file). This metadata is also used for the `feed.sh` generator.

```
title=I just want to write Markdown.
author=Dylan Gardner
summary=Write markdown. Then publish. Why do static site generators have to be so complicated?
```

with

```html
<h1>$title</h1>
<p>Author: $author</p>
<span>$summary</span>
```

turns into

```html
<h1>I just want to write Markdown.</h1>
<p>Author: Dylan Gardner</p>
<span>Write markdown. Then publish. Why do static site generators have to be so complicated?</span>
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

        page2-name/
            ...

        header.html
        footer.html
```

```
$ ./feed.sh
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
```
