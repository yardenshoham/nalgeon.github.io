---
layout: post
title: "SQLite is not a toy database"
description: "Here is why SQLite is a perfect tool for you - whether you are a developer, data analyst, or geek."
image: /assets/2021/sqlite-is-not-a-toy-database.png
date: 2021-03-25 12:00:00 +0300
tags: sqlite
---

Whether you are a developer, data analyst, QA engineer, DevOps person, or product manager - SQLite is a perfect tool for you. Here is why.

A few well-known facts to get started:

-   SQLite is the most common DBMS in the world, shipped with all popular operating systems.
-   SQLite is serverless.
-   For developers, SQLite is embedded directly into the app.
-   For everyone else, there is a convenient database console (REPL), provided as a single file (sqlite3.exe on Windows, sqlite3 on Linux / macOS).

## Console, import, and export

The console is a killer SQLite feature for data analysis: more powerful than Excel and more simple than `pandas`. One can import CSV data with a single command, the table is created automatically:

```
> .import --csv city.csv city
> select count(*) from city;
1117
```

The console supports basic SQL features and shows query results in a nice ASCII-drawn table. Advanced SQL features are also supported, but more on that later.

```sql
select
  century || ' century' as dates,
  count(*) as city_count
from history
group by century
order by century desc;
```

```
┌────────────┬────────────┐
│   dates    │ city_count │
├────────────┼────────────┤
│ 21 century │ 1          │
│ 20 century │ 263        │
│ 19 century │ 189        │
│ 18 century │ 191        │
│ 17 century │ 137        │
│ ...        │ ...        │
└────────────┴────────────┘
```

Data could be exported as SQL, CSV, JSON, even Markdown and HTML. Takes just a couple of commands:

```
.mode json
.output city.json
select city, foundation_year, timezone from city limit 10;
.shell cat city.json
```

```json
[
    { "city": "Amsterdam", "foundation_year": 1300, "timezone": "UTC+1" },
    { "city": "Berlin", "foundation_year": 1237, "timezone": "UTC+1" },
    { "city": "Helsinki", "foundation_year": 1548, "timezone": "UTC+2" },
    { "city": "Monaco", "foundation_year": 1215, "timezone": "UTC+1" },
    { "city": "Moscow", "foundation_year": 1147, "timezone": "UTC+3" },
    { "city": "Reykjavik", "foundation_year": 874, "timezone": "UTC" },
    { "city": "Sarajevo", "foundation_year": 1461, "timezone": "UTC+1" },
    { "city": "Stockholm", "foundation_year": 1252, "timezone": "UTC+1" },
    { "city": "Tallinn", "foundation_year": 1219, "timezone": "UTC+2" },
    { "city": "Zagreb", "foundation_year": 1094, "timezone": "UTC+1" }
]
```

