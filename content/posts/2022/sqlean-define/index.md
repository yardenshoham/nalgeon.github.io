+++
date = 2022-09-08T15:30:00Z
title = "User-defined functions in SQLite"
description = "Write functions in plain SQL."
image = "../sqlean/cover.png"
slug = "sqlean-define"
tags = ["sqlite"]
+++

_Write functions in plain SQL using the 'define' extension._

SQLite does not directly support user-defined functions. Sure, one can write a function in C or Python and register it within SQLite. But not in SQL itself.

Luckily for us, SQLite provides an extension mechanism. One of such extensions — `define` — allows writing functions in regular SQL.

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

&rarr; [**See the docs for details**](https://github.com/nalgeon/sqlean/blob/main/docs/define.md)
