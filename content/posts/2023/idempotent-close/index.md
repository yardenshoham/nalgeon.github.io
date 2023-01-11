+++
date = 2023-01-11T11:00:00Z
title = "Idempotent Close in Go"
description = "How to free the resources safely."
image = "/idempotent-close/cover.png"
slug = "idempotent-close"
tags = ["thank-go"]
+++

_Idempotence_ is when a repeated call to an operation on an object does not result in changes or errors. Idempotence is a handy development tool.

Let's see how idempotence helps to free the occupied resources safely.

## Idempotent Close

Suppose we have a gate:

```go
type Gate struct{
    // internal state
    // ...
}
```

The `NewGate()` constructor opens the gate, acquires some system resources, and returns an instance of the `Gate`.

```go
g := NewGate()
```

In the end, we must release the occupied resources:

```go
func (g *Gate) Close() error {
    // free acquired resources
    // ...
    return nil
}

g := NewGate()
defer g.Close()
// do stuff
// ...
```

Problems arise when in some branch of the code, we want to close the gate explicitly:

```go
g := NewGate()
defer g.Close()

err := checkSomething()
if err != nil {
    g.Close()
    // do something else
    // ...
    return
}

// do more stuff
// ...
```

The first `Close()` will work, but the second (via `defer`) will break because the resources have already been released.

The solution is to make `Close()` idempotent so that repeated calls do nothing if the gate is already closed:

```go
type Gate struct{
    closed bool
    // internal state
    // ...
}

func (g *Gate) Close() error {
    if g.closed {
        return nil
    }
    // free acquired resources
    // ...
    g.closed = true
    return nil
}
```

[playground](https://go.dev/play/p/LFEThpm1nTs)

Now we can call `Close()` repeatedly without any problems. Until we try to close the gate from different goroutines — then everything will fall apart.

## Idempotency in a concurrent environment

We have made the gate closing idempotent — safe for repeated calls:

```go
func (g *Gate) Close() error {
    if g.closed {
        return nil
    }
    // free acquired resources
    // ...
    g.closed = true
    return nil
}
```

But if several goroutines use the same `Gate` instance, a simultaneous call to `Close()` will lead to races — a concurrent modification of the `closed` field. We don't want this.

We have to protect the `closed` field access with a mutex:

```go
type Gate struct {
    mu     sync.Mutex
    closed bool
    // internal state
    // ...
}

func (g *Gate) Close() error {
    g.mu.Lock()

    if g.closed {
        g.mu.Unlock()
        return nil
    }
    // free acquired resources
    // ...

    g.closed = true
    g.mu.Unlock()
    return nil
}
```

[playground](https://go.dev/play/p/i3pFy362YEi)

The mutex ensures that only a single goroutine executes the code between `Lock()` and `Unlock()` at any given time.

Now multiple calls to `Close()` work correctly in a concurrent environment.

That's it!
