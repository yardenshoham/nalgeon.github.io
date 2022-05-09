+++
date = 2022-05-07T17:10:00Z
title = "Generated columns in SQLite"
description = "Simplify queries without storing additional data."
image = "/generated-columns/cover.png"
slug = "generated-columns"
tags = ["sqlite"]
+++

Sometimes an SQL query field is calculated based on other table columns. Imagine a table with `income` and `tax_rate` columns:

```
┌────────┬──────────┐
│ income │ tax_rate │
├────────┼──────────┤
│ 70     │ 0.22     │
│ 84     │ 0.22     │
│ 90     │ 0.24     │
└────────┴──────────┘
```

You can calculate the annual tax:

```sql
select
  id,
  income * tax_rate as tax
from people;
```

In order not to repeat these calculations everywhere, it is convenient to create a virtual _generated column_:

```sql
alter table people
add column tax real as (
  income * tax_rate
);
```

After that, the column can be used in queries in the same way as regular columns:

```sql
select id, tax
from people;
```

Virtual columns are not stored in the database and are calculated on the fly. But you can build an index on them to speed up data retrieval.

> Strictly speaking, SQLite has _virtual_ generated columns and _stored_ ones. The latter are stored on disk, but it is impossible to create them via `alter table`, so people mostly use virtual ones.

In general, the syntax is as follows:

```
alter table TABLE
add column COLUMN TYPE as (EXPRESSION);
```

Generated column expression can include any table columns, but not other tables or subquery results. It's for the best: for more complex combinations, there are _views_ and _temp tables_. Let's talk about them some other time.

[Documentation](https://sqlite.org/gencol.html) • [Playground](https://sqlime.org/#gist:5208177f89a0e38ccfae8ead90a35631)
