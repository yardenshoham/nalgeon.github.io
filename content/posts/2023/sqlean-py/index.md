+++
date = 2023-06-15T21:30:00Z
title = "Python's sqlite3 with extensions"
description = "A drop-in replacement for the sqlite3 module, bundled with essential extensions."
image = "/sqlean-py/cover.png"
slug = "sqlean-py"
tags = ["sqlite"]
+++

Adding SQLite extensions with Python's `sqlite3` module is a breeze. Download a file, call a few functions, and you are good to go. Unless you try to do it on macOS, where `sqlite3` is compiled without extension support.

I wanted to make the process even easier (and of course solve the macOS problem). So I created the [`sqlean.py`](https://github.com/nalgeon/sqlean.py) package: a drop-in replacement for the standard library's `sqlite3` module, bundled with the [essential extensions](/sqlean/).

## Installation and usage

All you need to do is `pip install` the package:

```
pip install sqlean.py
```

And use it just like you'd use `sqlite3`:

```
import sqlean as sqlite3

# has the same API as the default `sqlite3` module
conn = sqlite3.connect(":memory:")
conn.execute("create table employees(id, name)")

# and comes with the `sqlean` extensions
cur = conn.execute("select median(value) from generate_series(1, 99)")
print(cur.fetchone())
# (50.0,)

conn.close()
```

Note that the package name is `sqlean.py`, while the code imports are just `sqlean`. The `sqlean` package name was taken by some zomby project and the author seemed to be unavailable, so I had to add the `.py` suffix.

## Extensions

`sqlean.py` contains 12 essential SQLite extensions:

-   [crypto](/sqlean-encode/): Hashing, encoding and decoding data
-   [define](/sqlean-define/): User-defined functions and dynamic SQL
-   [fileio](/sqlean-fileio/): Reading and writing files
-   [fuzzy](https://github.com/nalgeon/sqlean/blob/main/docs/fuzzy.md): Fuzzy string matching and phonetics
-   [ipaddr](https://github.com/nalgeon/sqlean/blob/main/docs/ipaddr.md): IP address manipulation
-   [math](https://github.com/nalgeon/sqlean/blob/main/docs/math.md): Math functions
-   [regexp](/sqlean-regexp/): Regular expressions
-   [stats](https://github.com/nalgeon/sqlean/blob/main/docs/stats.md): Math statistics
-   [text](/sqlean-text/): Advanced string functions
-   [unicode](https://github.com/nalgeon/sqlean/blob/main/docs/unicode.md): Unicode support
-   [uuid](https://github.com/nalgeon/sqlean/blob/main/docs/uuid.md): Universally Unique IDentifiers
-   [vsv](https://github.com/nalgeon/sqlean/blob/main/docs/vsv.md): CSV files as virtual tables

## Platforms

The package is available for the following operating systems:

-   Windows (64-bit)
-   Linux (64-bit)
-   macOS (both Intel and Apple processors)

You can also compile it from source if necessary.

See the [package repo](https://github.com/nalgeon/sqlean.py) for details.
