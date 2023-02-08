+++
date = 2022-09-08T15:30:00Z
title = "User-Defined Functions in SQLite"
description = "Write functions in plain SQL."
image = "/sqlean-define/cover.png"
slug = "sqlean-define"
tags = ["sqlite"]
+++

Most database engines provide a lot of built-in functions. Still, sometimes they are not enough, and people turn to writing their own — _user-defined_ — functions in plain SQL or some SQL-based language (like pl/sql in Oracle or pl/pgsql in Postgres).

SQLite does not support user-defined functions by default. But you can easily enable them using the `define` extension.

**Note**. Unlike other DBMS, adding extensions in SQLite is a breeze. Download a file, run one database command — and you are good to go.

## Custom Functions

With `define` writing a custom function becomes as easy as:

```sql
select define('sumn', ':n * (:n + 1) / 2');
```

And then using it as any built-in function:

```sql
select sumn(5);
-- 15
```

User-defined functions can take multiple parameters and call other functions.

Generate a random `N` such that `a ≤ N ≤ b`:

```sql
select define('randint', ':a + abs(random()) % (:b - :a + 1)');
select randint(10, 99);
-- 42
select randint(10, 99);
-- 17
select randint(10, 99);
-- 29
```

List user-defined functions:

```sql
select * from sqlean_define;
```

Delete a function:

```sql
select undefine('sumn');
```

There is even a way to return multiple values from a function!

## Dynamic SQL

To dynamically compose an SQL query and execute it without creating a function, use `eval()`:

```sql
select eval('select 10 + 32');
-- 42
```

Supports any DDL or DML queries:

```sql
select eval('create table tmp(value int)');
select eval('insert into tmp(value) values (1), (2), (3)');
select eval('select value from tmp');
select eval('drop table tmp');
```

## Installation and Usage

1. Download the [latest release](https://github.com/nalgeon/sqlean/releases/latest)

2. Use with SQLite command-line interface:

```
sqlite> .load ./define
sqlite> select define('sumn', ':n * (:n + 1) / 2');
sqlite> select sumn(5);
```

See [How to Install an Extension](https://github.com/nalgeon/sqlean/blob/main/docs/install.md) for usage with IDE, Python, etc.

See [Extension Documentation](https://github.com/nalgeon/sqlean/blob/main/docs/define.md) for reference.
