+++
date = 2023-06-12T14:30:00Z
title = "Covering Index in SQL"
description = "Allows executing queries without touching the table."
image = "/sql-covering-index/cover.png"
slug = "sql-covering-index"
tags = ["data"]
+++

A covering index is the fastest way to select data from a table.

For example, there is a query that selects employees with a certain salary:

```sql
select id, name from employees
where salary = 90;
```

If there is no index, it goes through the entire table (this is called a "full scan"):

```
QUERY PLAN
`--SCAN employees
```

Let's create an index by salary:

```sql
create index employees_idx
on employees (salary);
```

Now the same query finds records by salary in the index (this is faster than going through the entire table). And for each record found, it accesses the table to get the `id` and `name` values:

```
QUERY PLAN
`--SEARCH employees USING INDEX employees_idx (salary=?)
```

But if we create a covering index (which covers all selected columns):

```sql
create index employees_idx
on employees (salary, id, name);
```

Then the query will work only with the index, without accessing the table at all. This is even faster:

```
QUERY PLAN
`--SEARCH employees USING COVERING INDEX employees_idx (salary=?)
```

Covering indexes cost more when the data in the table changes, so don't create them for every type of query. Often this is one of the last optimizations after everything else has been done.
