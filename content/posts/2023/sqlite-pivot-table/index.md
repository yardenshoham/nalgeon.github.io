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

<details>
    <summary class="summary-ai">explain</summary>
    <div class="boxed">
        <p><strong><abbr title="Generated by AI, verified by human">Human-verified explanation</abbr></strong></p>
        <p>This SQL query shows the total income of each product for each year.</p>
        <p>The first line of the query selects the <code>product</code> column from the table.</p>
        <p>The next four lines use the <code>sum</code> function to calculate the total <code>income</code> for each year (2020, 2021, 2022, and 2023) using a <code>case</code> statement to only include income values where the <code>year</code> matches the specified year. The <code>as</code> keyword is used to give each calculated sum a column alias that corresponds to the year.</p>
        <p>The <code>from</code> clause specifies that the data is being selected from the <code>sales</code> table.</p>
        <p>The <code>group by</code> clause groups the data by <code>product</code>, which means that the query will return one row for each unique <code>product</code> value in the <code>sales</code> table.</p>
        <p>Finally, the <code>order by</code> clause orders the results by <code>product</code> in ascending order.</p>
    </div>
</details>

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

<details>
    <summary class="summary-ai">explain</summary>
    <div class="boxed">
        <p><strong><abbr title="Generated by AI, verified by human">Human-verified explanation</abbr></strong></p>
        <p>This SQL query creates a view named <code>v_sales</code> that shows the total income of each product for each year. The query uses a common table expression (CTE) to generate a list of distinct years from the <code>sales</code> table. Then, it defines another CTE named <code>lines</code> that contains a series of unioned select statements to generate the SQL commands to create the view.</p>
        <p>The first select statement in <code>lines</code> generates a <code>drop view if exists</code> command to ensure that any previous version of the view is removed before creating the new one.</p>
        <p>The second select statement generates a <code>create view</code> command to create the <code>v_sales</code> view.</p>
        <p>The third select statement generates a <code>select</code> command to select the product column from the <code>sales</code> table.</p>
        <p>The fourth select statement generates a <code>sum</code> command that sums the income for each product for a given year. It uses the <code>filter</code> clause to filter the sum by year. The year value is passed in from the <code>years</code> CTE using string concatenation.</p>
        <p>The fifth select statement specifies the <code>from</code> and <code>group by</code> clauses for the SQL statement. It groups the results by product and orders them by product.</p>
        <p>Finally, the last select statement concatenates all the SQL commands generated in the <code>lines</code> CTE using the <code>group_concat</code> function and evaluates the resulting SQL string using the <code>eval</code> function. The resulting SQL commands create the <code>v_sales</code> view with the desired structure.</p>
    </div>
</details>

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

> Note: extensions do not work in the playground, so you'll have to use your local SQLite to reproduce this step.

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

<details>
    <summary class="summary-ai">explain</summary>
    <div class="boxed">
        <p><strong><abbr title="Generated by AI, verified by human">Human-verified explanation</abbr></strong></p>
        <p>This SQL query creates a virtual table called <code>v_sales</code> using the <code>pivot_vtab</code> module from the <code>pivotvtab</code> extension. A virtual table is a special type of table that does not store data on disk, but rather generates it on the fly based on a query.</p>
        <p>The <code>pivot_vtab</code> command takes three arguments:</p>
        <ol>
            <li>A subquery that specifies the rows of the virtual table. In this case, the subquery selects all distinct values from the <code>product</code> column of the <code>sales</code> table.</li>
            <li>A subquery that specifies the columns of the virtual table. In this case, the subquery selects all distinct values from the <code>year</code> column of the <code>sales</code> table, and duplicates them. This is because the <code>pivot_vtab</code> module expects two values for each column, one for the column value and one for the column name. By duplicating the <code>year</code> value, we are effectively using it as both the value and name for the column.</li>
            <li>A subquery that specifies the values of the virtual table. In this case, the subquery selects the sum of the <code>income</code> column from the <code>sales</code> table for a specific <code>product</code> and <code>year</code> combination. The <code>?1</code> and <code>?2</code> placeholders in the subquery represent parameters that will be filled in at runtime with the actual values for <code>product</code> and <code>year</code>.</li>
        </ol>
        <p>Overall, this query creates a virtual table that pivots the data from the <code>sales</code> table, with the <code>product</code> values as rows, the <code>year</code> values as columns, and the sum of <code>income</code> as the cell values.</p>
    </div>
</details>

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