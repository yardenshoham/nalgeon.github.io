+++
date = 2023-05-30T18:00:00Z
title = "LIMIT vs. FETCH in SQL"
description = "According to the standard, we should use be using FETCH."
image = "/sql-fetch/cover.png"
slug = "sql-fetch"
tags = ["data"]
+++

Fun fact: There is no `limit` clause in the SQL standard.

Everyone uses `limit`:

```sql
select * from employees
order by salary desc
limit 5;
```

```
┌────┬───────┬────────────┬────────┐
│ id │ name  │ department │ salary │
├────┼───────┼────────────┼────────┤
│ 25 │ Frank │ it         │ 120    │
│ 23 │ Henry │ it         │ 104    │
│ 24 │ Irene │ it         │ 104    │
│ 33 │ Alice │ sales      │ 100    │
│ 31 │ Cindy │ sales      │ 96     │
└────┴───────┴────────────┴────────┘
```

And yet, according to the standard, we should be using `fetch`:

```sql
select * from employees
order by salary desc
fetch first 5 rows only;
```

`fetch first N rows only` does exactly what `limit N` does. But `fetch` can do more.

## Limit with ties

Suppose we want to select the top 5 employees by salary, but also select anyone with the same salary as the last (5th) employee. Here comes `with ties`:

```sql
select * from employees
order by salary desc
fetch first 5 rows with ties;
```

```
┌────┬───────┬────────────┬────────┐
│ id │ name  │ department │ salary │
├────┼───────┼────────────┼────────┤
│ 25 │ Frank │ it         │ 120    │
│ 23 │ Henry │ it         │ 104    │
│ 24 │ Irene │ it         │ 104    │
│ 33 │ Alice │ sales      │ 100    │
│ 31 │ Cindy │ sales      │ 96     │
│ 32 │ Dave  │ sales      │ 96     │
└────┴───────┴────────────┴────────┘
```

## Relative limit

Suppose we want to select the top 10% of employees by salary. `percent` to the rescue:

```sql
select * from employees
order by salary desc
fetch first 10 percent rows only;
```

```
┌────┬───────┬────────────┬────────┐
│ id │ name  │ department │ salary │
├────┼───────┼────────────┼────────┤
│ 25 │ Frank │ it         │ 120    │
│ 23 │ Henry │ it         │ 104    │
└────┴───────┴────────────┴────────┘
```

(there are 20 employees, so 10% is 2 records)

## Offset with fetch

Suppose we want to skip the first 3 employees and select the next 5. No problem: `fetch` plays nicely with `offset`, as does `limit`:

```sql
select * from employees
order by salary desc
offset 3 rows
fetch next 5 rows only;
```

```
┌────┬───────┬────────────┬────────┐
│ id │ name  │ department │ salary │
├────┼───────┼────────────┼────────┤
│ 33 │ Alice │ sales      │ 100    │
│ 31 │ Cindy │ sales      │ 96     │
│ 32 │ Dave  │ sales      │ 96     │
│ 22 │ Grace │ it         │ 90     │
│ 21 │ Emma  │ it         │ 84     │
└────┴───────┴────────────┴────────┘
```

`next` here is just a syntactic sugar, a synonym for `first` in the previous examples. We can use `first` and get exactly the same result:

```sql
select * from employees
order by salary desc
offset 3 rows
fetch first 5 rows only;
```

Oh, and by the way, `row` and `rows` are also synonyms.

## Database support

The following DBMS support `fetch`:

-   PostgreSQL 8.4+
-   Oracle 12c+
-   MS SQL 2012+
-   DB2 9+

However, only Oracle supports `percent` fetching.

MySQL and SQLite do not support `fetch` at all.

P.S. Interested in mastering advanced SQL? Check out my book — [SQL Window Functions Explained](/sql-window-functions-book)
