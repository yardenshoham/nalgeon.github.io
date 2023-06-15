+++
date = 2022-01-04T13:00:00Z
title = "The Ultimate SQLite Extension Set"
description = "Regexes, math, file IO and over 100 other functions."
image = "/sqlean/cover.png"
slug = "sqlean"
tags = ["sqlite", "data"]
featured = true
+++

I really like SQLite. It's a miniature embedded database, perfect for both exploratory data analysis and as a storage for small apps (I've [blogged about that](/sqlite-is-not-a-toy-database/) previously).

It has a minor drawback though. There are few built-in functions compared to PostgreSQL or Oracle. Fortunately, the authors provided an extension mechanism, which allows doing almost anything. As a result, there are a lot of SQLite extensions out there, but they are incomplete, inconsistent and scattered across the internet.

I wanted more consistency. So I started the **sqlean** project, which brings the extensions together, neatly packaged into domain modules, documented, tested, and built for Linux, Windows and macOS. Something like a standard library in Python or Go, only for SQLite.

I plan to write in detail about each module in a separate article, but for now — here's a brief overview.

## Main set

These are the most popular functions. They are tested, documented and organized into the domain modules with clear API.

Think of them as the extended standard library for SQLite:

-   [crypto](/sqlean-encode/): Hashing, encoding and decoding data.
-   [define](/sqlean-define/): User-defined functions and dynamic SQL.
-   [fileio](/sqlean-fileio/): Reading and writing files and catalogs.
-   [fuzzy](https://github.com/nalgeon/sqlean/blob/main/docs/fuzzy.md): Fuzzy string matching and phonetics.
-   [ipaddr](https://github.com/nalgeon/sqlean/blob/main/docs/ipaddr.md): IP address manipulation.
-   [math](https://github.com/nalgeon/sqlean/blob/main/docs/math.md): Math functions.
-   [regexp](/sqlean-regexp/): Pattern matching using regular expressions.
-   [stats](https://github.com/nalgeon/sqlean/blob/main/docs/stats.md): Math statistics — median, percentiles, etc.
-   [text](/sqlean-text/): Advanced string functions.
-   [unicode](https://github.com/nalgeon/sqlean/blob/main/docs/unicode.md): Unicode support.
-   [uuid](https://github.com/nalgeon/sqlean/blob/main/docs/uuid.md): Universally Unique IDentifiers.
-   [vsv](https://github.com/nalgeon/sqlean/blob/main/docs/vsv.md): CSV files as virtual tables.

The single-file `sqlean` bundle contains all extensions from the main set.

There are [precompiled binaries](https://github.com/nalgeon/sqlean/releases/latest) for Windows, Linix and macOS.

## Incubator

These extensions haven't yet made their way to the main set. They may be untested, poorly documented, too broad, too narrow, or without a well-thought API.

Think of them as candidates for the standard library:

-   [array](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004109889): one-dimensional arrays.
-   [besttype](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999732640): convert string value to numeric.
-   [bloom](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002267134): a fast way to tell if a value is already in a table.
-   [btreeinfo](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004896027), [memstat](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007421989), [recsize](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999732907) and [stmt](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007654407): various database introspection features.
-   [classifier](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001239676): binary classifier via logistic regression.
-   [closure](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004931771): navigate hierarchic tables with parent/child relationships.
-   [compress](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000937999) and [sqlar](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000938046): compress / uncompress data.
-   [cron](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997427979): match dates against cron patterns.
-   [dbdump](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1006791300): export database as SQL.
-   [decimal](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007348326), [fcmp](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997482625) and [ieee754](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007375162): decimal and floating-point arithmetic.
-   [envfuncs](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997423609): read environment variables.
-   [eval](https://github.com/nalgeon/sqlean/issues/27#issuecomment-996432840): run arbitrary SQL statements.
-   [isodate](https://github.com/nalgeon/sqlean/issues/27#issuecomment-998138191): additional date and time functions.
-   [json1](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1593490593): JSON functions
-   [math2](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999128539): additional math functions and bit arithmetics
-   [path](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1252243356): parsing and querying paths
-   [pearson](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997417836): Pearson correlation coefficient between two data sets.
-   [pivotvtab](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997052157): pivot tables.
-   [prefixes](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007464840): generate string prefixes.
-   [rotate](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007500659): string obfuscation.
-   [spellfix](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002297477): search a large vocabulary for close matches.
-   [stats2](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000902666) and [stats3](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002703581): additional math statistics functions.
-   [uint](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001232670): natural string sorting and comparison.
-   [unhex](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997432989): reverse for `hex()`.
-   [unionvtab](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007687162): union similar tables into one.
-   [xmltojson](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997018486): convert XML to JSON string.
-   [zipfile](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001190336): read and write zip files.
-   [zorder](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007733209): map multidimensional data to a single dimension.

Incubator extensions are also available [for download](https://github.com/nalgeon/sqlean/releases/tag/incubator).

## How to install an extension

The easiest way to try out the extensions is to use the [pre-bundled shell](https://github.com/nalgeon/sqlean/blob/main/docs/shell.md). But you can also load them individually.

First, [download](https://github.com/nalgeon/sqlean/releases/latest) the extension. Then load it as described below.

Examples use the `stats` extension; you can specify any other supported extension. To load all extensions at once, use the single-file `sqlean` bundle.

### Command-line or IDE

SQLite command-line interface (CLI, aka 'sqlite3.exe' on Windows):

```
sqlite> .load ./stats
sqlite> select median(value) from generate_series(1, 99);
```

IDE, e.g. SQLiteStudio, SQLiteSpy or DBeaver:

```
select load_extension('c:\Users\anton\sqlite\stats.dll');
select median(value) from generate_series(1, 99);
```

_Note for macOS users_. macOS may disable unsigned binaries and prevent the extension from loading. To resolve this issue, remove the extension from quarantine by running the following command in Terminal (replace `/path/to/folder` with an actual path to the folder containing the extension):

```
xattr -d com.apple.quarantine /path/to/folder/stats.dylib
```

Also note that the "stock" SQLite CLI on macOS does not support extensions. Use the [custom build](https://github.com/nalgeon/sqlite).

### Python

Install the [`sqlean.py`](/sqlean-py) package, which is a drop-in replacement for the default `sqlite3` module:

```
pip install sqlean.py
```

All extensions from the main set are already enabled:

```python
import sqlean as sqlite3

conn = sqlite3.connect(":memory:")
conn.execute("select median(value) from generate_series(1, 99)")
conn.close()
```

You can also use the default `sqlite3` module and load extensions manually:

```python
import sqlite3

conn = sqlite3.connect(":memory:")
conn.enable_load_extension(True)
conn.load_extension("./stats")
conn.execute("select median(value) from generate_series(1, 99)")
conn.close()
```

_Note for macOS users_. "Stock" SQLite on macOS does not support extensions, so the default `sqlite3` module won't work. Use the `sqlean.py` package.

### Node.js

Using [`better-sqlite3`](https://github.com/WiseLibs/better-sqlite3):

```js
const sqlite3 = require("better-sqlite3");
const db = new sqlite3(":memory:");
db.loadExtension("./stats");
db.exec("select median(value) from generate_series(1, 99)");
db.close();
```

## Next steps

If you feel that you are missing some function in SQLite, check the [**sqlean**](https://github.com/nalgeon/sqlean) repository — you'll probably find one.

If you want to participate, submit [your own](https://github.com/nalgeon/sqlean/blob/incubator/docs/submit.md) or [third-party](https://github.com/nalgeon/sqlean/blob/incubator/docs/external.md) extensions.

I keep adding new extensions to the incubator. I also refactor the extensions from the incubator and merge them into the main set. I plan to write a separate article for each major extension, so stay tuned.

SQLite FTW!
