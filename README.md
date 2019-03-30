# ijustwanttowritemd

Write markdown. Then publish. Why do static site generators have to be so complicated?

## How?

1. Write your markdown file.
2. Publish. `./publish.sh source.md dest.html`

See `examples/` for some examples.

## Styling

The `header.html` and `footer.html` files in the source.md directory are just prepended and appended to the markdown html. You can change the styling of the resulting html by adding css and html to those files. See the `examples/` folder.

## Adding Metadata

You can add metadata to the resulting html by appending a `*.meta` file path to the `./publish.sh` command (e.g. `./publish.sh source.md dest.html source.meta`. This meta file contains lines of id value pairs separated by a "=" sign. The value will replace every occurence of a `$id` in the resulting html (where `id` is the id in the meta file).

```
title=I just want to write Markdown.
author=Dylan Gardner
```

