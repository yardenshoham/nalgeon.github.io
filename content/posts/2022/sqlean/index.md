+++
date = 2022-01-04T13:00:00Z
title = "The ultimate SQLite extension set"
description = "Regexes, math, file IO and over 100 other functions."
image = "/sqlean/cover.png"
slug = "sqlean"
tags = ["sqlite", "data"]
+++

I really like SQLite. It's a miniature embedded database, perfect for both exploratory data analysis and as a storage for small apps (I've [blogged about that](/sqlite-is-not-a-toy-database/) previously).

It has a minor drawback though. There are few built-in functions compared to PostgreSQL or Oracle. Fortunately, the authors provided an extension mechanism, which allows doing almost anything. As a result, there are a lot of SQLite extensions out there, but they are incomplete, inconsistent and scattered across the internet.

I wanted more consistency. So I started the **sqlean** project, which brings the extensions together, neatly packaged into domain modules, documented, tested, and built for Linux, Windows and macOS. Something like a standard library in Python or Go, only for SQLite.

I plan to write in detail about each module in a separate article, but for now — here's a brief overview.

## The main set

These are the most popular functions missing in SQLite:

-   [crypto](https://github.com/nalgeon/sqlean/blob/main/docs/crypto.md): cryptographic hashes like MD5 or SHA-256.
-   [fileio](https://github.com/nalgeon/sqlean/blob/main/docs/fileio.md): read and write files and catalogs.
-   [fuzzy](https://github.com/nalgeon/sqlean/blob/main/docs/fuzzy.md): fuzzy string matching and phonetics.
-   [ipaddr](https://github.com/nalgeon/sqlean/blob/main/docs/ipaddr.md): IP address manipulation.
-   [json1](https://github.com/nalgeon/sqlean/blob/main/docs/json1.md): JSON functions.
-   [math](https://github.com/nalgeon/sqlean/blob/main/docs/math.md): math functions.
-   [re](https://github.com/nalgeon/sqlean/blob/main/docs/re.md): regular expressions.
-   [stats](https://github.com/nalgeon/sqlean/blob/main/docs/stats.md): math statistics — median, percentiles, etc.
-   [text](https://github.com/nalgeon/sqlean/blob/main/docs/text.md): string functions.
-   [unicode](https://github.com/nalgeon/sqlean/blob/main/docs/unicode.md): Unicode support.
-   [uuid](https://github.com/nalgeon/sqlean/blob/main/docs/uuid.md): Universally Unique IDentifiers.
-   [vsv](https://github.com/nalgeon/sqlean/blob/main/docs/vsv.md): CSV files as virtual tables.

There are [precompiled binaries](https://github.com/nalgeon/sqlean/releases/latest) for Windows, Linix and macOS.

## The incubator

These extensions haven't yet made their way to the main set. They may be too broad, too narrow, or without a well-thought API. I'm gradually refactoring and merging them into the main set:

-   [array](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004109889): one-dimensional arrays.
-   [besttype](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999732640): convert string value to numeric.
-   [bloom](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002267134): a fast way to tell if a value is already in a table.
-   [btreeinfo](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004896027), [memstat](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007421989), [recsize](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999732907) and [stmt](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007654407): various database introspection features.
-   [cbrt](https://github.com/nalgeon/sqlean/issues/27#issuecomment-996605444) and [math2](https://github.com/nalgeon/sqlean/issues/27#issuecomment-999128539): additional math functions and bit arithmetics.
-   [classifier](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001239676): binary classifier via logistic regression.
-   [closure](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004931771): navigate hierarchic tables with parent/child relationships.
-   [compress](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000937999) and [sqlar](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000938046): compress / uncompress data.
-   [cron](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997427979): match dates against cron patterns.
-   [dbdump](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1006791300): export database as SQL.
-   [decimal](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007348326), [fcmp](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997482625) and [ieee754](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007375162): decimal and floating-point arithmetic.
-   [define](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1004347222): create scalar and table-valued functions from SQL.
-   [envfuncs](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997423609): read environment variables.
-   [eval](https://github.com/nalgeon/sqlean/issues/27#issuecomment-996432840): run arbitrary SQL statements.
-   [isodate](https://github.com/nalgeon/sqlean/issues/27#issuecomment-998138191): additional date and time functions.
-   [pearson](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997417836): Pearson correlation coefficient between two data sets.
-   [pivotvtab](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997052157): pivot tables.
-   [prefixes](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007464840): generate string prefixes.
-   [rotate](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007500659): string obfuscation.
-   [spellfix](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002297477): search a large vocabulary for close matches.
-   [stats2](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1000902666) and [stats3](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1002703581): additional math statistics functions.
-   [text2](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1003105288): additional string functions.
-   [uint](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001232670): natural string sorting and comparison.
-   [unhex](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997432989): reverse for `hex()`.
-   [unionvtab](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007687162): union similar tables into one.
-   [xmltojson](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997018486): convert XML to JSON string.
-   [zipfile](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1001190336): read and write zip files.
-   [zorder](https://github.com/nalgeon/sqlean/issues/27#issuecomment-1007733209): map multidimensional data to a single dimension.

[Vote for your favorites](https://github.com/nalgeon/sqlean/issues/27)! Popular ones will make their way into the main set faster.

Incubator extensions are also available [for download](https://github.com/nalgeon/sqlean/releases/tag/incubator).

## How to load an extension

There are three ways to do it. If you are using SQLite CLI (`sqlite.exe`):

```sql
sqlite> .load ./stats
sqlite> select median(value) from generate_series(1, 99);
```

If you are using a tool like DB Browser for SQLite, SQLite Expert or DBeaver:

```sql
select load_extension('c:\Users\anton\sqlite\stats.dll');
select median(value) from generate_series(1, 99);
```

If you are using Python (other languages provide similar means):

```python
import sqlite3

connection = sqlite3.connect(":memory:")
connection.enable_load_extension(True)
connection.load_extension("./stats.so")
connection.execute("select median(value) from generate_series(1, 99)")
connection.close()
```

## Next steps

If you feel that you are missing some function in SQLite, check the [**sqlean**](https://github.com/nalgeon/sqlean) repository — you'll probably find one.

If you want to participate, submit [your own](https://github.com/nalgeon/sqlean/blob/incubator/docs/submit.md) or [third-party](https://github.com/nalgeon/sqlean/blob/incubator/docs/external.md) extensions.

I keep adding new extensions to the incubator. I also refactor the extensions from the incubator and merge them into the main set. I plan to write a separate article for each main module, so stay tuned.

SQLite FTW!
