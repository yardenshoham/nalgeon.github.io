+++
date = 2022-05-08T11:30:00Z
title = "Storing state in the URL"
description = "So that the app does not reset to zero after page refresh."
image = "/storing-state/cover.png"
slug = "storing-state"
tags = ["software"]
+++

If you are developing a web application, sooner or later you will face the problem of saving the local system state for the user.

Imagine you sell elite potatoes over the Internet. The buyer visits the website and enters the search criteria:

-   strictly from Bolivia or South Africa,
-   harvest of 2022,
-   tuber size from 3 to 7 cm,
-   preferably in the form of a sea seal.

The buyer then receives a list of 300 items (seal-shaped potatoes are quite popular in South Africa), split into 6 pages of 50 items each. They load the third page, open the potato card and freeze in silent admiration for a few seconds. And then accidentally refresh the page. What will your application do?

## Don't store state at all

Let's say you didn't bother with the state or store it in memory. Then after page reload the current context will be lost. The user will be redirected to the main page, where they will stare in disbelief at the giant "ELITE POTATOES" heading.

This is how Google calendar used to behave. No matter how you navigate around the calendar, no matter what filters you apply, the URL always stayed the same:

    https://www.google.com/calendar/render

Refresh the page — and the calendar happily resets to the current week. Ouch.

## Store state locally

Most services understand that it is not OK to lose context after page refresh. They store the state on the client side (using Web Storage, IndexedDB or other means). This solves the problem with page refreshes, but still won't help with bookmarking.

Plus, such approach creates a problem with conflicting state changes. I opened two browser tabs, went to your potato website, searched for "young potatoes" in the first tab and for "bushy leaves" in the second one. Which query will the app remember?

## Store a set of GET parameters

Ever since the days when the dynamic nature of websites was limited to the `<blink>` tag, some considered a best practice to store the state in the URL. Such URL is great for emailing or bookmarking — there is no problem restoring the context:

    https://potato.shop/catalog/?search=wild+potatoes&country=bo,za&size=3-7&page=5

URL state makes each browser tab completely independent. No shared data in the local storage means no conflicts. It simplifies developer's life, and the user does not have to scratch their head over the mysterious system glitches.

## Store serialized state

GET parameters do an excellent job with scalar values (strings, numbers, booleans). But they are less suitable for collections and more complex structures. That's why programmers sometimes do this:

-   represent the state in the form of a dictionary;
-   serialize it to Base64;
-   pass it as the single URL parameter.

For example, for this state:

```json
{
    "search": "wild potatoes",
    "country": ["bo", "za"],
    "size": { "min": 3, "max": 7 },
    "page": 5
}
```

One will get this URL:

    https://potato.shop/catalog/?state=eyJzZWFyY2giOiJ3aWxkIHBvdGF0b2VzIiwiY291bnRyeSI6WyJibyIsInphIl0sInNpemUiOnsibWluIjozLCJtYXgiOjd9LCJwYWdlIjo1fQ==

## Hybrid approaches

One can store only the main parameters in the URL, and additional ones in the local storage:

    https://potato.shop/catalog/?search=wild+potatoes&page=10

One can pass the main parameters explicitly, and the additional ones as the serialized blob:

    https://potato.shop/catalog/?search=wild+potatoes&state=eyJjb3VudHJ5IjpbImJvIiwiemEiXSwic2l6ZSI6eyJtaW4iOjMsIm1heCI6N30sInBhZ2UiOjV9

There are also more creative options.

For example, one can store the state of the potato list locally. When a visitor requests a specific potato item, open it in a new tab — to not bother restoring the list state later.

Or one can implement an URL shortener of sorts. Store the full state on the server, generate a unique link like `https://potato.shop/catalog/xKda7` and serve it to the client.

## Summary

The main ways of storing the local state on the web are:

-   no storage at all;
-   local storage;
-   URL parameters;
-   serialized dictionary.

Personally, I prefer URL parameters. But whatever approach you choose — make sure to save and restore the context transparently for the user.

_Follow **[@ohmypy](https://twitter.com/ohmypy)** on Twitter to keep up with new posts 🚀_
