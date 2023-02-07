+++
date = 2023-02-07T12:00:00Z
title = "Cherry-Picked Features from Go 1.20"
description = "Multi-errors, context cancellation cause, new date formats, and other notable changes."
image = "/go-1-20/cover.png"
slug = "go-1-20"
tags = ["thank-go"]
+++

Go 1.20 brought a lot of new features and improvements. In this post, I'd like to review the ones that caught my eye. This is by no means an exhaustive list; for that, see the official [release notes](https://tip.golang.org/doc/go1.20).

These are the topics for review:

- [Multi-errors](#multi-errors)
- ['Context Canceled' Cause](#context-canceled-cause)
- [New Date Formats](#new-date-formats)
- [Slice to Array Conversion](#slice-to-array-conversion)
- [Other Notable Changes](#other-notable-changes)

Each section has a playground link, so check those out.

## Multi-errors

The "errors as values" concept (as opposed to exceptions) has gained renewed popularity in modern languages such as Go and Rust. You know this well because it's impossible to take a step without tripping over an error value in Go.

Go 1.20 has brought us new joy — the combination of errors through `errors.Join()`:

```go
errRaining := errors.New("it's raining")
errWindy := errors.New("it's windy")
err := errors.Join(errRaining, errWindy)
```

Now `err` is both `errRaining` and `errWindy` at the same time. The standard functions `errors.Is()` and `errors.As()` can work with this:

```go
if errors.Is(err, errRaining) {
    fmt.Println("ouch!")
}
// ouch!
```

`fmt.Errorf()` has also learned to combine errors:

```go
err := fmt.Errorf(
    "reasons to skip work: %w, %w",
    errRaining,
    errWindy,
)
```

To accept multiple errors in your own error type, return `[]error` from the `Unwrap()` method:

```go
type RefusalErr struct {
    reasons []error
}

func (e RefusalErr) Unwrap() []error {
    return e.reasons
}

func (e RefusalErr) Error() string {
    return fmt.Sprintf("refusing: %v", e.reasons)
}
```

If you love errors, this change will definitely be to your liking. If not... well, you always have panic :)

[playground](https://go.dev/play/p/CftXuesNA1q)

## 'Context Canceled' Cause

A `context.Canceled` error occurs when the context is canceled. This is no news:

```go
ctx, cancel := context.WithCancel(context.Background())
cancel()

fmt.Println(ctx.Err())
// context canceled
```

Starting from 1.20, we can create a context using `context.WithCancelCause()`. Then `cancel()` will take one parameter — the root _cause_ of the error:

```go
ctx, cancel := context.WithCancelCause(context.Background())
cancel(errors.New("the night is dark"))
```

`context.Cause()` extracts the cause of the error from the context:

```go
fmt.Println(ctx.Err())
// context canceled

fmt.Println(context.Cause(ctx))
// the night is dark
```

You may ask — why `context.Cause()`? It seems logical to add the `Cause()` method to the context itself, similar to the `Err()` method.

Sure. But `Context` is an interface. And any change to the interface breaks backward compatibility. That's why it was done differently.

[playground](https://go.dev/play/p/oDLOGfzSUvS)

## New Date Formats

_Please don't be offended by this section if you are a North American. We love you people, but sometimes your view of the world can be a bit... biased._

You surely know that the Go authors chose a quite unorthodox format for the date and time layout.

For example, parsing the date `2023-01-25 09:30` looks like this:

```go
const layout = "2006-01-02 15:04"
t, _ := time.Parse(layout, "2023-01-25 09:30")
fmt.Println(t)
// 2023-01-25 09:30:00 +0000 UTC
```

While `01/02 03:04:05PM '06` may be a nice mnemonic in the US, it's entirely cryptic for the European (or Asian) eye.

The Go authors have thoughtfully provided 12 standard date/time masks, of which only `RFC3339` and `RFC3339Nano` are suitable for non-Americans. Others are as mysterious as the imperial measurement system:

```go
Layout      = "01/02 03:04:05PM '06 -0700"
ANSIC       = "Mon Jan _2 15:04:05 2006"
UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
RFC822      = "02 Jan 06 15:04 MST"
RFC822Z     = "02 Jan 06 15:04 -0700"
RFC850      = "Monday, 02-Jan-06 15:04:05 MST"
RFC1123     = "Mon, 02 Jan 2006 15:04:05 MST"
RFC1123Z    = "Mon, 02 Jan 2006 15:04:05 -0700"
Kitchen     = "3:04PM"
```

Ten years have passed, and the Go development team began to suspect something. They learned that there are several other popular date formats worldwide. And, starting with version 1.20, they added three new masks:

```go
DateTime = "2006-01-02 15:04:05"
DateOnly = "2006-01-02"
TimeOnly = "15:04:05"
```

Now we can finally do this:

```go
t, _ := time.Parse(time.DateOnly, "2023-01-25")
fmt.Println(t)
// 2023-01-25 00:00:00 +0000 UTC
```

Nice!

[playground](https://go.dev/play/p/d3Vfyt43c0v)

## Slice to Array Conversion

Starting from version 1.17, we can get a pointer to an array under the slice:

```go
s := []int{1, 2, 3}
arrp := (*[3]int)(s)
```

By changing the array through the pointer, we are also changing the slice:

```go
arrp[2] = 42
fmt.Println(s)
// [1 2 42]
```

In Go 1.20, we can also get a copy of the array under the slice:

```go
s := []int{1, 2, 3}
arr := [3]int(s)
```

Changes in such an array are not reflected in the slice:

```go
arr[2] = 42
fmt.Println(arr)
// [1 2 42]
fmt.Println(s)
// [1 2 3]
```

This is, in essence, syntactic sugar because we could get a copy of the array before:

```go
s := []int{1, 2, 3}
arr := *(*[3]int)(s)
```

The new notation is cleaner, of course.

[playground](https://go.dev/play/p/9eTgSj2MO4V)

## Other Notable Changes

**bytes.Clone()** function clones a byte slice:

```go
b := []byte("abc")
clone := bytes.Clone(b)
```

**math/rand** package now automatically initializes the random number generator with a random starting value, so there is no need for a separate `rand.Seed()` call.

**strings.CutPrefix()** and `strings.CutSuffix()` functions trim a prefix/suffix from a string similarly to `TrimPrefix`/`TrimSuffix`, but they also indicate whether the prefix was present in the string:

```go
s := "> go!"
s, found := strings.CutPrefix(s, "> ")
fmt.Println(s, found)
// go! true
```

**sync.Map** now has atomic methods `Swap`, `CompareAndSwap`, and `CompareAndDelete`:

```go
var m sync.Map
m.Store("name", "Alice")
prev, ok := m.Swap("name", "Bob")
fmt.Println(prev, ok)
// Alice true
```

**time.Compare()** function compares two times and returns -1/0/1 based on the comparison results:

```go
t1 := time.Now()
t2 := t1.Add(10 * time.Minute)
cmp := t2.Compare(t1)
fmt.Println(cmp)
// 1
```

Overall, a great release! Looking forward to trying everything in production.
