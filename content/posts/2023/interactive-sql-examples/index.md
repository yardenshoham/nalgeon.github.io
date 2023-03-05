+++
date = 2023-03-05T12:00:00Z
title = "Interactive SQL Examples in JavaScript"
description = "Turn static SQL code in your articles into executable examples."
image = "/interactive-sql-examples/cover.png"
slug = "interactive-sql-examples"
tags = ["data", "sqlite"]
+++

Reading about SQL is fun, but trying out live examples is even better! So I created JavaScript widgets that turn static SQL code in your articles into interactive examples.

Here is a working example. Give it a try:

<pre class="example"><code>select * from employees
limit 5;</code></pre>

And here are the four steps to creating executable SQL examples in your own articles or documentation:

## 1. Include the widgets

You'll need three JavaScript files:

-   `sqlite3.js` — SQLite compiled for the browser.
-   `sqlime-db.js` — the database web component.
-   `sqlime-examples.js` — the interactive example web component.

Include them from CDN or (better) download and host locally:

```
<script src="https://unpkg.com/@antonz/sqlite@3.40.0/dist/sqlite3.js"></script>
<script src="https://unpkg.com/sqlime@0.1.2/dist/sqlime-db.js"></script>
<script src="https://unpkg.com/sqlime@0.1.2/dist/sqlime-examples.js"></script>
```

You'll also need to download and serve the SQLite WebAssembly file if you're hosting locally:

```
https://unpkg.com/@antonz/sqlite@3.40.0/dist/sqlite3.wasm
```

`sqlite3.wasm` is used internally by the `sqlite3.js` script, so place them in the same folder.

I suggest you host SQLite locally because it weighs ≈1Mb, and CDNs tend to be quite slow with such large files.

You can install all of these using `npm`:

```
npm install @antonz/sqlite
npm install sqlime
```

> **Note**. `@antonz/sqlite` is a copy of the official [SQLite Wasm](https://sqlite.org/wasm) build, provided as an NPM package for convenience. You can download and use the build from the SQLite website if you prefer.

## 2. Write an article as usual

Suppose you are writing a short post about ranking data in SQL:

```
<p>To rank data in SQL, we use the
<code>rank()</code> window function:</p>

<pre class="example">select
  rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;</pre>

<p>the article goes on...</p>
```

Which renders as ordinary HTML:

<div class="boxed">
    <p>To rank data in SQL, we use the <code>rank()</code> window function:</p>
    <pre><code>select
  rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;</code></pre>
    <p>the article goes on...</p>
</div>

## 3. Load the database

You can create a database from a binary SQLite file or SQL script. I'll go with the latter and use [employees.sql](/sql-window-functions-book/employees.sql), which creates the `employees` table and populates it with data.

Load the database using the `sqlime-db` web component:

```
<sqlime-db name="employees" path="./employees.sql"></sqlime-db>
```

-   `name` is the name we'll use later to refer to the database.
-   `path` is the URL path to the SQL (or binary) database file.

## 4. Init the examples

The only thing left is to convert your HTML `pre` code snippets into interactive examples. Use the `sqlime-examples` web component to do this:

```
<sqlime-examples db="employees" selector="pre.example" editable></sqlime-examples>
```

-   `db` is the name of the database we defined earlier.
-   `selector` is the CSS selector for your SQL code snippets.
-   `editable` makes the examples editable (remove for read-only).

And that's it!

<div class="boxed">
    <p>To rank data in SQL, we use the <code>rank()</code> window function:</p>
    <pre class="example"><code>select
  rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;</code></pre>
    <p>the article goes on...</p>
</div>

`sqlime-examples` converts all the snippets with the specified selector, so you only need to include it once (unless you have multiple databases to run your examples on).

## Summary

Executable SQL examples are an excellent fit for any kind of documentation:

-   They are more informative than static snippets.
-   They increase engagement and encourage experimentation,
-   They are lightweight, easy to set up, and do not require a server.

Try adding interactive SQL to your articles, or ask a question [on GitHub](https://github.com/nalgeon/sqlime) if you have one.

P.S. Want to see SQL examples in action? Check out my book — [SQL Window Functions Explained](/sql-window-functions-book/)

<sqlime-db name="employees" path="/sql-window-functions-book/employees.sql"></sqlime-db>
<sqlime-examples db="employees" selector="pre.example" editable></sqlime-examples>

<script src="/assets/sqlime/sqlite3.js"></script>
<script src="/assets/sqlime/sqlime-db.js"></script>
<script src="/assets/sqlime/sqlime-examples.js"></script>
