---
layout: post
title: "How to create a 1M record table with a single query"
date: 2021-03-22 00:15:00 +0300
tags: sqlite
---

Let's say you want to check how a query behaves on a large table - but there is no such table at hand. This is not a problem if your DBMS supports SQL recursion: lots of data can be generated with a single query. The `WITH RECURSIVE` clause comes to the rescue.

I'm going to use SQLite, but the same (or similar) queries will work for PostgreSQL and other DBMSs.

## Random numbers

Let's create a table with 1 million random numbers:

```
create table random_data as
with recursive tmp(x) as (
    select random()
    union all
    select random() from tmp
    limit 1000000
)
select * from tmp;
```

Validate:

```
sqlite> select count(*) from random_data;
1000000

sqlite> select avg(x) from random_data;
1.000501737529e+16
```

## Numeric sequence

Let's fill the table with numbers from one to a million instead of random numbers:

```
create table seq_data as
with recursive tmp(x) as (
    select 1
    union all
    select x+1 from tmp
    limit 1000000
)
select * from tmp;
```

Validate:

```
sqlite> select count(*) from seq_data;
1000000

sqlite> select avg(x) from seq_data;
500000.5

sqlite> select min(x) from seq_data;
1

sqlite> select max(x) from seq_data;
1000000
```

## Randomized data

Numbers are fine, but what if you need a large table filled with customer data? No sweat!

Let's agree on some rules:

-   customer has an ID, name, and age;
-   ID is filled sequentially from 1 to 1000000;
-   name is randomly selected from a fixed list;
-   age is a random number from 1 to 80.

Let's create a table of names:

```
create table names (
    id integer primary key,
    name text
);

insert into names(name)
select 'Ann'
union all
select 'Bill'
union all
select 'Cindy'
union all
select 'Diane'
union all
select 'Emma';
```

And generate some customers:

```
create table person_data as
with recursive tmp(id, idx, name, age) as (
    select 1, 1, 'Ann', 20
    union all
    select
        tmp.id + 1 as id,
        abs(random() % 5) + 1 as idx,
        (select name from names where id = idx) as name,
        abs(random() % 80) + 1 as age
    from tmp
    limit 1000000
)
select id, name, age from tmp;
```

Everything is according to the rules here:

-   `id` is calculated as the previous value + 1;
-   `idx` field contains a random number from 1 to 5;
-   `name` is selected from the `names` table according to `idx` value;
-   `age` is calculated as a random number from 1 to 80.

Check it out:

```
sqlite> select count(*) from person_data;
1000000

sqlite> select * from person_data limit 10;
┌────┬───────┬─────┐
│ id │ name  │ age │
├────┼───────┼─────┤
│ 1  │ Ann   │ 20  │
│ 2  │ Ann   │ 33  │
│ 3  │ Ann   │ 26  │
│ 4  │ Ann   │ 4   │
│ 5  │ Diane │ 20  │
│ 6  │ Diane │ 76  │
│ 7  │ Bill  │ 42  │
│ 8  │ Cindy │ 35  │
│ 9  │ Diane │ 6   │
│ 10 │ Ann   │ 29  │
└────┴───────┴─────┘
```

A single query has brought us a million customers. Not bad! It would be great to achieve such results in sales, wouldn't it? ツ

_Follow [@ohmypy](https://twitter.com/ohmypy) on Twitter to keep up with new posts!_
