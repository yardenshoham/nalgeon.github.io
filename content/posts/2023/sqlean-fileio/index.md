+++
date = 2023-02-26T15:00:00Z
title = "Reading and Writing Files in SQLite"
description = "Working with files and traversing directories from SQL."
image = "/sqlean-fileio/cover.png"
slug = "sqlean-fileio"
tags = ["sqlite"]
+++

Sometimes it's useful to load a dataset from an external file or export query results to a file.

SQLite does not support file I/O operations by default. However, you can easily enable them using the `sqlean-fileio` extension.

> **Note**. Unlike other DBMS, adding extensions to SQLite is a breeze. Download a file, run one database command — and you are good to go.

`sqlean-fileio` solves common import/export tasks such as:

-   Loading a JSON document from a file.
-   Reading a text file line by line.
-   Streaming query results to a file.
-   Importing all files in a directory.

Let's look at some examples.

## Loading a JSON Document From a File

Suppose we have a JSON file containing employee data:

```json
{
    "employees": [
        { "id": 11, "name": "Diane", "salary": 70 },
        { "id": 12, "name": "Bob", "salary": 78 },
        { "id": 21, "name": "Emma", "salary": 84 },
        { "id": 22, "name": "Grace", "salary": 90 },
        { "id": 23, "name": "Henry", "salary": 104 },
        { "id": 24, "name": "Irene", "salary": 104 },
        { "id": 25, "name": "Frank", "salary": 120 },
        { "id": 31, "name": "Cindy", "salary": 96 },
        { "id": 32, "name": "Dave", "salary": 96 },
        { "id": 33, "name": "Alice", "salary": 100 }
    ]
}
```

And an `employees` table:

```sql
create table employees (
  id integer primary key,
  name text,
  salary integer
);
```

To import the JSON data into the table, we combine `fileo_read()` with `json_tree()`:

```sql
insert into employees(id, name, salary)
select
  json_extract(value, '$.id'),
  json_extract(value, '$.name'),
  json_extract(value, '$.salary')
from json_tree(
  fileio_read('employees.json')
)
where type = 'object' and fullkey like '$.employees%';
```

`fileio_read()` loads the file as a blob, while `json_tree()` iterates over it. When the query completes, the data is imported into the `employees` table:

```sql
select * from employees;
```

```
┌────┬───────┬────────┐
│ id │ name  │ salary │
├────┼───────┼────────┤
│ 11 │ Diane │ 70     │
│ 12 │ Bob   │ 78     │
│ 21 │ Emma  │ 84     │
│ 22 │ Grace │ 90     │
│ 23 │ Henry │ 104    │
│ 24 │ Irene │ 104    │
│ 25 │ Frank │ 120    │
│ 31 │ Cindy │ 96     │
│ 32 │ Dave  │ 96     │
│ 33 │ Alice │ 100    │
└────┴───────┴────────┘
```

## Reading a Text File Line by Line

Reading the whole file into memory, as we did with `employees.json`, may not be a good idea for very large files (e.g., logs with millions of lines). In this case, it is better to read the file line by line.

Suppose we have an `app.log` file with 1M lines:

```
ts=2023-02-26 13:00:00,level=INFO,message=begin processing
ts=2023-02-26 13:01:00,level=INFO,message=processed 1000 records
ts=2023-02-26 13:02:00,level=INFO,message=processed 2000 records
ts=2023-02-26 13:03:00,level=INFO,message=processed 3000 records
ts=2023-02-26 13:03:25,level=ERROR,message=invalid record data
ts=2023-02-26 13:03:25,level=INFO,message=processing failed
...
```

And an `app_log` table:

```sql
create table app_log (
  line text
);
```

Let's iterate over the log file with `fileio_scan()`, loading lines one by one, and inserting them into the table:

```sql
insert into app_log(line)
select value from fileio_scan('app.log');
```

```sql
select count(*) from app_log;
-- 1000000
```

Now we can extract the individual fields using the `regexp_substr` function from the `sqlean-regexp` extension:

```sql
alter table app_log add column ts text;
alter table app_log add column level text;
alter table app_log add column message text;

update app_log set ts = substr(regexp_substr(line, 'ts=[^,]+'), 4);
update app_log set level = substr(regexp_substr(line, 'level=[^,]+'), 7);
update app_log set message = substr(regexp_substr(line, 'message=[^,]+'), 9);
```

Now each log field is stored in a separate column:

```sql
select ts, level, message from app_log limit 5;
```

```
┌─────────────────────┬───────┬────────────────────────┐
│         ts          │ level │        message         │
├─────────────────────┼───────┼────────────────────────┤
│ 2023-02-26 13:00:00 │ INFO  │ begin processing       │
│ 2023-02-26 13:01:00 │ INFO  │ processed 1000 records │
│ 2023-02-26 13:02:00 │ INFO  │ processed 2000 records │
│ 2023-02-26 13:03:00 │ INFO  │ processed 3000 records │
│ 2023-02-26 13:03:25 │ ERROR │ invalid record data    │
└─────────────────────┴───────┴────────────────────────┘
```

Neat!

## Streaming Query Results to a File

Suppose we want to export the ERROR log lines into a separate file. Let's use `fileio_append` for that:

```sql
select sum(
  fileio_append('error.log', printf('%s: %s', ts, message) || char(10))
) from app_log
where level = 'ERROR';
```

This is `error.log` after the export:

```
2023-02-26 13:03:25: invalid record data
```

## Importing All Files in a Directory

Suppose we have multiple log files:

```
app.log.1
app.log.2
app.log.3
...
```

Let's import them all at once using the `filio_ls()` function.

First, we'll look at the files to make sure we're loading the correct data:

```sql
select * from fileio_ls('logs')
where name like 'logs/app.log%';
```

```
┌────────────────┬───────┬────────────┬──────┐
│      name      │ mode  │   mtime    │ size │
├────────────────┼───────┼────────────┼──────┤
│ logs/app.log.2 │ 33188 │ 1677425479 │ 316  │
│ logs/app.log.3 │ 33188 │ 1677425496 │ 377  │
│ logs/app.log.1 │ 33188 │ 1677425467 │ 316  │
└────────────────┴───────┴────────────┴──────┘
```

Seems fine. Now let's import them into the `logs` table:

```sql
create table logs(fname text, line text);
```

```sql
with files as (
  select name from fileio_ls('logs')
  where name like 'logs/app.log%'
)
insert into logs(fname, line)
select files.name, value from fileio_scan(files.name), files;
```

Let's double-check that all logs are imported:

```sql
select fname, count(*)
from logs
group by fname;
```

```
┌────────────────┬──────────┐
│     fname      │ count(*) │
├────────────────┼──────────┤
│ logs/app.log.1 │ 5        │
│ logs/app.log.2 │ 5        │
│ logs/app.log.3 │ 6        │
└────────────────┴──────────┘
```

Looks fine!

## Installation and Usage

1. Download the [latest release](https://github.com/nalgeon/sqlean/releases/latest)

2. Use with SQLite command-line interface:

```
sqlite> .load ./fileio
sqlite> select * from fileio_read('data.txt');
```

See [How to Install an Extension](https://github.com/nalgeon/sqlean/blob/main/docs/install.md) for usage with IDE, Python, etc.

See [Extension Documentation](https://github.com/nalgeon/sqlean/blob/main/docs/fileio.md) for reference.
