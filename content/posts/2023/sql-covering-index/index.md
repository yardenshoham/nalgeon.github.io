+++
date = 2023-06-12T14:30:00Z
title = "Covering Index in SQL"
description = "Allows executing queries without touching the table."
image = "/sql-covering-index/cover.png"
slug = "sql-covering-index"
tags = ["data"]
+++

A covering index is the fastest way to select data from a table.

Let's see how it works using a query that selects employees with a certain salary:

```sql
select id, name from employees
where salary = 90;
```

## No index vs. Using an index

If there is no index, the database engine goes through the entire table (this is called a "full scan"):

```
QUERY PLAN
`--SCAN employees
```

Let's create an index by salary:

```sql
create index employees_idx
on employees (salary);
```

Now the database engine finds records by salary in the index (this is faster than going through the entire table). And for each record found, it accesses the table to get the `id` and `name` values:

```
QUERY PLAN
`--SEARCH employees USING INDEX employees_idx (salary=?)
```

## Using a covering index

Let's create a covering index (which covers all selected columns):

```sql
create index employees_idx
on employees (salary, id, name);
```

Now the database engine works only with the index, without accessing the table at all. This is even faster:

```
QUERY PLAN
`--SEARCH employees USING COVERING INDEX employees_idx (salary=?)
```

However, simply covering all columns used in a query may not be enough. The order of the columns should allow for a fast search using the index.

Suppose we build an index with the same set of columns, but in a different order:

```sql
create index employees_idx
on employees (id, name, salary);
```

Now the database engine won't be able to quickly find records with `salary` = `90`. It may still use the index, but it will be a full index scan instead of a search (which is slow).

```
QUERY PLAN
`--SCAN employees USING COVERING INDEX employees_idx
```

(note SCAN instead of SEARCH here)

Covering indexes cost more when the data in the table changes, so don't create them for every type of query. Often this is one of the last optimizations after everything else has been done.
