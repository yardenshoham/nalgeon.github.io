+++
date = 2022-05-31T17:00:00Z
title = "Flying Pig, or Protocols in Python"
description = "Structural subtyping using protocols."
image = "/protocol/cover.png"
slug = "protocol"
tags = ["python"]
+++

Let's say you've developed a utility that sends everything flying:

```python
def launch(thing):
    thing.fly()
```

Well, not exactly _everything_. Things with the `fly()` method, to be precise. With a single handy function we launch Frank (he's a pigeon), an airplane, and even Superman:

```python
class Frank:
    def fly(self):
        print("💩")

class Plane:
    def fly(self):
        print("Flight delayed")

class Superman:
    def fly(self):
        print("ε===(っ≧ω≦)っ")
```

Whoosh:

```python
f = Frank()
launch(f)
# 💩

p = Plane()
launch(p)
# Flight delayed

s = Superman()
launch(s)
# ε===(っ≧ω≦)っ
```

It's not that our heroes are particularly successful at coping with the task, but the launch works for them.

So far, so good. But sometimes (especially when the program grows) the developer wants to add a little rigor. Make it clear that the `thing` parameter in `launch()` is not any object, but necessarily a flying thing with the `fly()` method. What is the best way to do this?

## Using a description

If you prefer to avoid types, then you will go with a variable name or a docstring:

```python
def launch(flyer):
    """Launces a flyer (an object with a `fly()` method)"""
    flyer.fly()
```

The problem is that the more complex the code, the more often the "descriptive" approach fails.

## Using a base class

Thanks to some 1990s java programming skills, you end up with a small hierarchy:

```python
class Flyer:
    def fly():
        ...

class Frank(Flyer):
    # ...

class Plane(Flyer):
    # ...

class Superman(Flyer):
    # ...
```

```python
def launch(thing: Flyer):
    thing.fly()
```

This method works:

```bash
$ mypy flyer.py
Success: no issues found in 1 source file
```

But, as the Python devs say, it is terribly "unpythonic":

> The problem is that a class has to be explicitly marked, which is unpythonic and unlike what one would normally do in idiomatic dynamically typed Python code.

Indeed. Not only have we modified three classes instead of one function. Not only have we introduced an inheritance hierarchy to our code. But also Frank, the plane and Superman are now burdened by the shared knowledge that they are Flyers. They never asked for this, you know.

## Using a protocol

The quote above is from [PEP 544](https://peps.python.org/pep-0544/) (Python Enhancement Proposal), which was implemented in Python 3.8. Starting with this version, Python recieved _protocols_.

Protocols describe behavior. Here is our Flyer:

```python
from typing import Protocol

class Flyer(Protocol):
    def fly(self):
        ...
```

We use a protocol to specify that an object should have a specific behavior. The `launch()` function can only launch Flyers:

```python
def launch(thing: Flyer):
    thing.fly()
```

The objects themselves do not need to know about the protocol. It is enough that they implement the right behavior:

```python
class Frank:
    def fly(self):
        # ...

class Plane:
    def fly(self):
        # ...

class Superman:
    def fly(self):
        # ...
```

Protocols are static duck typing:

-   the interface is explicitly described in the protocol: a flyer has the `fly()` method;
-   but it is implemented implicitly, according to the "duck" principle: Superman has the `fly()` method — so he's a flyer.

Let's check:

```bash
$ mypy flyer.py
Success: no issues found in 1 source file
```

Perfect!

## Summary

If your code should work consistently with different types, find their common behavior and specify it in the protocol. Use the protocol type for static code validation using mypy.

Avoid pigeons, planes, and superheroes whenever possible. They are nothing but problems.
