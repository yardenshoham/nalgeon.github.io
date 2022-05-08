+++
date = 2021-06-02T11:00:00Z
title = "Good Code Criterion"
description = "Optimize T, keep an eye on R."
image = "/good-code/cover.png"
slug = "good-code"
tags = ["software"]
+++

Good code is understandable and non-greedy. Let's talk about it.

## Time to understanding

The main criterion for good code is the time T it takes for a non-author to understand the code. Not "I sorta get it", but understand deep enough to make changes and not break anything.

The smaller the T, the better the code.

Let's say Alice and Bob implemented the same feature, and you want to modify it. If you understand Alice's code in 10 minutes, and Bob's code in 30 minutes - Alice's code is better. It doesn't matter how layered Bob's architecture is, whether he used a functional approach, a modern framework, etc.

The T-metric is different for a beginner and an experienced programmer. Therefore, it makes sense to focus on the average level of devs who will use the code. If you have a team of people working for 10+ years, and everyone writes compilers in their spare time - even very complex code will have a low T. If you have a huge turnover and hire yesterday's students — the code should be rather primitive so that T does not shoot through the roof.

It's not easy to measure T directly, so usually, teams track secondary metrics that affect T:

-   code style (`black` for Python),
-   code smells (`pylint`, `flake8`),
-   cyclomatic complexity (`mccabe`),
-   module dependencies (`import-linter`).

Plus code review.

## Resource usage

The second criterion for good code is the amount of resources R it consumes (time, CPU, memory, disk). The smaller the R, the better the code.

If Alice and Bob implemented a feature with the same T, but Alice's code time complexity is O(n), and Bob's is O(n²) (with the same consumption of other resources) - Alice's code is better.

Note about the notorious "sacrifice readability for efficiency". For each task, there is a resource consumption threshold R0, which the solution should not exceed. If R < R0, do not degrade T for the sake of further reducing R.

If a non-critical service processes a request in 50ms, you don't need to rewrite it from Python to C to reduce the time to 5ms. The thing is already fast enough.

If the code has a high T and a low R, in most cases you can reduce T while keeping R < R0.

But sometimes, if resources are limited, or the input data is huge, it may not possible to reach R < R0 without degrading T. Then you really have to sacrifice clarity. But make sure that:

1. This is the last resort when all the other options have failed.
2. The code sections where T is traded for R are well isolated.
3. There are few such sections.
4. They are well-documented.

## Summary

Here is the mnemonics for good code:

<pre class="big">
T↓ R&lt;R0
</pre>

Optimize T, keep an eye on R. Your team will thank you.

_Thanks for reading! Follow **[@ohmypy](https://twitter.com/ohmypy)** on Twitter to keep up with new posts 🚀_
