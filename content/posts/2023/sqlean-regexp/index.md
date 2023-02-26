+++
date = 2023-02-04T11:20:00Z
title = "Regular Expressions in SQLite"
description = "Use a robust pattern matching and text replacement tool from SQL."
image = "/sqlean-regexp/cover.png"
slug = "sqlean-regexp"
tags = ["sqlite"]
+++

Regular expressions are probably the most powerful text processing tool without programming.

SQLite does not support regular expressions by default. However, you can easily enable them using the `sqlean-regexp` extension.

> **Note**. Unlike other DBMS, adding extensions to SQLite is a breeze. Download a file, run one database command — and you are good to go.

With `sqlean-regexp`, matching a string against a pattern becomes as easy as:

```sql
-- count messages containing digits
select count(*) from messages
where msg_text regexp '\d+';
-- 42
```

## Pattern matching and text replacement

There are three main tasks people usually solve using regular expressions:

1. Match a string against the pattern.
2. Extract a part of the string that matches the pattern.
3. Replace all parts of the string that match the pattern.

`sqlean-regexp` provides a separate function for each of these tasks.

### `regexp_like(source, pattern)`

Checks if the source string matches the pattern.

```sql
select regexp_like('Meet me at 10:30', '\d+:\d+');
-- 1
select regexp_like('Meet me at the cinema', '\d+:\d+');
-- 0
```

### `regexp_substr(source, pattern)`

Returns a substring of the source string that matches the pattern.

```sql
select regexp_substr('Meet me at 10:30', '\d+:\d+');
-- 10:30

select regexp_substr('Meet me at 17:05', '\d+:\d+');
-- 17:05
```

### `regexp_replace(source, pattern, replacement)`

Replaces all matching substrings with the replacement string.

```sql
select regexp_replace('password = "123456"', '"[^"]+"', '***');
-- password = ***

select regexp_replace('1 2 3 4', '[2468]', 'even');
-- 1 even 3 even
```

## Pattern syntax

`sqlean-regexp` supports pretty advanced syntax, including various groups, lazy quantifiers, and look-arounds:

```sql
select regexp_substr('the year is 2020', '(\d{2})\1');
-- 2020
select regexp_substr('the year is 2021', '(\d{2})\1');
-- (null)

select regexp_substr('1 2 3 2 4 5', '.*2');
-- 1 2 3 2
select regexp_substr('1 2 3 2 4 5', '.*?2');
-- 1 2

select regexp_substr('new year', '(\w+)\s(?=year)');
-- new
select regexp_substr('last year', '(\w+)\s(?=year)');
-- last
```

## Installation and Usage

1. Download the [latest release](https://github.com/nalgeon/sqlean/releases/latest)

2. Use with SQLite command-line interface:

```
sqlite> .load ./regexp
sqlite> select regexp_like('abcdef', 'b.d');
```

See [How to Install an Extension](https://github.com/nalgeon/sqlean/blob/main/docs/install.md) for usage with IDE, Python, etc.

See [Extension Documentation](https://github.com/nalgeon/sqlean/blob/main/docs/regexp.md) for reference.
