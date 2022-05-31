+++
date = 2022-05-23T15:30:00Z
title = "Random numbers and sequences in Python"
description = "There is much more than just randint()"
image = "/random/cover.png"
slug = "random"
tags = ["python"]
+++

Everybody knows about `random.randint(a, b)` in Python, which returns a ≤ n ≤ b:

```python
random.randint(10, 99)
# 59
```

But the `random` module has so much more to offer.

Like selecting a number from a range **with a step**:

```python
random.randrange(10, 99, 3)
# 91
```

Or a random **sequence element**:

```python
numbers = [7, 9, 13, 42, 64, 99]
random.choice(numbers)
# 42
```

Or **multiple** elements:

```python
numbers = range(99, 10, -1)
random.choices(numbers, k=3)
# [32, 62, 76]
```

How about choosing some elements **more often** than others? Sure:

```python
numbers = [7, 9, 13, 42, 64, 99]
weights = [10, 1, 1, 1, 1, 1]

random.choices(numbers, weights, k=3)
# [42, 13, 7]

random.choices(numbers, weights, k=3)
# [7, 7, 7]

random.choices(numbers, weights, k=3)
# [13, 7, 7]
```

Wanna see a sample **without repetitions**? No problem:

```python
numbers = [7, 9, 13, 42, 64, 99]
random.sample(numbers, k=3)
# [42, 99, 7]
```

Or even **shuffle** the whole sequence:

```python
numbers = [1, 2, 3, 4, 5]
random.shuffle(numbers)
# [3, 2, 1, 5, 4]
```

There are also countless **real-valued** distributions like `uniform()`, `gauss()`, `expovariate()`, `paretovariate()` and many more. Not gonna get into the specifics now — [see for yourself](https://docs.python.org/3/library/random.html#real-valued-distributions) if your are a statistics fan.

Last but not least. When testing, **seed** the generator with a constant so that it gives reproducible results:

```python
random.seed(42)
```

On the contrary, use `seed()` without arguments in production. Python will then use the sources of randomness provided by the operating system.
