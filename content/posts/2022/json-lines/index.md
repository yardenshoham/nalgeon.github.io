+++
date = 2022-08-04T18:30:00Z
title = "JSON Lines"
description = "CSV on steroids."
image = "/json-lines/cover.jpg"
slug = "json-lines"
tags = ["development"]
subscribe = "ohmypy"
+++

Worked with the [JSON Lines](https://jsonlines.org/) format the other day. It's a CSV on steroids:

-   each entry is a separate line, as in CSV;
-   at the same time it is a full-fledged JSON.

For example:

```json
{ "id": 11, "name": "Alice", "department": { "id": 1001, "name": "it"} }
{ "id": 12, "name": "bob", "department": { "id": 1001, "name": "it"} }
{ "id": 21, "name": "Cindy", "department": { "id": 2001, "name": "hr"} }
```

Great stuff:

-   Suitable for objects of complex structure (unlike csv);
-   Easy to stream read without loading the entire file into memory (unlike json);
-   Easy to append new entries to an existing file (unlike json).

JSON can also be streamed. But look [how much easier it is with JSON Lines](https://replit.com/@antonz/json-lines#main.py).

Great fit for logs and data processing pipelines.
