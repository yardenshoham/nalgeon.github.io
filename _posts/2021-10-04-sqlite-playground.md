---
layout: post
title: "SQLite playground in the browser"
description: "I have built an online SQL playground with vanilla JS and a bit of GitHub API. Here's how."
image: /assets/2021/sqlime-cover.png
date: 2021-10-04 13:40:00 +0300
tags: sqlite
---

What I've always lacked is something similar to JSFiddle, but for SQLite. An online playground to quickly test an SQL query and share it with others.

Here is what I wanted:

-   Binary database import, not just SQL schema.
-   Support both local and remote databases (by url).
-   Save the database and queries in the cloud.
-   Free of charge, no sign-up required.
-   The latest version of SQLite.
-   Minimalistic and mobile friendly.

So I've built **[SQLime](https://sqlime.org/)** — an online SQLite playground for debugging and sharing SQL snippets.

![SQLime - SQLite Playground](/assets/2021/sqlime.png)

First I'll show the results, then describe how everything works:

-   [empty playground](https://sqlime.org/);
-   [sample database](https://sqlime.org/#gist:e012594111ce51f91590c4737e41a046);
-   [source code](https://github.com/nalgeon/sqlime).

Now the details.

## SQLite in the browser

All browsers — both mobile and desktop — have an excellent DBMS is already built-in — [SQLite](https://sqlite.org/). It implements the SQL-92 standard (and a large part of later standards). Seems only logical to access it through the browser API.

Many browser vendors thought so at the end of the 00s. That's how Web SQL standard appeared, supported by Apple (Safari), Google (Chrome), and Opera (popular at the time). Not by Mozilla (Firefox), though. As a result, Web SQL was killed in 2010. After that, browser data storage went along the NoSQL path (Indexed Database, Cache API).

In 2019, Ophir Lojkine compiled SQLite sources into WebAssembly (the 'native' browser binary format) for the [sql.js](https://github.com/sql-js/sql.js) project. It is a full-fledged SQLite instance that works in the browser (and quite a small one — the binary takes about 1Mb).

sql.js is the perfect engine for an online playground. So I used it.

## Loading the database from a file

Get the file from the user via `input[type=file]`, read it with the `FileReader`, convert into an 8-bit array, and upload to SQLite:

```javascript
const file = event.target.files[0];
const reader = new FileReader();
reader.onload = function () {
    const arr = new Uint8Array(reader.result);
    return new SQL.Database(arr);
};
reader.readAsArrayBuffer(file);
```

## Loading the database by URL

Upload the file using `fetch()`, read the answer into `ArrayBuffer`, then proceed as with a regular file:

```javascript
const resp = await fetch(url);
const buffer = await response.arrayBuffer();
const arr = new Uint8Array(buffer);
return new SQL.Database(arr);
```

Works equally well with local and remote URLs. Also handles databases hosted on GitHub — just use the `raw.githubusercontent.com` domain instead of `github.com`:

```
https://github.com/nalgeon/sqliter/blob/main/employees.en.db
→ https://raw.githubusercontent.com/nalgeon/sqliter/main/employees.en.db
```

## Querying the database

Perhaps the simplest part, as sql.js provides a convenient query API:

```javascript
// execute one or more queries
// and return the last result
const result = db.exec(sql);
if (!result.length) {
    return null;
}
return result[result.length - 1];
```

## Exporting the database to SQL

It is not hard to get the binary database content — sql.js provides a method:

```javascript
const buffer = db.export();
const blob = new Blob([buffer]);
const link = document.createElement("a");
link.href = window.URL.createObjectURL(blob);
// ...
link.click();
```

But I wanted a full SQL script with table schema and contents instead of a binary file. Such script is easier to understand and upload to PostgreSQL or another DBMS.

To export the database, I used the algorithm from the [sqlite-dump](https://github.com/simonw/sqlite-dump) project. The code is not very concise, so I will not show it here (see [dumper.js](https://github.com/nalgeon/sqlime/blob/main/js/dumper.js) if interested). In short:

1. Get a list of tables from the system `sqlite_schema` table, extract `create table...` queries.
2. For each table, get a list of columns from the virtual table `table_info(name)`.
3. Select data from each table and generate `insert into...` queries.

It produces a readable script:

```sql
create table if not exists employees (
    id integer primary key,
    name text,
    city text,
    department text,
    salary integer
);
insert into "employees" values(11,'Diane','London','hr',70);
insert into "employees" values(12,'Bob','London','hr',78);
insert into "employees" values(21,'Emma','London','it',84);
...
```

## Saving to the cloud

The database and queries need to be stored somewhere so that you can share a link to the prepared playground. The last thing I wanted was to implement the backend with authorization and storage. That way the service could not stay free, not to mention an extra signup headache.

Fortunately, there is a GitHub Gist API that perfectly fits all criteria:

-   many developers already have GitHub accounts;
-   API allows CORS (allowed to make requests from my domain);
-   nice user interface;
-   free and reliable.

I integrated the Gist API via the ordinary `fetch()`: `GET` to load the gist, `POST` to save it.

```javascript
// produce an SQL script with db schema and contents
const data = export(db);
// save as gist
fetch("https://api.github.com/gists", {
    method: "post",
    headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        Authorization: `Token ${token}`
    },
    body: JSON.stringify(data),
});
```

All the user needs is to specify the Github API token. Conveniently, the token is scoped exclusively to work with gists — it has no access to repositories, so is guaranteed to do no harm.

## User Interface

Modern frontend projects are full of tooling and infrastructure stuff. Honestly, I'm not interested in it at all (I'm not a JS developer). So I deliberately did not use UI frameworks and did everything with vanilla HTML + CSS + JS. It seems to be quite acceptable for a small project.

<figure>
    <img alt="SQLime on mobile" src="/assets/2021/sqlime-mobile.png">
    <figcaption class="centered">I took care of the mobile layout: the playground is perfectly usable on the phone. And there are command shortcuts for the desktop.</figcaption>
</figure>

At the same time, the code turned out to be quite modular, thanks to native JS modules and web components — they are supported by all modern browsers. A real frontend developer will wince probably, but I'm fine.

The playground is hosted on GitHub Pages, and the deployment is a basic `git push`. Since there is no build stage, I didn't even have to set up GitHub Actions.

## Summary

Try [SQLime](https://sqlime.org/) for yourself — see if you find it useful. Or, perhaps, you'll adopt the approach of creating serverless tools with vanilla JS and GitHub API. Constructive critique is also welcome, of course ツ

_Follow [@ohmypy](https://twitter.com/ohmypy) on Twitter to keep up with new posts 🚀_

[Comments on Hacker News](https://news.ycombinator.com/item?id=28669703)
