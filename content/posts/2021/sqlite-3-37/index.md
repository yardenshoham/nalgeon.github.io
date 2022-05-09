+++
date = 2021-11-28T15:25:00Z
title = "What's new in SQLite 3.37"
description = "Strict tables, any type and a new pragma."
image = "/sqlite-3-37/cover.png"
slug = "sqlite-3-37"
tags = ["sqlite", "data"]
+++

Unlike [3.35](/sqlite-3-35/), release 3.37 didn't bring many changes. But among them is one of the most important in the history of SQLite: the "strict" table mode, in which the engine makes sure that the data in the column matches the type.

Perhaps now SQLite will no longer be called "the JavaScript of the DBMS world" ツ But let's take it one piece at a time.

## The problem with types

SQLite supports 5 data types:

-   `INTEGER` — integers,
-   `REAL` — real numbers,
-   `TEXT` — strings,
-   `BLOB` — binary data,
-   `NULL` — empty value.

But, unlike other DBMSs, SQLite can store any type of data in a given cell — regardless of the column type.

> SQLite stores the type not only on the column itself, but also on each value in that column. That is why a given column can store values of different types without any problems. The type on the column is used as a hint: when inserting, SQLite tries to cast the value to the column type, but when it fails, it will save the value "as is".

On the one hand, it is convenient for exploratory data analysis — you can import everything first, and then use SQL to deal with problematic values. Any other DBMS will give an error when importing and force you to crunch the data with scripts or manually.

On the other hand, it causes a constant flow of criticism against SQLite: you can write things into the production database that you will never be able to sort out.

And now, in version 3.37, the problem is solved!

## STRICT tables

Now the table can be declared "strict". Strict tables do not allow saving arbitrary data:

```sql
create table employees (
    id integer primary key,
    name text,
    salary integer
) STRICT;
```

```sql
insert into employees (id, name, salary)
values (22, 'Emma', 'hello');
-- Error: stepping, cannot store TEXT value in INTEGER column employees.salary (19)
```

Emma clearly has a problem with her salary, which is what SQLite indicates. Someone has been waiting for this for twenty years ツ

At the same time, the engine still tries to convert the value to the column type, and if it succeeds — there will be no error:

```sql
insert into employees (id, name, salary)
values (22, 'Emma', '85');

select * from employees;
┌────┬───────┬────────┐
│ id │ name  │ salary │
├────┼───────┼────────┤
│ 22 │ Emma  │ 85     │
└────┴───────┴────────┘
```

See [STRICT Tables](https://sqlite.org/stricttables.html) for details.

## The ANY datatype

`ANY` type provides the means to save arbitrary values into STRICT tables:

```sql
create table employees (
    id integer primary key,
    name text,
    stuff any
) strict;

insert into employees (id, name, stuff)
values
(21, 'Emma', 84),
(22, 'Grace', 'hello'),
(23, 'Henry', randomblob(8));

select id, name, typeof(stuff) from employees;
┌────┬───────┬───────────────┐
│ id │ name  │ typeof(stuff) │
├────┼───────┼───────────────┤
│ 21 │ Emma  │ integer       │
│ 22 │ Grace │ text          │
│ 23 │ Henry │ blob          │
└────┴───────┴───────────────┘
```

The STRICT table stores ANY value without any transformations. In a regular table, ANY works almost the same way, but converts strings to numbers whenever possible.

See [The ANY datatype](https://sqlite.org/stricttables.html#the_any_datatype) for details.

## table_list pragma

`table_list` pragma statement lists tables and views in the database:

```sql
pragma table_list;
┌────────┬────────────────────┬───────┬──────┬────┬────────┐
│ schema │        name        │ type  │ ncol │ wr │ strict │
├────────┼────────────────────┼───────┼──────┼────┼────────┤
│ main   │ expenses           │ table │ 4    │ 0  │ 0      │
│ main   │ employees          │ table │ 5    │ 0  │ 0      │
│ main   │ sqlite_schema      │ table │ 5    │ 0  │ 0      │
│ temp   │ sqlite_temp_schema │ table │ 5    │ 0  │ 0      │
└────────┴────────────────────┴───────┴──────┴────┴────────┘
```

Previously, one had to query the `sqlite_schema` table for this. The pragma is more convenient.

See [PRAGMA table_list](https://sqlite.org/pragma.html#pragma_table_list) for details.

## CLI changes

The CLI tool (`sqlite.exe`) now supports switching between multiple database connections using the dot command `.connection`:

```
sqlite> .connection
ACTIVE 0: :memory:
```

```
sqlite> .open employees.ru.db
sqlite> .connection
ACTIVE 0: employees.ru.db
```

```
sqlite> .connection 1
sqlite> .open employees.en.db
sqlite> .connection
       0: employees.ru.db
ACTIVE 1: employees.en.db
```

See [Working With Multiple Database Connections](https://sqlite.org/cli.html#dotconn) for details.

Also, there is now a `--safe` launch option. It disables commands that can make changes anywhere other than a specific database. Safe mode disables `.open`, `.shell`, `.import` and other "dangerous" commands.

See [The --safe command-line option](https://sqlite.org/cli.html#safemode) for details.

## And a few more little things

-   The query scheduler ignores `order by` on subqueries unless they change the overall semantics of the query.
-   Function `generate_series(start, stop, step)` always requires the `start` parameter (`stop` and `step` remain optional).
-   Some changes in C API.

Overall, a great release! Strict tables offer a long-awaited alternative to flexible typing, `any` type makes flexibility explicit, and `table_list` pragma is just nice to have.

[Official release notes](https://sqlite.org/releaselog/3_37_0.html) | [Download](https://sqlite.org/download.html)