If you are more of a BI than a console person - popular data exploration tools like [Metabase](https://www.metabase.com/), [Redash](https://redash.io/), and [Superset](https://superset.apache.org/) all support SQLite.

## Native JSON

There is nothing more convenient than SQLite for analyzing and transforming JSON. You can select data directly from a file as if it were a regular table. Or import data into the table and select from there.

```sql
select
  json_extract(value, '$.iso.code') as code,
  json_extract(value, '$.iso.number') as num,
  json_extract(value, '$.name') as name,
  json_extract(value, '$.units.major.name') as unit
from
  json_each(readfile('currency.sample.json'))
;
```

```
┌──────┬─────┬─────────────────┬──────────┐
│ code │ num │      name       │   unit   │
├──────┼─────┼─────────────────┼──────────┤
│ ARS  │ 032 │ Argentine peso  | peso     │
│ CHF  │ 756 │ Swiss Franc     │ franc    │
│ EUR  │ 978 │ Euro            │ euro     │
│ GBP  │ 826 │ British Pound   │ pound    │
│ INR  │ 356 │ Indian Rupee    │ rupee    │
│ JPY  │ 392 │ Japanese yen    │ yen      │
│ MAD  │ 504 │ Moroccan Dirham │ dirham   │
│ RUR  │ 643 │ Russian Rouble  │ rouble   │
│ SOS  │ 706 │ Somali Shilling │ shilling │
│ USD  │ 840 │ US Dollar       │ dollar   │
└──────┴─────┴─────────────────┴──────────┘
```

Doesn't matter how deep the JSON is - you can extract any nested object:

```sql
select
  json_extract(value, '$.id') as id,
  json_extract(value, '$.name') as name
from
  json_tree(readfile('industry.sample.json'))
where
  path like '$[%].industries'
;
```

```
┌────────┬──────────────────────┐
│   id   │         name         │
├────────┼──────────────────────┤
│ 7.538  │ Internet provider    │
│ 7.539  │ IT consulting        │
│ 7.540  │ Software development │
│ 9.399  │ Mobile communication │
│ 9.400  │ Fixed communication  │
│ 9.401  │ Fiber-optics         │
│ 43.641 │ Audit                │
│ 43.646 │ Insurance            │
│ 43.647 │ Bank                 │
└────────┴──────────────────────┘
```

## CTEs and set operations

Of course, SQLite supports Common Table Expressions (`WITH` clause) and `JOIN`s, I won't even give examples here. If the data is hierarchical (the table refers to itself through a column like `parent_id`) - `WITH RECURSIVE` will come in handy. Any hierarchy, no matter how deep, can be 'unrolled' with a single query.

```sql
with recursive tmp(id, name, level) as (
  select id, name, 1 as level
  from area
  where parent_id is null

  union all

  select
    area.id,
    tmp.name || ', ' || area.name as name,
    tmp.level + 1 as level
  from area
    join tmp on area.parent_id = tmp.id
)

select * from tmp;
```

```
┌──────┬──────────────────────────┬───────┐
│  id  │           name           │ level │
├──────┼──────────────────────────┼───────┤
│ 93   │ US                       │ 1     │
│ 768  │ US, Washington DC        │ 2     │
│ 1833 │ US, Washington           │ 2     │
│ 2987 │ US, Washington, Bellevue │ 3     │
│ 3021 │ US, Washington, Everett  │ 3     │
│ 3039 │ US, Washington, Kent     │ 3     │
│ ...  │ ...                      │ ...   │
└──────┴──────────────────────────┴───────┘
```

Sets? No problem: `UNION`, `INTERSECT`, `EXCEPT` are at your service.

```sql
select employer_id
from employer_area
where area_id = 1

except

select employer_id
from employer_area
where area_id = 2;
```

Calculate one column based on several others? Enter generated columns:

```sql
alter table vacancy
add column salary_net integer as (
  case when salary_gross = true then
    round(salary_from/1.04)
  else
    salary_from
  end
);
```

Generated columns can be queried in the same way as 'normal' ones:

```sql
select
  substr(name, 1, 40) as name,
  salary_net
from vacancy
where
  salary_currency = 'JPY'
  and salary_net is not null
limit 10;
```

## Math statistics

Descriptive statistics? Easy: mean, median, percentiles, standard deviation, you name it. You'll have to load an extension, but it's also a single command (and a single file).

```sql
.load sqlite3-stats

select
  count(*) as book_count,
  cast(avg(num_pages) as integer) as mean,
  cast(median(num_pages) as integer) as median,
  mode(num_pages) as mode,
  percentile_90(num_pages) as p90,
  percentile_95(num_pages) as p95,
  percentile_99(num_pages) as p99
from books;
```

```
┌────────────┬──────┬────────┬──────┬─────┬─────┬──────┐
│ book_count │ mean │ median │ mode │ p90 │ p95 │ p99  │
├────────────┼──────┼────────┼──────┼─────┼─────┼──────┤
│ 1483       │ 349  │ 295    │ 256  │ 640 │ 817 │ 1199 │
└────────────┴──────┴────────┴──────┴─────┴─────┴──────┘
```

> **Note on extensions**. SQLite is missing a lot of functions compared to other DBMSs like PostgreSQL. But they are easy to add, which is what people do - so it turns out quite a mess.
>
> Therefore, I decided to make a consistent set of extensions, divided by domain area and compiled for major operating systems. There are few of them there yet, but more are on their way:
>
> [sqlite-plus @ GitHub](https://github.com/nalgeon/sqlite-plus/)

More fun with statistics. You can plot the data distribution right in the console. Look how cute it is:

```sql
with slots as (
  select
    num_pages/100 as slot,
    count(*) as book_count
  from books
  group by slot
),
max as (
  select max(book_count) as value
  from slots
)
select
  slot,
  book_count,
  printf('%.' || (book_count * 30 / max.value) || 'c', '*') as bar
from slots, max
order by slot;
```

```
┌──────┬────────────┬────────────────────────────────┐
│ slot │ book_count │              bar               │
├──────┼────────────┼────────────────────────────────┤
│ 0    │ 116        │ *********                      │
│ 1    │ 254        │ ********************           │
│ 2    │ 376        │ ****************************** │
│ 3    │ 285        │ **********************         │
│ 4    │ 184        │ **************                 │
│ 5    │ 90         │ *******                        │
│ 6    │ 54         │ ****                           │
│ 7    │ 41         │ ***                            │
│ 8    │ 31         │ **                             │
│ 9    │ 15         │ *                              │
│ 10   │ 11         │ *                              │
│ 11   │ 12         │ *                              │
│ 12   │ 2          │ *                              │
└──────┴────────────┴────────────────────────────────┘
```

## Performance

SQLite works with hundreds of millions of records just fine. Regular `INSERT`s show about 240K records per second on my laptop. And if you connect the CSV file as a virtual table (there is an extension for that) - inserts become 2 times faster.

```sql
.load sqlite3-vsv

create virtual table temp.blocks_csv using vsv(
    filename="ipblocks.csv",
    schema="create table x(network text, geoname_id integer, registered_country_geoname_id integer, represented_country_geoname_id integer, is_anonymous_proxy integer, is_satellite_provider integer, postal_code text, latitude real, longitude real, accuracy_radius integer)",
    columns=10,
    header=on,
    nulls=on
);
```

```sql
.timer on
insert into blocks
select * from blocks_csv;

Run Time: real 5.176 user 4.716420 sys 0.403866
```

```sql
select count(*) from blocks;
3386629

Run Time: real 0.095 user 0.021972 sys 0.063716
```

There is a popular opinion among developers that SQLite is not suitable for the web, because it doesn't support concurrent access. This is a myth. In the write-ahead log mode (available since long ago), there can be as many concurrent readers as you want. There can be only one concurrent writer, but often one is enough.

SQLite is a perfect fit for small websites and applications. [sqlite.org](https://sqlite.org/) uses SQLite as a database, not bothering with optimization (≈200 requests per page). It handles 700K visits per month and serves pages faster than 95% of websites I've seen.

## Documents, graphs, and search

SQLite supports partial indexes and indexes on expressions, as 'big' DBMSs do. You can build indexes on generated columns and even turn SQLite into a document database. Just store raw JSON and build indexes on `json_extract()`-ed columns:

```sql
create table currency(
  body text,
  code text as (json_extract(body, '$.code')),
  name text as (json_extract(body, '$.name'))
);

create index currency_code_idx on currency(code);

insert into currency
select value
from json_each(readfile('currency.sample.json'));
```

```sql
explain query plan
select name from currency where code = 'EUR';

QUERY PLAN
`--SEARCH TABLE currency USING INDEX currency_code_idx (code=?)
```

> You can also use SQLite as a graph database. A bunch of complex `WITH RECURSIVE` will do the trick, or maybe you'll prefer to add a bit of Python:
>
> [simple-graph @ GitHub](https://github.com/dpapathanasiou/simple-graph)

Full-text search works out of the box:

```sql
create virtual table books_fts
using fts5(title, author, publisher);

insert into books_fts
select title, author, publisher from books;

select
  author,
  substr(title, 1, 30) as title,
  substr(publisher, 1, 10) as publisher
from books_fts
where books_fts match 'ann'
limit 5;
```

```
┌─────────────────────┬────────────────────────────────┬────────────┐
│       author        │             title              │ publisher  │
├─────────────────────┼────────────────────────────────┼────────────┤
│ Ruby Ann Boxcar     │ Ruby Ann's Down Home Trailer P │ Citadel    │
│ Ruby Ann Boxcar     │ Ruby Ann's Down Home Trailer P │ Citadel    │
│ Lynne Ann DeSpelder │ The Last Dance: Encountering D │ McGraw-Hil │
│ Daniel Defoe        │ Robinson Crusoe                │ Ann Arbor  │
│ Ann Thwaite         │ Waiting for the Party: The Lif │ David R. G │
└─────────────────────┴────────────────────────────────┴────────────┘
```

Maybe you need an in-memory database for intermediate computations? Single line of python code:

```python
db = sqlite3.connect(":memory:")
```

You can even access it from multiple connections:

```python
db = sqlite3.connect("file::memory:?cache=shared")
```

## And so much more

There are fancy window functions (just like in PostgreSQL). `UPSERT`, `UPDATE FROM`, and `generate_series()`. R-Tree indexes. Regular expressions, fuzzy-search, and geo. In terms of features, SQLite can compete with any 'big' DBMS.

There is also great tooling around SQLite. I especially like [Datasette](https://datasette.io/) - an open-source tool for exploring and publishing SQLite datasets. And [DBeaver](https://dbeaver.io/) is an excellent open-source database IDE with the latest SQLite versions support.

I hope this article will inspire you to try SQLite. Thanks for reading!

_Follow [@ohmypy](https://twitter.com/ohmypy) on Twitter to keep up with new posts 🚀_
