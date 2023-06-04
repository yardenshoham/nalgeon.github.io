+++
date = 2023-05-11T15:50:00Z
title = "SQL Recipe: Ranking Records"
description = "Assigning a rank to each row based on the value of one or more columns."
image = "/sql-ranking/cover.png"
slug = "sql-ranking"
tags = ["data"]
+++

_This post is part of the "SQL Recipes" series, where I provide short patterns for solving common SQL data analysis tasks._

Suppose we want to create a ranking, where the position of each record is determined by the value of one or more columns.

The solution is to use the `rank()` function over an SQL window ordered by target columns.

## Example

Let's rank `employees` by salary:

```sql
select
  rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;
```

The `rank()` function assigns each employee a rank according to their salary (`order by salary desc`). Note that employees with the same salary receive the same rank (Henry and Irene, Cindy and Dave).

## Alternatives

We can use `dense_rank()` instead of `rank()` to avoid "gaps" in the ranking:

```sql
select
  dense_rank() over w as "rank",
  name, department, salary
from employees
window w as (order by salary desc)
order by "rank", id;
```

Note that Alice is ranked #3 and Grace is ranked #5, whereas previously they were ranked #4 and #7, respectively.

## Compatibility

All major vendors support the `rank()` and `dense_rank()` window functions. Some of them, such as MS SQL and Oracle, do not support the `window` clause. In these cases, we can inline the window definition:

```sql
select
  rank() over (
    order by salary desc
  ) as "rank",
  name, department, salary
from employees
order by "rank", id;
```

We can also rewrite the query without window functions:

```sql
select
  (
    select count(*)
    from employees as e2
    where e2.salary > e1.salary
  ) + 1 as "rank",
  e1.name, e1.department, e1.salary
from employees as e1
order by "rank", e1.id;
```

<br>

Want to learn more about window functions? Read my book — [**SQL Window Functions Explained**](/sql-window-functions-book/)

<sqlime-db name="employees" path="/sql-window-functions-book/employees.sql"></sqlime-db>
<sqlime-examples db="employees" selector="div.highlight" editable></sqlime-examples>

<script src="/assets/sqlime/sqlite3.js"></script>
<script src="/assets/sqlime/sqlime-db.js"></script>
<script src="/assets/sqlime/sqlime-examples.js"></script>
