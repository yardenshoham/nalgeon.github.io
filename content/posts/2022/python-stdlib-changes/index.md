+++
date = 2022-05-11T12:40:00Z
title = "Python Standard Library changes in recent years"
description = "17 modules with new and improved features."
image = "/python-stdlib-changes/cover.png"
slug = "python-stdlib-changes"
tags = ["python"]
featured = true
+++

With each major Python release, all the attention goes to the new language features: the walrus operator, dictionary merging, pattern matching. There is also a lot of writing about `asyncio` and `typing` modules — they are developing rapidly and are obviously important for the core team.

The rest of the standard library modules receive undeservedly little attention. I want to fix this and tell you about the novelties introduced in versions 3.8–3.10.

> This is not an exhaustive list, of course. I write only about those changes that interested me personally. But since I am not too much different from the "average" Python backend developer, it is likely that you will also be interested. Let me know if I missed something.

The modules are in alphabetical order, so if you get bored with the first (little-known) ones, do not be discouraged — it gets more exciting further.

[array](#array) • [base64](#base64) • [bisect](#bisect) • [builtins](#builtins) • [dataclasses](#dataclasses) • [datetime](#datetime) • [fractions](#fractions) • [functools](#functools) • [glob](#glob) • [graphlib](#graphlib) • [itertools](#itertools) • [math](#math) • [random](#random) • [shlex](#shlex) • [shutil](#shutil) • [statistics](#statistics) • [zoneinfo](#zoneinfo)

All new features and improvements in the article are accompanied by examples. You can try them in the playground or run locally. If you have an older local Python, run it using Docker:

```
$ docker run -it --rm python:3.10-alpine
```

## array

[`array`](https://docs.python.org/3/library/array) module provides compact typed numeric arrays. It is used much less frequently than the famous `list` counterpart.

[`array.index()`](https://docs.python.org/3/library/array#array.array.index) methods finds the value in the array and returns the index of the found element. Now it supports optional `start` and `stop` parameters, which define the search interval (3.10+):

```python
from array import array
arr = array("i", [7, 11, 19, 42])

idx = arr.index(11)
# idx == 1

idx = arr.index(11, 2)
# ValueError: array.index(x): x not in array
```

[playground](https://stepik.org/lesson/717024/step/2)

Contributed by: [Anders Lorentsen](https://github.com/Phaqui) • [Zackery Spytz](https://github.com/ZackerySpytz)

## base64

[`base64`](https://docs.python.org/3/library/base64) module encodes binary data into ASCII strings using Base16, Base32, and Base64 algorithms.

It received a couple of new functions: [`b32hexencode()`](https://docs.python.org/3/library/base64#base64.b32hexencode) and [`b32hexdecode()`](https://docs.python.org/3/library/base64#base64.b32hexdecode), which use an extended 32-character alphabet according to [RFC 4648](https://datatracker.ietf.org/doc/html/rfc4648.html#section-7) (3.10+):

```python
import base64
bytes = b"python is awesome"

base64.b32encode(bytes)
# b'OB4XI2DPNYQGS4ZAMF3WK43PNVSQ===='

base64.b32hexencode(bytes)
# b'E1SN8Q3FDOG6ISP0C5RMASRFDLIG===='
```

[playground](https://stepik.org/lesson/717024/step/3)

Contributed by: [Filipe Laíns](https://github.com/FFY00)

## bisect

[`bisect`](https://docs.python.org/3/library/bisect) module works with sorted lists using binary search method. Main functions are:

-   [`bisect()`](https://docs.python.org/3/library/bisect#bisect.bisect) finds an item in the list;
-   [`insort()`](https://docs.python.org/3/library/bisect#bisect.insort) adds an item while retaining the order.

```python
import bisect

lst = [7, 11, 19, 42]
idx = bisect.bisect(lst, 12)
# idx == 2

bisect.insort(lst, 12)
# [7, 11, 12, 19, 42]
```

Since version 3.10, all module functions support the optional `key` parameter. It is a function that returns the value of a list item. It is convenient to use if the elements cannot be compared directly:

```python
import bisect
import operator

p1 = {"id": 11, "name": "Diane"}
p2 = {"id": 12, "name": "Bob"}
p3 = {"id": 13, "name": "Emma"}

key = operator.itemgetter("name")
people = sorted([p1, p2, p3], key=key)
# Bob, Diane, Emma

idx = bisect.bisect(people, "Dan")
# TypeError: '<' not supported between instances of 'str' and 'dict'

idx = bisect.bisect(people, "Dan", key=key)
# idx == 1
```

[playground](https://stepik.org/lesson/717024/step/4)

Contributed by: [Raymond Hettinger](https://github.com/rhettinger)

## builtins

[`builtins`](https://docs.python.org/3/library/builtins) module contains all the built-in functions and classes that programmers use without imports: `int`, `list`, `len()`, `open()` and the like.

```python
import builtins

list is builtins.list
# True

len is builtins.len
# True
```

The **string** received [`str.removeprefix()`](https://docs.python.org/3/library/stdtypes#str.removeprefix) and [`str.removesuffix()`](https://docs.python.org/3/library/stdtypes#str.removesuffix) methods, which cut off the string head and tail respectively (3.9+):

```python
s = "Python is awesome"

s.removeprefix("Python is ")
# 'awesome'

s.removesuffix(" is awesome")
# 'Python'
```

The **integer** received the [`int.bit_count()`](https://docs.python.org/3/library/stdtypes#int.bit_count) method, which returns the number of ones in the binary representation of the integer (3.10+):

```python
n = 42

bin(n)
# '0b101010'

n.bit_count()
# 3
```

The **dictionary** methods `dict.key()`, `dict.values()` and `dict.items()` return view objects that reference dictionary data. Previously, it was impossible to get a reverse link to the dictionary from these objects, but now it can be done — through the `.mapping` attribute (3.10+):

```python
people = {
    "Diane": 70,
    "Bob": 78,
    "Emma": 84
}

keys = people.keys()
# dict_keys(['Diane', 'Bob', 'Emma'])

keys.mapping["Bob"]
# 78
```

**Collection merging** [`zip()`](https://docs.python.org/3/library/functions#zip) function received the `strict` parameter. It ensures that the sequences are of the same length (3.10+):

```python
keys = ["Diane", "Bob", "Emma"]
vals = [70, 78, 84, 42]

pairs = zip(keys, vals)
list(pairs)
# [('Diane', 70), ('Bob', 78), ('Emma', 84)]

pairs = zip(keys, vals, strict=True)
list(pairs)
# ValueError: zip() argument 2 is longer than argument 1
```

[playground](https://stepik.org/lesson/717024/step/5)

Contributed by: [Dennis Sweeney](https://github.com/sweeneyde) • [Niklas Fiekas](https://github.com/niklasf) • [Brandt Bucher](https://github.com/brandtbucher)

## dataclasses

[`dataclasses`](https://docs.python.org/3/library/dataclasses) module generates classes according to the specification.

Dataclasses can now use [`slots`](https://docs.python.org/3/reference/datamodel.html#slots) for compact objects with a fixed set of properties (3.10+).

Regular dataclass:

```python
from dataclasses import dataclass

@dataclass
class Person:
    id: int
    name: str

diane = Person(id=11, name="Diane")
diane.__dict__
# {'id': 11, 'name': 'Diane'}
diane.salary = 70
# ok
```

Dataclass with slots:

```python
from dataclasses import dataclass

@dataclass(slots=True)
class SlotPerson:
    id: int
    name: str

bob = SlotPerson(id=12, name="Bob")
bob.__dict__
# AttributeError: 'SlotPerson' object has no attribute '__dict__'
bob.__slots__
# ('id', 'name')
bob.salary = 78
# AttributeError: 'SlotPerson' object has no attribute 'salary'
```

Besides, the dataclass can now be forced to accept keyword-only parameters when creating an object (3.10+):

```python
from dataclasses import dataclass

@dataclass(kw_only=True)
class KeywordPerson:
    id: int
    name: str

diane = KeywordPerson(id=11, name="Diane")
# ok
diane = KeywordPerson(11, "Diane")
# TypeError: KeywordPerson.__init__() takes 1 positional argument but 3 were given
```

[playground](https://stepik.org/lesson/717024/step/6)

Contributed by: [Yurii Karabas](https://github.com/uriyyo) • [Eric V. Smith](https://github.com/ericvsmith)

## datetime

[`datetime`](https://docs.python.org/3/library/datetime) module (unsurprisingly) deals with date and time.

It received new [`date.fromisocalendar()`](https://docs.python.org/3/library/datetime#datetime.date.fromisocalendar) and [`datetime.fromisocalendar()`](https://docs.python.org/3/library/datetime#datetime.datetime.fromisocalendar) constructors, which create a date from the `(year, week, week_day)` trio (3.8+):

```python
import datetime as dt

day = dt.date(2022, 9, 13)
day.isocalendar()
# datetime.IsoCalendarDate(year=2022, week=37, weekday=2)

year, week, day = day.isocalendar()
next_day = dt.date.fromisocalendar(year, week, day+1)
# datetime.date(2022, 9, 14)
```

Besides, the `.isocalendar()` method now returns a named `IsoCalendarDate` instead of the regular tuple (3.9+). You can see it in the example above.

[playground](https://stepik.org/lesson/717024/step/7)

Contributed by: [Paul Ganssle](https://github.com/pganssle) • [Dong-hee Na](https://github.com/corona10)

## fractions

[`fractions`](https://docs.python.org/3/library/fractions) module works with rational numbers.

It received the [`Fraction.as_integer_ratio()`](https://docs.python.org/3/library/fractions#fractions.Fraction.as_integer_ratio) method to return a fraction as a `(numerator, denominator)` pair, thereby fixing the age-old shame of the usual `float` (3.8+):

```python
(0.25).as_integer_ratio()
# (1, 4)

(0.5).as_integer_ratio()
# (1, 2)

(0.2).as_integer_ratio()
# (3602879701896397, 18014398509481984)
# oopsie
```

```python
from fractions import Fraction

Fraction("0.2").as_integer_ratio()
# (1, 5)
# so much better
```

To be fair, `decimal.Decimal` learned to do this back in 3.6. But it's still nice.

[playground](https://stepik.org/lesson/717024/step/8)

Contributed by: [Lisa Roach](https://github.com/lisroach) • [Raymond Hettinger](https://github.com/rhettinger)

## functools

[`functools`](https://docs.python.org/3/library/functools) module is a collection of higher-order auxiliary functions. One of them is [`lru_cache()`](https://docs.python.org/3/library/functools#functools.lru_cache), which caches expensive calculations:

```python
import functools
import time

@functools.lru_cache(maxsize=256)
def find_user(name):
    # imitating slow search
    time.sleep(1)
    user = {"id": 11, "name": "Diane"}
    return user

find_user("Diane")
# kinda slow

find_user("Diane")
# blazingly fast
```

Previously, it required to explicitly set the cache size. And now you can specify `@lru_cache` without arguments, using the default size of `128` (3.8+).

Besides, you can get the cache parameters (3.9+):

```python
find_user.cache_parameters()
# {'maxsize': 256, 'typed': False}
```

If you don't mind the memory usage, you can use the unlimited [`@cache`](https://docs.python.org/3/library/functools#functools.cache) instead of `@lru_cache` (3.9+).

New [`@cached_property`](https://docs.python.org/3/library/functools#functools.cached_property) decorator caches the calculated object property (3.8+):

```python
import functools
import statistics

class Dataset:
    def __init__(self, seq):
        self._data = tuple(seq)

    @functools.cached_property
    def stdev(self):
        return statistics.stdev(self._data)

dataset = Dataset(range(1_000_000))

dataset.stdev
# kinda slow

dataset.stdev
# blazingly fast
```

And [`@singledispatchmethod`](https://docs.python.org/3/library/functools#functools.singledispatchmethod) overloads the method depending on the parameter type (3.8+):

```python
import functools

class Divider:
    @functools.singledispatchmethod
    def divide(self, dividend, divisor):
        raise NotImplementedError("Do not know how to divide those")

    @divide.register
    def _(self, dividend: int, divisor: int):
        return dividend // divisor

    @divide.register
    def _(self, dividend: str, divisor: int):
        # this is really stupid, I know
        newlen = len(dividend) // divisor
        return dividend[:newlen]

divider = Divider()
divider.divide(10, 2)
# 5

divider.divide("hello world", 2)
# 'hello'
```

Smells like Java to me.

[playground](https://stepik.org/lesson/717024/step/9)

Contributed by: [Raymond Hettinger](https://github.com/rhettinger) • [Carl Meyer](https://github.com/carljm) • [Ethan Smith](https://github.com/ethanhs)

## glob

[`glob`](https://docs.python.org/3/library/glob) module searches for files and directories that match the template.

Now thanks to the `root_dir` parameter in [`glob()`](https://docs.python.org/3/library/glob#glob.glob) and [`iglob()`](https://docs.python.org/3/library/glob#glob.iglob) functions you can specify the root directory of the search (3.10+):

```python
import glob
import os

os.getcwd()
# '/'

glob.glob("*", root_dir="/usr")
# ['local', 'share', 'bin', 'lib', 'sbin', 'src']
```

It's a small thing, but it's nice.

[playground](https://stepik.org/lesson/717024/step/10)

Contributed by: [Serhiy Storchaka](https://github.com/serhiy-storchaka)

## graphlib

[`graphlib`](https://docs.python.org/3/library/graphlib) module works with graphs. And you know what? This is a brand-new module! (3.9+)

So far, it has only one feature — topological graph sorting (an ordering of vertices such that for any `u → v`, the vertex `u` comes before `v`):

```python
from graphlib import TopologicalSorter

graph = {"Diane": {"Bob", "Cindy"}, "Cindy": {"Alice"}, "Bob": {"Alice"}}
# Alice → Bob → Diane
#     ↳ Cindy ↗

sorter = TopologicalSorter(graph)
list(sorter.static_order())
# ['Alice', 'Cindy', 'Bob', 'Diane']
```

[playground](https://stepik.org/lesson/717025/step/2)

Contributed by: [Pablo Galindo](https://github.com/pablogsal) • [Tim Peters](https://github.com/tim-one) • [Larry Hastings](https://github.com/larryhastings)

## itertools

[`itertools`](https://docs.python.org/3/library/itertools) module provides a variety of iterators for memory-efficient collection processing.

One of them is the [`accumulate()`](https://docs.python.org/3/library/itertools#itertools.accumulate) function, which calculates the rolling aggregate. Now it allows the `initial` parameter, which sets the initial value (3.8+):

```python
import itertools

seq = [7, 11, 19, 42]

accumulator = itertools.accumulate(seq)
list(accumulator)
# [7, 18, 37, 79]

accumulator = itertools.accumulate(seq, initial=100)
list(accumulator)
# [100, 107, 118, 137, 179]
```

And the shiny new [`pairwise()`](https://docs.python.org/3/library/itertools#itertools.pairwise) function traverses the collection and yields pairs of consecutive elements (3.10+):

```python
import itertools

seq = [7, 11, 19, 42]
pairer = itertools.pairwise(seq)

list(pairer)
# [(7, 11), (11, 19), (19, 42)]
```

[playground](https://stepik.org/lesson/717025/step/3)

Contributed by: [Lisa Roach](https://github.com/lisroach) • [Raymond Hettinger](https://github.com/rhettinger)

## math

[`math`](https://docs.python.org/3/library/math) module includes an abundance of mathematical functions.

There are a lot of news here:

-   [`dist()`](https://docs.python.org/3/library/math#math.dist) calculates the Euclidean distance between points (3.8+);
-   [`perm()`](https://docs.python.org/3/library/math#math.perm) and [`comb()`](https://docs.python.org/3/library/math#math.comb) count the number of permutations and combinations (3.8+);
-   [`lcm()`](https://docs.python.org/3/library/math#math.lcm) computes the least common multiple (3.9+);
-   [`gcd()`](https://docs.python.org/3/library/math#math.gcd) now computes the greatest common divisor for an arbitrary number of arguments (3.9+).

```python
import math

math.dist((1,1), (4, 5))
# 5.0

math.perm(5, 2)
# 20

math.comb(5, 2)
# 10

math.lcm(9, 27, 60)
# 540

math.gcd(9, 27, 60)
# 3
```

And [`prod()`](https://docs.python.org/3/library/math#math.prod) multiplies the sequence elements (3.8+):

```python
import math

seq = range(3, 9)
math.prod(seq)
# 20160
```

[playground](https://stepik.org/lesson/717025/step/4)

Contributed by: [Raymond Hettinger](https://github.com/rhettinger) • [Yash Aggarwal](https://github.com/FR4NKESTI3N) • [Keller Fuchs](https://github.com/KellerFuchs) • [Serhiy Storchaka](https://github.com/serhiy-storchaka) • [Mark Dickinson](https://github.com/mdickinson) • [Ananthakrishnan](https://github.com/ananthan-123) • [Pablo Galindo](https://github.com/pablogsal)

## random

[`random`](https://docs.python.org/3/library/random) module handles random numbers.

New [`randbytes()`](https://docs.python.org/3/library/random#random.randbytes) method generates a random byte string (3.9+):

```python
import random

random.randbytes(4)
# b'\x8b\xd4\x8f\xc9'
```

[playground](https://stepik.org/lesson/717025/step/5)

Contributed by: [Victor Stinner](https://github.com/vstinner)

## shlex

[`shlex`](https://docs.python.org/3/library/shlex) module splits the string into tokens according to the Unix command line rules.

And now it also joins the tokens back into the string — thanks to the [`join()`](https://docs.python.org/3/library/shlex#shlex.join) function (3.8+):

```python
import shlex

tokens = ["echo", "-n", "Python is awesome"]
shlex.join(tokens)
# "echo -n 'Python is awesome'"
```

[playground](https://stepik.org/lesson/717025/step/6)

Contributed by: [Bo Bayles](https://github.com/bbayles)

## shutil

[`shutil`](https://docs.python.org/3/library/shutil) module works with files and directories: copies, moves and deletes them.

Copying directories has now become a little more convenient — kudos to the `dirs_exist_ok` parameter in the [`copytree()`](https://docs.python.org/3/library/shutil#shutil.copytree) function (3.8+). If it is on, the function allows the target directory to exist:

```python
from pathlib import Path
import shutil

tmp = Path("/tmp")

src = tmp.joinpath("src")
src.mkdir()
src.joinpath("src.txt").touch()
# /tmp/src
# /tmp/src/src.txt

dst = tmp.joinpath("dst")
dst.mkdir()
# /tmp/dst

shutil.copytree(src, dst)
# FileExistsError: [Errno 17] File exists: '/tmp/dst'
shutil.copytree(src, dst, dirs_exist_ok=True)
# PosixPath('/tmp/dst')
```

[playground](https://stepik.org/lesson/717025/step/7)

Contributed by: [Josh Bronson](https://github.com/jab)

## statistics

[`statistics`](https://docs.python.org/3/library/statistics) module handles mathematical statistics. Like `math`, it has greatly improved in recent releases. Not `scipy` yet, but it's not the kindergarten version Python had in 3.4.

See for yourself:

-   [`fmean()`](https://docs.python.org/3/library/statistics#statistics.fmean) computes the arithmetic mean (like `mean()`, only faster) (3.8+);
-   [`geometric_mean()`](https://docs.python.org/3/library/statistics#statistics.geometric_mean) computes the geometric mean (3.8+);
-   [`multimode()`](https://docs.python.org/3/library/statistics#statistics.multimode) returns the modes (the most frequent values in the dataset), even if there are multiple ones (in contrast to `mode()`) (3.8+);
-   [`quantiles()`](https://docs.python.org/3/library/statistics#statistics.quantiles) splits the dataset into quantiles and returns the cut points (3.8+).

```python
import statistics

seq = list(range(1, 10))

statistics.fmean(seq)
# 5.0

statistics.geometric_mean(seq)
# 4.147166274396913

statistics.multimode(seq)
# [1, 2, 3, 4, 5, 6, 7, 8, 9]
statistics.multimode("python is awesome")
# ['o', ' ', 's', 'e']

statistics.quantiles(seq)
# [2.5, 5.0, 7.5]
```

[`NormalDist`](https://docs.python.org/3/library/statistics#statistics.NormalDist) describes the normal distribution of a random variable (3.8+):

```python
from statistics import NormalDist

birth_weights = NormalDist.from_samples([2.5, 3.1, 2.1, 2.4, 2.7, 3.5])
drug_effects = NormalDist(0.4, 0.15)
combined = birth_weights + drug_effects

round(combined.mean, 1)
# 3.1

round(combined.stdev, 1)
# 0.5
```

The module received Pearson [`correlation()`](https://docs.python.org/3/library/statistics#statistics.correlation) and [`covariance()`](https://docs.python.org/3/library/statistics#statistics.covariance) functions (3.10+):

```python
import statistics

x = [1, 2, 3, 4, 5, 6, 7, 8, 9]
y = [9, 8, 7, 6, 5, 4, 3, 2, 1]

statistics.correlation(x, x)
# 1.0

statistics.correlation(x, y)
# -1.0

statistics.covariance(x, x)
# 7.5

statistics.covariance(x, y)
# -7.5
```

And even the [`linear_regression()`](https://docs.python.org/3/library/statistics#statistics.linear_regression) calculator (3.10+):

```python
import statistics

movies_by_year = {
    2000: 371,
    2003: 507,
    2006: 608,
    2009: 520,
    2012: 669,
    2015: 708,
    2018: 873,
    2021: 403,
}

x = movies_by_year.keys()
y = movies_by_year.values()
slope, intercept = statistics.linear_regression(x, y)

year_2022 = round(slope * 2022 + intercept)
# 697
```

By the way, the `statistics` module is also famous for its excellent documentation. Check it out.

[playground](https://stepik.org/lesson/717025/step/8)

Contributed by: [Raymond Hettinger](https://github.com/rhettinger) • [Steven D’Aprano](https://github.com/stevendaprano) • [Timothy Wolodzko](https://github.com/twolodzko)

## zoneinfo

[`zoneinfo`](https://docs.python.org/3/library/zoneinfo) module provides information about time zones around the world. Another new module! (3.9+)

Before the `zoneinfo` appearance, Python had a single ascetic `timezone.utc` time zone. Well, not anymore:

```python
import datetime as dt
from zoneinfo import ZoneInfo

utc = dt.datetime(2022, 9, 13, hour=21, tzinfo=dt.timezone.utc)
# 2022-09-13 21:00:00+00:00

paris = utc.astimezone(ZoneInfo("Europe/Paris"))
# 2022-09-13 23:00:00+02:00

tokyo = utc.astimezone(ZoneInfo("Asia/Tokyo"))
# 2022-09-14 06:00:00+09:00

sydney = utc.astimezone(ZoneInfo("Australia/Sydney"))
# 2022-09-14 07:00:00+10:00
```

[playground](https://stepik.org/lesson/717025/step/9)

Contributed by: [Paul Ganssle](https://github.com/pganssle)

## Summary

We have reviewed as many as 17 modules contributed by 27 devs — and this is without taking into account `asyncio`, `typing` and many other lower-level ones. As you can see, the standard library is actively developing. And the new features are quite reasonable. I hope you will find the described novelties useful!

I would also like to specifically thank the contributors for their amazing work:

-   [Carl Meyer](https://twitter.com/carljm) for the `functools.cached_property()` decorator;
-   [Dennis Sweeney](https://github.com/sweeneyde) for the `str.removeprefix()` and `str.removesuffix()` methods;
-   [Ethan Smith](https://twitter.com/ethanhs) for the `functools.singledispatchmethod()` decorator;
-   [Filipe Laíns](https://twitter.com/missingclara) for the `base64.b32hexencode()` and `base64.b32hexdecode()` functions;
-   [Lisa Roach](https://twitter.com/lisroach) for the `Fraction.as_integer_ratio()` method and `itertools.accumulate()` improvements;
-   [Niklas Fiekas](https://twitter.com/niklasfiekas) for the `int.bit_count()` method;
-   [Pablo Galindo](https://twitter.com/pyblogsal) for the whole `graphlib` module and `math.prod()` function;
-   [Paul Ganssle](https://twitter.com/pganssle) for the whole `zoneinfo` module;
-   [Raymond Hettinger](https://twitter.com/raymondh) for lots of functions in the `statistics` module, `itertools.pairwise()` function, `key` parameter in the `bisect` module and his community work;
-   [Serhiy Storchaka](https://twitter.com/serhiystorchaka) and [Yash Aggarwal](https://github.com/FR4NKESTI3N) for the combinatorics in the `math` module;
-   [Timothy Wolodzko](https://twitter.com/tymwol) for the `covariance()`, `correlation()`, and `linear_regression()` functions in the `statistics` module;
-   [Victor Stinner](https://twitter.com/victorstinner) for the `random.randbytes()` method.
