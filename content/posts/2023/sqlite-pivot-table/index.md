+++
date = 2023-02-09T14:00:00Z
title = "Building a Pivot Table in SQLite"
description = "Three ways to create a pivot table in plain SQL."
image = "/sqlite-pivot-table/cover.png"
slug = "sqlite-pivot-table"
tags = ["sqlite"]
+++

Suppose we have a `sales` table with product incomes for the years 2020-2023:

```
┌─────────┬──────┬────────┐
│ product │ year │ income │
├─────────┼──────┼────────┤
│ alpha   │ 2020 │ 100    │
│ alpha   │ 2021 │ 120    │
│ alpha   │ 2022 │ 130    │
│ alpha   │ 2023 │ 140    │
│ beta    │ 2020 │ 10     │
│ beta    │ 2021 │ 20     │
│ beta    │ 2022 │ 40     │
│ beta    │ 2023 │ 80     │
│ gamma   │ 2020 │ 80     │
│ gamma   │ 2021 │ 75     │
│ gamma   │ 2022 │ 78     │
│ gamma   │ 2023 │ 80     │
└─────────┴──────┴────────┘
```

[playground](https://sqlime.org/#gist:4a46833d948e8635593fec028eb178ba) • [download](./sales.sql)

And we want to transform it into a so-called _pivot table_, where products serve as rows and years serve as columns:

```
┌─────────┬──────┬──────┬──────┬──────┐
│ product │ 2020 │ 2021 │ 2022 │ 2023 │
├─────────┼──────┼──────┼──────┼──────┤
│ alpha   │ 100  │ 120  │ 130  │ 140  │
│ beta    │ 10   │ 20   │ 40   │ 80   │
│ gamma   │ 80   │ 75   │ 78   │ 80   │
└─────────┴──────┴──────┴──────┴──────┘
```

Some DBMS, like SQL Server, have a custom `pivot` operator to do this. SQLite does not. Still, there are multiple ways to solve the problem. Let's examine them.

## 1. Filtered totals

Let's manually extract each year in a separate column and calculate a filtered total income for that year:

```sql
select
  product,
  sum(income) filter (where year = 2020) as "2020",
  sum(income) filter (where year = 2021) as "2021",
  sum(income) filter (where year = 2022) as "2022",
  sum(income) filter (where year = 2023) as "2023"
from sales
group by product
order by product;
```

Here is our pivot table:

```
┌─────────┬──────┬──────┬──────┬──────┐
│ product │ 2020 │ 2021 │ 2022 │ 2023 │
├─────────┼──────┼──────┼──────┼──────┤
│ alpha   │ 100  │ 120  │ 130  │ 140  │
│ beta    │ 10   │ 20   │ 40   │ 80   │
│ gamma   │ 80   │ 75   │ 78   │ 80   │
└─────────┴──────┴──────┴──────┴──────┘
```

This universal method works in every DBMS, not only SQLite. Even if your DB engine does not support `filter`, you can always resort to using `case`:

```sql
select
  product,
  sum(case when year = 2020 then income end) as "2020",
  sum(case when year = 2021 then income end) as "2021",
  sum(case when year = 2022 then income end) as "2022",
  sum(case when year = 2023 then income end) as "2023"
from sales
group by product
order by product;
```

Using `filter` is probably the easiest way when we know the columns in advance. But what if we don't?

## 2. Dynamic SQL

Let's build our query dynamically without hardcoding year values:

1. Extract distinct year values.
2. Generate a `...filter (where year = X) as "X"` query line for each year.

```sql
with years as (
  select distinct year as year
  from sales
),
lines as (
  select 'select product ' as part
  union all
  select ', sum(income) filter (where year = ' || year || ') as "' || year || '" '
  from years
  union all
  select 'from sales group by product order by product;'
)
select group_concat(part, '')
from lines;
```

This query returns the same SQL we wrote manually at the previous step (minus formatting):

```sql
select product , sum(income) filter (where year = 2020) as "2020" , sum(income) filter (where year = 2021) as "2021" , sum(income) filter (where year = 2022) as "2022" , sum(income) filter (where year = 2023) as "2023" from sales group by product order by product;
```

Now we have to execute it. For that, let's use the `eval(sql)` function available as part of the [`define`](https://github.com/nalgeon/sqlean/blob/main/docs/define.md) extension:

```sql
select load_extension('./define');

with years as (
  select distinct year as year
  from sales
),
lines as (
  select 'drop view if exists v_sales; ' as part
  union all
  select 'create view v_sales as '
  union all
  select 'select product '
  union all
  select ', sum(income) filter (where year = ' || year || ') as "' || year || '" '
  from years
  union all
  select 'from sales group by product order by product;'
)
select eval(group_concat(part, ''))
from lines;
```

> Note: extensions do not work in the playground, so you'll have to use your local SQLite to reproduce this step.

Here, we are building a `v_sales` view which executes the query we've constructed previously. Let's select the data from it:

```sql
select * from v_sales;
```

```
┌─────────┬──────┬──────┬──────┬──────┐
│ product │ 2020 │ 2021 │ 2022 │ 2023 │
├─────────┼──────┼──────┼──────┼──────┤
│ alpha   │ 100  │ 120  │ 130  │ 140  │
│ beta    │ 10   │ 20   │ 40   │ 80   │
│ gamma   │ 80   │ 75   │ 78   │ 80   │
└─────────┴──────┴──────┴──────┴──────┘
```

Nice!

## 3. Pivot extension

If dynamic SQL seems too much for you, there is a more straightforward solution — the [`pivotvtab`](https://github.com/nalgeon/sqlean/issues/27#issuecomment-997052157) extension.

With it, we only have to provide three selects to build a pivot:

1. Select row values.
2. Select column values.
3. Select cell values.

```sql
select load_extension('./pivotvtab');

create virtual table v_sales using pivot_vtab (
  -- rows
  (select distinct product from sales),
  -- columns
  (select distinct year, year from sales),
  -- cells
  (select sum(income) from sales where product = ?1 and year = ?2)
);
```

The extension does the rest:

```sql
select * from v_sales;
```

```
┌─────────┬──────┬──────┬──────┬──────┐
│ product │ 2020 │ 2021 │ 2022 │ 2023 │
├─────────┼──────┼──────┼──────┼──────┤
│ alpha   │ 100  │ 120  │ 130  │ 140  │
│ beta    │ 10   │ 20   │ 40   │ 80   │
│ gamma   │ 80   │ 75   │ 78   │ 80   │
└─────────┴──────┴──────┴──────┴──────┘
```

That's even easier than the `pivot` operator in SQL Server!

## Summary

There are three ways to build a pivot table in SQLite:

1. Using plain SQL and `sum()` + `filter` expressions.
2. Building and executing a dynamic query with the `eval()` function.
3. Utilizing the `pivotvtab` extension.

P.S. Interested in using SQL for data analytics? Check out my book — [SQL Window Functions Explained](/sql-window-functions-book)
