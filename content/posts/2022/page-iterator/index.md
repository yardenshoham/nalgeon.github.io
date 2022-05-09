+++
date = 2022-05-02T13:00:00Z
title = "Page iterator in Python"
description = "Traverse dataset in pages for faster batch processing."
image = "/page-iterator/cover.png"
slug = "page-iterator"
tags = ["python"]
+++

Suppose you are counting stats for a huge dataset of toys sold across the country over the past year:

```python
reader = fetch_toys()
for item in reader:
    process_single(item)
```

`process_single()` takes 10 ms, so 400 million toys will be processed in 46 days 😱

After a number of intense conversations, you manage to convince the developers that it's not very fast. `process_batch()` function enters the scene. It processes 10,000 toys in 1 second. It means 11 hours for all the toys — much nicer.

Now we need to iterate over the dataset in batches of 10 thousand records. This is where the page iterator comes in handy!

## Naive paginator

Let's go through the initial sequence, gradually filling the page. As soon as it is filled, return it through `yield` and start filling in the next one. Continue until the original sequence is exhausted:

```python
def paginate(iterable, page_size):
    page = []
    for item in iterable:
        page.append(item)
        if len(page) == page_size:
            yield page
            page = []
    yield page
```

```python
reader = fetch_toys()
page_size = 10_000
for page in paginate(reader, page_size):
    process_batch(page)
```

The implementation is working, but there is a problem. Such page-by-page traversal is noticeably slower than the one-by-one iteration.

## Iteration speed

Let's compare two traversals — one-by-one and paginated:

```python
def one_by_one(a, b):
    """Processes records one-by-one, without pagination"""
    rdr = reader(a, b)
    for record in rdr:
        process_single(record)

def batch(page_size, a, b):
    """Processes records in batches, with pagination"""
    rdr = reader(a, b)
    for page in paginate(rdr, page_size):
        process_batch(page)

times = 10

page_size = 10_000
a = 1_000_000
b = 2_000_000

fn = lambda: one_by_one(a, b)
total = timeit.timeit(fn, number=times)
it_time = round(total * 1000 / times)
print(f"One-by-one (baseline): {it_time} ms")

fn = lambda: batch(page_size, a, b)
total = timeit.timeit(fn, number=times)
it_time = round(total * 1000 / times)
print(f"Fill page with append(): {it_time} ms")
```

Here is the result for 1 million records and a page size of 10 thousand:

```
One-by-one (baseline):   161 ms
Fill page with append(): 227 ms
```

Page-by-page iteration is almost 1.5 times slower!

At each iteration of the loop, we create a new empty list and then gradually fill it in. Python has to constantly increase the size of the underlying array, and this is an expensive operation — O(n) of the number of elements in the list.

## Fixed page size

Let's create a list of the required size in advance and use it for all pages:

```python
def paginate(iterable, page_size):
    page = [None] * page_size
    idx = 0
    for item in iterable:
        page[idx] = item
        idx += 1
        if idx == page_size:
            yield page
            idx = 0
    yield page[:idx]
```

Compare once again:

```
One-by-one (baseline):   161 ms
Fill page with append(): 227 ms
Use fixed-size page:     162 ms
```

Much faster! Fixed page algorithm is as fast as the ordinary one-by-one traversal.

## Slicing iterator

Can we do even better? Algorithmically, no. But practically, yes — if we move most of the operations from Python code to C library code. The `itertools()` module and its `islice()` function may help:

```python
def paginate(iterable, page_size):
    it = iter(iterable)
    slicer = lambda: list(itertools.islice(it, page_size))
    return iter(slicer, [])
```

Here is what's going on:

-   `islice()` creates an iterator (let's call it a slicer) that traverses the passed sequence until it yields `page_size` elements;
-   `list()` fetches elements from the slicer, thus creating a page;
-   since `islice()` runs on top of the main iterator, the next time it is called, it will continue from the same place where it left off before;
-   the `iter(slicer, [])` expression creates an iterator that calls the slicer at each step;
-   thus, the `paginate()` function returns an iterator, which at each step yields the next page through the slicer, traversing the main sequence until it ends.

Look how good this implementation is:

```
One-by-one (baseline):   161 ms
Fill page with append(): 227 ms
Use fixed-size page:     162 ms
Use islice:               93 ms
```

40% faster than the one-by-one iterator!

## Summary

Page-by-page traversal works fine whenever a batch operation is much faster than a sequence of single operations. In order not to implement such traversal every time from scratch, it is convenient to use a _page iterator_.

Filling the page with `.append()` is slow due to array resizing. It is better to use a fixed-size list, or even better, iteration based on `itertools.islice()`

Totally recommend it.

[Playground](https://replit.com/@antonz/page-iterator#main.py)
