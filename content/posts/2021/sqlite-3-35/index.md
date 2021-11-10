+++
date = 2021-03-12T19:10:16.000Z
title = "What's new in SQLite 3.35"
description = "Math functions, column removal and RETURNING clause."
image = "/sqlite-3-35/cover.png"
slug = "sqlite-3-35"
tags = ["sqlite"]
+++

SQLite developers often prefer to work on database internals. For an external observer nothing really changes. 2020 was a pleasant exception - SQLite received a bunch of nice features for ordinary users, such as generated columns, `UPDATE FROM` and fantastic `.mode box` in the shell.

There's every chance that 2021 will continue the tradition. Here's what shipped in the 3.35 release today:

1. Math functions ‼️
2. Column removal ❗
3. `RETURNING` processed rows for `DELETE`, `INSERT` and `UPDATE`.
4. Materialized CTEs.

Here are some details about each feature.

## Math functions

For many years, users literally begged SQLite devs to add basic functions like `sqrt()`, `log()` and `pow()`. The answer was always about the same (not a direct quote):

> SQLite is called 'lite' for a reason. If you need functions, add them yourself.

An understandable position indeed. But refusing to add the square root? At the same time implementing window functions, recursive queries and other advanced SQL magic? Seriously?

Maybe SQLite developers prefer to focus on features that large customers are willing to pay for. Anyway, after 20 years we now have mathematical functions!

Here is the full list:

```
acos(X)
acosh(X)
asin(X)
asinh(X)
atan(X)
atan2(X,Y)
ceil(X)
ceiling(X)
cos(X)
cosh(X)
degrees(X)
exp(X)
floor(X)
ln(X)
log(B,X)
log(X)
log10(X)
log2(X)
mod(X,Y)
pi()
pow(X,Y)
power(X,Y)
radians(X)
sin(X)
sinh(X)
sqrt(X)
tan(X)
tanh(X)
trunc(X)
```

## Column removal

Probably the second most popular source of user suffering. It's incredibly annoying that you can create as many columns as you want, but there is no way to delete them. Want to delete a column? Make a copy of the table without it, and delete the old one.

Now this pain is also going away! `ALTER TABLE DROP COLUMN`, how long have we been waiting for you.

To delete a column, SQLite have to completely overwrite the table - so the operation is not fast. But it's still nice.

## RETURNING clause

`DELETE`, `INSERT` and `UPDATE` queries now can return the rows that they deleted, added, or changed respectively.

E.g., return the `id` of a new record:

```sql
create table users (
  id integer primary key,
  first_name text,
  last_name text
);

insert into users (first_name, last_name)
values ('Jane', 'Doe')
returning id;
```

Or return products with increased price:

```sql
update products set price = price * 1.10
where price <= 99.99
returning name, price as new_price;
```

## Materialized CTEs

CTE (Common Table Expression) is a great way to make a query more expressive. E.g., count the number of cities founded in each century:

```
create table city(
  city text,
  timezone text,
  geo_lat real,
  geo_lon real,
  population integer,
  foundation_year integer
);

-- insert data ...

with history as (
  select
    city,
    (foundation_year/100)+1 as century
  from city
)
select
  century || ' century' as dates,
  count(*) as city_count
from history
group by century
order by century desc;
```

If the same CTE occurs multiple times in a query, SQLite calculates it multiple times. For large tables this may not be fast.

With a materialized CTE, SQLite executes the query once, remembers the result and does not recalculate it (within the same query):

```
with history as materialized (
  select ...
)
select ... from history where ...
except
select ... from history where ...
;
```

Four great features, all in the same release! Awesome ツ

[SQLite 3.35 Release Notes](https://sqlite.org/releaselog/3_35_0.html)

[Download latest version](https://sqlite.org/download.html)

[Comments on Hacker News](https://news.ycombinator.com/item?id=26440397)

_Follow [@ohmypy](https://twitter.com/ohmypy) on Twitter to keep up with new posts!_
