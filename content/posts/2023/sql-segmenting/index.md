+++
date = 2023-05-23T15:30:00Z
title = "SQL Recipe: Segmenting Data"
description = "Assigning each record to a specific segment based on the value of one or more columns."
image = "/sql-segmenting/cover.png"
slug = "sql-segmenting"
tags = ["data"]
+++

_This post is part of the "SQL Recipes" series, where I provide short patterns for solving common SQL data analysis tasks._

Suppose we want to divide our data into several segments based on the value of one or more columns (e.g., to assign customers or products to different groups for marketing purposes).

The solution is to use the `ntile()` function over an SQL window ordered by target columns.

## Example

Let's divide the `employees` into three groups according to their salary:

-   high-paid,
-   medium-paid,
-   low-paid.

```sql
select
  ntile(3) over w as tile,
  name, salary
from employees
window w as (order by salary desc)
order by salary desc, id;
```

The `ntile(n)` function splits all records into `n` groups and returns the group number for each record. If the total number of records (10 in our case) is not divisible by the group size (3), then the former groups will be larger than the latter.

## Alternatives

`ntile()` always tries to split the data so that the groups are of the same size. So records with the same value may end up in different (adjacent) groups:

```sql
select
  ntile(2) over w as tile,
  name, salary
from employees
window w as (order by salary desc, id)
order by salary desc, tile;
```

To avoid this, we can use the following (much more complicated) formula instead of `ntile(n)`:

```
1 + ((rank() over w) - 1) * N / count(*) over () as tile
```

For `n = 2`:

```sql
select
  1 + ((rank() over w) - 1) * 2 / count(*) over () as tile,
  name, salary
from employees
window w as (order by salary desc)
order by salary desc, id;
```

## Compatibility

All major vendors support the `ntile()` window function. Some of them, such as MS SQL and Oracle, do not support the `window` clause. In these cases, we can inline the window definition:

```sql
select
  ntile(3) over (
    order by salary desc
  ) as tile,
  name, salary
from employees
order by salary desc, id;
```

We can also rewrite the query without window functions:

```sql
select
  ceil(
    (select count(*) from employees as e2 where e2.salary > e1.salary) * 3 /
    (select count(*) from employees)
  ) + 1 as tile,
  name, salary
from employees as e1
order by salary desc, id;
```

<br>

Want to learn more about window functions? Read my book — [**SQL Window Functions Explained**](/sql-window-functions-book/)

<sqlime-db name="employees" path="/sql-window-functions-book/employees.sql"></sqlime-db>
<sqlime-examples db="employees" selector="div.highlight" editable></sqlime-examples>

<script src="/assets/sqlime/sqlite3.js"></script>
<script src="/assets/sqlime/sqlime-db.js"></script>
<script src="/assets/sqlime/sqlime-examples.js"></script>
