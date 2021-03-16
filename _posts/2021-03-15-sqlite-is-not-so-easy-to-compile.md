---
layout: post
title: "SQLite is not so easy to compile"
date: 2021-03-15 14:45:00 +0300
tags: sqlite
---

SQLite shell is quite easy to compile, right?

```
curl -L http://sqlite.org/2021/sqlite-amalgamation-3350000.zip --output src.zip
unzip src.zip
mv sqlite-amalgamation-3350000 src
gcc src/shell.c src/sqlite3.c -o sqlite3 -lpthread -ldl
```

Well, unless you want all the cool features which are not included in the default build. Or unless you are using Windows and prefer 64-bit binary to 32-bit. Or unless you do not have `gcc` installed.

I found myself in these situations a couple of times. So I decided to create reproducible builds for Windows, Ubuntu, and macOS — using GitHub Actions. Here they are:

<p class="big"><a href="https://github.com/nalgeon/sqlite/releases/latest">SQLite shell builds</a></p>

Refer to [build.yml](https://github.com/nalgeon/sqlite/blob/main/.github/workflows/build.yml) for build instructions if you prefer to build SQLite shell yourself.

*Follow [@ohmypy](https://twitter.com/ohmypy) on Twitter to keep up with new posts!*