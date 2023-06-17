+++
date = 2023-06-17T04:00:00Z
title = "I Don't Need Your Query Language"
description = "Seriously, I don't. I'd prefer SQL."
image = "/fancy-ql/cover.png"
slug = "fancy-ql"
tags = ["data"]
+++

_This post may seem a bit harsh, but I'm tired of the "SQL shaming" that has somehow become a thing in the industry. I have a right to disagree, don't I?_

Every year or so, a new general-purpose database engine comes out. And that's great! It can bring new valuable approaches, architectures, and tools (plus, building database engines is fun).

Often this new database engine comes with a new query language. And that's probably good, too. Or maybe it's not.

## Simple and elegant

<figure>
    <img src="fancy-1.png" alt="An elegant query language for a more civilized age">
    <figcaption>Oh, it's elegant and civilized? Sure, I'll bite.</figcaption>
</figure>

What puzzles me is that every time the authors claim that having this brand-new query language is somehow a strength. It's not. It's a weakness. Learning a whole new language just to query your database is a burden. I don't want to do that.

We already have a common ground language for general-purpose databases. It's called SQL. I'd rather use it with your database.

📝 _I'm not talking about software that targets a specific narrow domain field. Having a separate domain language for specific use cases makes perfect sense._

Sure, your language is elegant. That doesn't help me. First, it's still easier to write a slightly longer query in SQL than to learn a new query language. Second, your supposedly simple language will become complex anyways — as soon as I try to solve real-world tasks with it. So why bother?

## Better than SQL

<figure>
    <img src="fancy-2.png" alt="A comparison that speaks for itself">
    <figcaption>Just look at that ugly SQL beast.</figcaption>
</figure>

Sometimes the authors of a new query language try to frame SQL as terribly complex. Let's take an example from one of these "post-SQL" databases. A comparison that, according to the authors, speaks for itself.

📝 _I'm using a particular "post-SQL" database (without naming it) to illustrate my point here, because its landing page is a vivid example of "SQL shaming". This is not a criticism of the database or its authors. I'm sure it's a great product._

FancyQL:

```
select Movie {
  title,
  actors: {
   name
  },
};
```

SQL (as the authors of FancyQL see it):

```sql
SELECT
  title,
  Actors.name AS actor_name
FROM Movie
 LEFT JOIN Movie_Actors ON
  Movie.id = Movie_Actors.movie_id
 LEFT JOIN Person AS Actors ON
  Movie_Actors.person_id = Person.id
```

SQL (as it may be):

```sql
select
  title,
  actors.name
from movies
  join movies_actors using(movie_id)
  join actors using(actor_id)
```

Hmm. Another example?

FancyQL:

```
select Movie {
  title,
  actors: {
   name
  },
  rating := math::mean(.reviews.score)
} filter "Zendaya" in .actors.name;
```

SQL (as the authors of FancyQL see it):

```sql
SELECT
  title,
  Actors.name AS actor_name,
  (SELECT avg(score)
    FROM Movie_Reviews
    WHERE movie_id = Movie.id) AS rating
FROM
  Movie
  LEFT JOIN Movie_Actors ON
    Movie.id = Movie_Actors.movie_id
  LEFT JOIN Person AS Actors ON
    Movie_Actors.person_id = Person.id
WHERE
  'Zendaya' IN (
    SELECT Person.name
    FROM
      Movie_Actors
      INNER JOIN Person
        ON Movie_Actors.person_id = Person.id
    WHERE
      Movie_Actors.movie_id = Movie.id)
```

SQL (as it may be):

```sql
select
  title,
  actors.name,
  (select avg(score) from reviews
   where movie_id = movies.movie_id) as rating
from movies
  join movies_actors using(movie_id)
  join actors using(actor_id)
where movie_id in (
  select movie_id
  from actors join movies_actors using(actor_id)
  where actors.name = 'Zendaya'
)
```

[movies.sql](https://gist.github.com/nalgeon/f80845eab71153eed7d41b5306d6d785)

A bit verbose. But maybe SQL is not that complex after all? Otherwise, why would you paint it scarier than it really is?

## Modern

<figure>
    <img src="fancy-3.png" alt="Designed for devs, not suits">
    <figcaption>Let's throw in some suite-shaming!</figcaption>
</figure>

Here is another common argument:

> SQL was designed with 1970s businessmen in mind, and it shows.

True, SQL was designed in the 1970s. But how is that a weakness? Everyone knows SQL. All major database engines support SQL. SQL is expressive enough to solve any data-related task. SQL has a solid standards committee that maintains and improves it. What can your language offer besides being created in the 2020s?

I can go on, but I don't think it's necessary. My point is simple.

I don't need your fancy query language. I'd stick with SQL.

Maybe it's just me.
