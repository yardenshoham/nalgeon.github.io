+++
date = 2022-05-13T20:25:00Z
title = "Compact objects in Python"
description = "Tuple vs dataclass, until numpy interferes"
image = "/compact-objects/cover.png"
slug = "compact-objects"
tags = ["python"]
+++

Python is an object language. This is nice and cozy until you are out of memory holding 10 million objects at once. Let's talk about how to reduce appetite.

_Visit the [Playground](https://colab.research.google.com/drive/1oKl4rda2apWORLxYYtN9J49r3Mj3L6J9?usp=sharing) to try out the code samples_

## Tuples

Imagine you have a simple `Pet` object with the `name` (string) and `price` (integer) attributes. Intuitively, it seems that the most compact representation is a tuple:

```python
("Frank the Pigeon", 50000)
```

Let's measure how much memory this beauty eats:

```python
import random
from pympler.asizeof import asizeof

def fields():
    name_gen = (random.choice(string.ascii_uppercase) for _ in range(10))
    name = "".join(name_gen)
    price = random.randint(10000, 99999)
    return (name, price)

def measure(name, fn, n=10_000):
    pets = [fn() for _ in range(n)]
    size = round(asizeof(pets) / n)
    print(f"Pet size ({name}) = {size} bytes")
    return size

baseline = measure("tuple", fields)
```

```
Pet size (tuple) = 161 bytes
```

161 bytes. Let's use it as a baseline for further comparison.

## Dataclasses vs named tuples

But who works with tuples these days? You would probably choose a dataclass:

```python
from dataclasses import dataclass

@dataclass
class PetData:
    name: str
    price: int

fn = lambda: PetData(*fields())
measure("dataclass", fn)
```

```
Pet size (dataclass) = 257 bytes
x1.60 to baseline
```

Thing is, it's 1.6 times larger than a tuple.

Let's try a named tuple then:

```python
from typing import NamedTuple

class PetTuple(NamedTuple):
    name: str
    price: int


fn = lambda: PetTuple(*fields())
measure("named tuple", fn)
```

```
Pet size (named tuple) = 161 bytes
x1.00 to baseline
```

Looks like a dataclass, works like a tuple. Perfect. Or not?

## Slots

Python 3.10 received dataclasses with slots:

```python
@dataclass(slots=True)
class PetData:
    name: str
    price: int


fn = lambda: PetData(*fields())
measure("dataclass w/slots", fn)
```

```
Pet size (dataclass w/slots) = 153 bytes
x0.95 to baseline
```

Wow! Slots magic creates special skinny objects without an underlying dictionary, unlike regular Python objects. Such dataclass is even lighter than a tuple.

What if 3.10 is out of the question yet? Use `NamedTuple`. Or add a slots dunder manually:

```python
@dataclass
class PetData:
    __slots__ = ("name", "price")
    name: str
    price: int
```

Slot objects have their own shortcomings. But they are great for simple cases (without inheritance and other complex stuff).

## numpy arrays

The real winner, of course, is the `numpy` array:

```python
import string
import numpy as np

PetNumpy = np.dtype([("name", "S10"), ("price", "i4")])
generator = (fields() for _ in range(n))
pets = np.fromiter(generator, dtype=PetNumpy)
size = round(asizeof(pets) / n)
```

```
Pet size (numpy array) = 14 bytes
x0.09 to baseline
```

This is not a flawless victory, as you might think. If names are unicode (`U` type instead of `S`), the advantage is not so impressive:

```python
PetNumpy = np.dtype([("name", "U10"), ("price", "i4")])
```

```
Pet size (numpy U10) = 44 bytes
x0.27 to baseline
```

If the name length is not strictly 10 characters, but varies, say, up to 50 characters (`U50` instead of `U10`) — the advantage disappears completely:

```python
def fields():
    name_len = random.randint(10, 50)
    name_gen = (random.choice(string.ascii_uppercase) for _ in range(name_len))
    # ...

PetNumpy = np.dtype([("name", "U50"), ("price", "i4")])
```

```
Pet size (tuple) = 179 bytes

Pet size (numpy U50) = 204 bytes
x1.14 to baseline
```

## Others

Let's consider alternatives for completeness.

A regular class is no different than a dataclass:

```python
class PetClass:
    def __init__(self, name: str, price: int):
        self.name = name
        self.price = price
```

```
Pet size (class) = 257 bytes
x1.60 to baseline
```

And a frozen (immutable) dataclass too:

```python
@dataclass(frozen=True)
class PetDataFrozen:
    name: str
    price: int
```

```
Pet size (frozen dataclass) = 257 bytes
x1.60 to baseline
```

Pydantic model sets an anti-record (no wonder, it uses inheritance):

```python
from pydantic import BaseModel

class PetModel(BaseModel):
    name: str
    price: int
```

```
Pet size (pydantic) = 385 bytes
x2.39 to baseline
```

<p class="align-center">⌘&nbsp;⌘&nbsp;⌘</p>

Compact (and not so compact) objects in Python:

<div class="row">
<div class="col-xs-12 col-sm-4">
<figure><img alt="Tuple" src="tuple.png"></figure>
</div>
<div class="col-xs-12 col-sm-4">
<figure><img alt="Dataclass" src="dataclass.png"></figure>
</div>
<div class="col-xs-12 col-sm-4">
<figure><img alt="Named tuple" src="named-tuple.png"></figure>
</div>
</div>

<div class="row">
<div class="col-xs-12 col-sm-4">
<figure><img alt="Dataclass with slots" src="dataclass-slots.png"></figure>
</div>
<div class="col-xs-12 col-sm-4">
<figure><img alt="Manual slots" src="manual-slots.png"></figure>
</div>
<div class="col-xs-12 col-sm-4">
<figure><img alt="numpy array" src="np-array.png"></figure>
</div>
</div>
