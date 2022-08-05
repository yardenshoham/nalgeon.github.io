+++
date = 2022-08-04T18:30:00Z
title = "JSON Lines"
description = "CSV on steroids."
image = "/json-lines/cover.jpg"
slug = "json-lines"
tags = ["python"]
+++

Worked with the [JSON Lines](https://jsonlines.org/) format the other day. It's a CSV on steroids:

-   each entry is a separate line, as in CSV;
-   at the same time it is a full-fledged JSON.

For example:

```json
{ "id":11, "name":"Diane", "city":"London", "department":"hr", "salary":70 }
{ "id":12, "name":"Bob", "city":"London", "department":"hr", "salary":78 }
{ "id":21, "name":"Emma", "city":"London", "department":"it", "salary":84 }
{ "id":22, "name":"Grace", "city":"Berlin", "department":"it", "salary":90}
{ "id":23, "name":"Henry", "city":"London", "department":"it", "salary":104}
```

Great stuff:

-   Suitable for objects of complex structure (unlike csv);
-   Easy to stream read without loading the entire file into memory (unlike json);
-   Easy to append new entries to an existing file (unlike json).

JSON can also be streamed. But look how much easier it is with JSON Lines:

```python
import json
from typing import Iterator


def jl_reader(fname: str) -> Iterator[dict]:
    with open(fname) as file:
        for line in file:
            obj = json.loads(line.strip())
            yield obj


if __name__ == "__main__":
    reader = jl_reader("employees.jl")
    for employee in reader:
        id = employee["id"]
        name = employee["name"]
        dept = employee["department"]
        print(f"#{id} - {name} ({dept})")
```

```
#11 - Diane (hr)
#12 - Bob (hr)
#21 - Emma (it)
#22 - Grace (it)
#23 - Henry (it)
```

[playground](https://replit.com/@antonz/json-lines#main.py)

Great fit for logs and data processing pipelines.
