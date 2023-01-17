+++
date = 2023-01-17T09:20:00Z
title = "Atomic operations composition in Go"
description = "Examining atomicity and predictability of operations in a concurrent environment."
image = "/atomics-composition/cover.png"
slug = "atomics-composition"
tags = ["thank-go"]
+++

An atomic operation in a concurrent program is a great thing. Such operation transforms into a single processor instruction, so it does not require locks. You can safely call it from different goroutines and receive a predictable result.

But what happens if you abuse atomics? Let's figure it out.

## Atomicity

Let's look at a function that increments a counter:

```go
var counter int32

func increment() {
    counter += 1
    // random sleep up to 10 ms
    sleep(10)
    counter += 1
}
```

If we call it 100 times in a single goroutine:

```go
for i := 0; i < 100; i++ {
    increment()
}
```

then `counter` is guaranteed to equal 200.

In a concurrent environment, `increment()` is unsafe due to races on `counter += 1`. Now I will try to fix it and propose several options.

In each case, answer the question: if you call `increment()` from 100 goroutines, is the final value of the `counter` guaranteed?

**Example 1**

```go
var counter atomic.Int32

func increment() {
    counter.Add(1)
    sleep(10)
    counter.Add(1)
}
```

Is the `counter` value guaranteed?

<details>
    <summary>Answer</summary>
    <p>It is guaranteed.</p>
</details>

**Example 2**

```go
var counter atomic.Int32

func increment() {
    if counter.Load()%2 == 0 {
        sleep(10)
        counter.Add(1)
    } else {
        sleep(10)
        counter.Add(2)
    }
}
```

Is the `counter` value guaranteed?

<details>
    <summary>Answer</summary>
    <p>It's not guaranteed.</p>
</details>

**Example 3**

```go
var delta atomic.Int32
var counter atomic.Int32

func increment() {
    delta.Add(1)
    sleep(10)
    counter.Add(delta.Load())
}
```

Is the `counter` value guaranteed?

<details>
    <summary>Answer</summary>
    <p>It's not guaranteed.</p>
</details>

## Composition of Atomic Operations

People sometimes think that the composition of atomics also magically becomes an atomic operation. But this is not the case.

For example, the second of the above examples:

```go
var counter atomic.Int32

func increment() {
    if counter.Load()%2 == 0 {
        sleep(10)
        counter.Add(1)
    } else {
        sleep(10)
        counter.Add(2)
    }
}
```

Call `increment()` 100 times from different goroutines:

```go
var wg sync.WaitGroup
wg.Add(100)

for i := 0; i < 100; i++ {
    go func() {
        increment()
        wg.Done()
    }()

}

wg.Wait()
fmt.Println(counter.Load())
```

Run with the `-race` flag — there are no races. But can we guarantee what the `counter` value will be in the end? Nope.

```
% go run atomic-2.go
192
% go run atomic-2.go
191
% go run atomic-2.go
189
```

Despite the absence of races, `increment()` is not atomic.

Check yourself by answering the question: in which example is `increment()` an atomic operation?

<details>
    <summary>Answer</summary>
    <p>In none of them.</p>
</details>

## Atomicity and Sequence-Independence

In all examples, `increment()` is not an atomic operation. The composition of atomics is always non-atomic.

The first example, however, guarantees the final value of the `counter` in a concurrent environment:

```go
var counter atomic.Int32

func increment() {
    counter.Add(1)
    sleep(10)
    counter.Add(1)
}
```

If we run 100 goroutines, the `counter` will ultimately equal 200 (if there were no errors during execution).

The reason is that `Add()` is a sequence-independent operation. The runtime can perform such operations in any order, and the result will not change.

The second and third examples use sequence-dependent operations. When we run 100 goroutines, the order of operations is different each time. Therefore, the result is also different.

In general, despite the apparent simplicity of atomics, use them cautiously. Mutex is less shiny but more error-proof.
