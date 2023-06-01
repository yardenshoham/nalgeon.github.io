+++
date = 2023-06-01T18:30:00Z
title = "Base64 and other encodings in SQLite"
description = "Encoding binary data into a textual representation and vice versa."
image = "/sqlean-encode/cover.png"
slug = "sqlean-encode"
tags = ["sqlite"]
+++

You've probably heard about hexadecimal encoding in SQLite:

```sql
select hex('hello');
-- 68656C6C6F

select unhex('68656C6C6F');
-- hello
```

SQLite does not support other encoding algorithms by default. However, you can easily enable them using the `sqlean-crypto` extension (not related to cryptocurrency in any way).

> **Note**. Unlike other DBMS, adding extensions to SQLite is a breeze. Download a file, run one database command — and you are good to go.

`sqlean-crypto` adds two functions:

-   `encode(data, algo)` encodes binary data into a textual representation using the specified algorithm.
-   `decode(text, algo)` decodes binary data from a textual representation using the specified algorithm.

Supported algorithms: `base32`, `base64`, `base85`, `hex` and `url`.

[Base32](https://en.wikipedia.org/wiki/Base32) uses 32 human-readable characters to represent binary data:

```sql
select encode('hello', 'base32');
-- NBSWY3DP

select decode('NBSWY3DP', 'base32');
-- hello
```

[Base64](https://en.wikipedia.org/wiki/Base64) uses 64 printable characters to represent binary data:

```sql
select encode('hello', 'base64');
-- aGVsbG8=

select decode('aGVsbG8=', 'base64');
-- hello
```

[Base85](https://en.wikipedia.org/wiki/Ascii85) (aka Ascii85) uses 85 printable characters to represent binary data:

```sql
select encode('hello', 'base85');
-- BOu!rDZ

select decode('BOu!rDZ', 'base85');
-- hello
```

[Hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal) uses 16 characters (0-9 and A-F) to represent binary data:

```sql
select encode('hello', 'hex');
-- 68656c6c6f

select decode('68656c6c6f', 'hex');
-- hello
```

[URL encoding](https://en.wikipedia.org/wiki/URL_encoding) replaces non-alphanumeric characters in a string with their corresponding percent-encoded values:

```sql
select encode('hel lo!', 'url');
-- hel%20lo%21

select decode('hel%20lo%21', 'url');
-- hel lo!
```

## Installation and Usage

1. Download the [latest release](https://github.com/nalgeon/sqlean/releases/latest)

2. Use with SQLite command-line interface:

```
sqlite> .load ./crypto
sqlite> select encode('hello', 'base64');
```

See [How to Install an Extension](https://github.com/nalgeon/sqlean/blob/main/docs/install.md) for usage with IDE, Python, etc.

See [Extension Documentation](https://github.com/nalgeon/sqlean/blob/main/docs/crypto.md) for reference.
