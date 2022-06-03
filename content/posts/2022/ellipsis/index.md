+++
date = 2022-06-03T10:50:00Z
title = "Expressive Ellipsis in Python"
description = "What is Ellipsis and how it is used."
image = "/ellipsis/cover.png"
slug = "ellipsis"
tags = ["python"]
+++

One of the lesser-known things in Python is the ellipsis:

```python
class Flyer:
    def fly(self):
        ...
```

This code works. The `...` (aka `Ellipsis`) is a real object that can be used in code.

`Ellipsis` is the only instance of the `EllipsisType` type (similar to how `None` is the only instance of the `NoneType` type):

```python
>>> ... is Ellipsis
>>> True
>>> Ellipsis is ...
>>> True
```

Python core devs mostly use `...` to show that a type, method, or function has no implementation — as in the `fly()` example.

And in [type hints](https://docs.python.org/3/library/typing.html):

> It is possible to declare the return type of a callable without specifying the call signature by substituting a literal ellipsis for the list of arguments in the type hint: `Callable[..., ReturnType]`

> To specify a variable-length tuple of homogeneous type, use literal ellipsis, e.g. `Tuple[int, ...]`. A plain `Tuple` is equivalent to `Tuple[Any, ...]`, and in turn to tuple.

```python
# numbers  is a tuple of integer numbers
# summator is a function that accepts arbitrary parameters
#          and returns an integer
def print_sum(numbers: tuple[int, ...], summator: Callable[..., int]):
    total = summator(numbers)
    print(total)

print_sum((1, 2, 3), sum)
# 6
```

Other developers use Ellipsis for all sorts of bizarre things ツ
