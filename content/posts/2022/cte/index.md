+++
date = 2022-05-20T16:50:00Z
title = "Common Table Expressions in SQL"
description = "Use them instead of subqueries."
image = "/cte/cover.png"
slug = "cte"
tags = ["sqlite"]
+++

Rule #1 for writing well-readable SQL queries is to use _common table expressions_ (CTE). People are afraid of them, but they really shouldn't. Let's learn CTEs in three minutes, so you don't have to read a weighty SQL book or take an online course.

## Problem

Let's say we have a table with monthly sales for two years:

```
┌──────┬───────┬───────┬──────────┬─────────┐
│ year │ month │ price │ quantity │ revenue │
├──────┼───────┼───────┼──────────┼─────────┤
│ 2019 │ 1     │ 60    │ 200      │ 12000   │
│ 2019 │ 2     │ 60    │ 660      │ 39600   │
│ 2019 │ 3     │ 60    │ 400      │ 24000   │
│ 2019 │ 4     │ 60    │ 300      │ 18000   │
│ 2019 │ 5     │ 60    │ 440      │ 26400   │
│ 2019 │ 6     │ 60    │ 540      │ 32400   │
│ 2019 │ 7     │ 60    │ 440      │ 26400   │
│ 2019 │ 8     │ 60    │ 440      │ 26400   │
│ 2019 │ 9     │ 60    │ 250      │ 15000   │
│ 2019 │ 10    │ 60    │ 420      │ 25200   │
│ ...  │ ...   │ ...   │ ...      │ ...     │
└──────┴───────┴───────┴──────────┴─────────┘
```

[playground](https://sqlime.org/#gist:858c409b81ae3a676580cba6745d68ea)

We want to select only those months for which revenue exceeded the monthly average for the year.

To begin with, let's calculate the average monthly revenue by year:

```sql
select
  year,
  avg(revenue) as avg_rev
from sales
group by year;
```

```
┌──────┬─────────┐
│ year │ avg_rev │
├──────┼─────────┤
│ 2019 │ 25125.0 │
│ 2020 │ 48625.0 │
└──────┴─────────┘
```

Now we can select only those records in which `revenue` is not less than `avg_rev`:

```sql
select
  sales.year,
  sales.month,
  sales.revenue,
  round(totals.avg_rev) as avg_rev
from sales
  join (
    select
      year,
      avg(revenue) as avg_rev
    from sales
    group by year
  ) as totals
  on sales.year = totals.year
where sales.revenue >= totals.avg_rev;
```

```
┌──────┬───────┬─────────┬─────────┐
│ year │ month │ revenue │ avg_rev │
├──────┼───────┼─────────┼─────────┤
│ 2019 │ 2     │ 39600   │ 25125.0 │
│ 2019 │ 5     │ 26400   │ 25125.0 │
│ 2019 │ 6     │ 32400   │ 25125.0 │
│ 2019 │ 7     │ 26400   │ 25125.0 │
│ ...  │ ...   │ ...     │ ...     │
└──────┴───────┴─────────┴─────────┘
```

We solved the task using a subquery:

-   the inner query calculates the average monthly revenue;
-   the outer query joins with it and filters the results.

The query as a whole turned out to be a bit complicated. If you revisit it in a month, you'll probably spend some time "unraveling" things. The problem is that such nested queries have to be read from the inside out:

-   find the innermost query and comprehend it;
-   join it with the next outer query;
-   join them with the next outer query;
-   and so on.

It is OK when there are only two levels, as in our example. In practice, I often encounter three- and four-level subqueries. A pain to read and understand.

## Solution

Instead of a subquery, we can use a _common table expression_ (CTE). Every subquery `X`:

```sql
select a, b, c
from (X)
where e = f
```

Can be converted to CTE:

```sql
with cte as (X)
select a, b, c
from cte
where e = f
```

In our example:

```sql
with totals as (
  select
    year,
    avg(revenue) as avg_rev
  from sales
  group by year
)

select
  sales.year,
  sales.month,
  sales.revenue,
  round(totals.avg_rev) as avg_rev
from sales
  join totals on totals.year = sales.year
where sales.revenue >= totals.avg_rev;
```

With a table expression, the query becomes flat — it's much easier to perceive it this way. Besides, we can reuse the table expression as if it were a regular table:

```sql
with totals as (...)
select ... from sales_ru join totals ...
union all
select ... from sales_us join totals ...
```

SQL table expressions are somewhat similar to functions in a regular programming language — they reduce the overall complexity:

-   You can write an unreadable sheet of code, or you can break the code into understandable individual functions and compose a program out of them.
-   You can build a tower of nested subqueries, or you can extract them into CTEs and reference from the main query.

## CTE vs subquery

There is a myth that "CTEs are slow". It came from old versions of PostgreSQL (11 and earlier), which always _materialized_ CTE — calculated the full result of a table expression and stored it until the end of the query.

This is usually a good thing: the engine calculates the result once, and then uses it several times during the main query. But sometimes materialization prevented the engine from optimizing the query:

```sql
with cte as (select * from foo)
select * from cte where id = 500000;
```

The query selects exactly one record by ID, but materialization creates a copy of the _entire table_ in memory. Because of this, the query is terribly slow.

PostgreSQL 12+ and other modern DBMS have become smarter and no longer do so. Materialization is used when it does more good than harm. Plus, many DBMSs allow you to explicitly control this behavior through the `MATERIALIZED` / `NOT MATERIALIZED` instructions.

So CTEs work no slower than subqueries. And if in doubt, you can try both — a subquery and a table expression — and compare the query plan and execution time.

How does one know when to use a subquery and when to use CTE? I came up with a simple rule that has never failed me yet:

<blockquote class="big">
<p>Always use CTE</p>
</blockquote>

That's what I wish you.
