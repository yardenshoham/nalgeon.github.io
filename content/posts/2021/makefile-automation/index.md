+++
date = 2021-03-16T17:15:00Z
title = "Automate your Python project with Makefile"
description = "Makefile is not just some relict from the 70s."
image = "/makefile-automation/cover.png"
slug = "makefile-automation"
tags = ["python"]
+++

When working on a library or application, certain tasks tend to show up over and over again:

-   checking the code with linters,
-   running tests with coverage,
-   deploying with Docker,
-   ...

JS developers are lucky (ha!): their `package.json` has a special `scripts` section for this stuff:

```
{
    ...
    "scripts": {
        "format": "prettier --write \"src/**/*.ts\"",
        "lint": "tslint -p tsconfig.json",
        "test": "jest --coverage --config jestconfig.json",
    },
    ...
}
```

Nothing like this is provided with Python. You can, of course, make a `.sh` script for each task. But it litters the project directory, and it's better to keep all such tasks together. Installing a separate task runner or using the one built into IDE also seems weird.

Good news: Linux and macOS already have a great task automation tool for any project - `Makefile`.

## Makefile for task automation

Perhaps you, like me, thought that Makefile is a relict from the 70s, useful for compiling `C` programs. True. But it is also perfectly suitable for automating any tasks in general.

Here's what it might look like in a python project. Create a file named `Makefile`:

```
coverage:  ## Run tests with coverage
	coverage erase
	coverage run --include=podsearch/* -m pytest -ra
	coverage report -m

deps:  ## Install dependencies
	pip install black coverage flake8 mypy pylint pytest tox

lint:  ## Lint and static-check
	flake8 podsearch
	pylint podsearch
	mypy podsearch

push:  ## Push code with tags
	git push && git push --tags

test:  ## Run tests
	pytest -ra
```

And run linter with tests, for example:

```
$ make lint coverage

flake8 podsearch
pylint podsearch
...
mypy podsearch
...
coverage erase
coverage run —include=podsearch/* -m pytest -ra
...
coverage report -m
Name                    Stmts   Miss  Cover   Missing
-----------------------------------------------------
podsearch/__init__.py       2      0   100%
podsearch/http.py          17      0   100%
podsearch/searcher.py      51      0   100%
-----------------------------------------------------
TOTAL                      70      0   100%
```

## Features

### Task steps

A task can include multiple steps, like `lint` in the example above:

```
lint:
	flake8 podsearch
	pylint podsearch
	mypy podsearch
```

Each step is executed in a separate subprocess. To run a chain of actions (for example, `cd` and `git pull`) combine them through `&&`:

```
push:
	git push && git push --tags
```

### Task dependencies

Consider the `test` task, which should first perform linting, and then run the tests. Specify `lint` as a dependency for `test`, and you're done:

```
test: lint
	pytest -ra
```

You can specify multiple space-separated dependencies. Or tasks can explicitly call each other:

```
lint:
	flake8 podsearch
	pylint podsearch
	mypy podsearch

test:
	pytest -ra

prepare:
	make lint
	make test
```

### Task parameters

Consider the `serve` task which serves a static site, with IP and port specified as parameters. No problem:

```
serve:
	python -m http.server dist --bind $(bind) $(port)
```

Run task with parameters:

```bash
$ make serve bind=localhost port=3000
```

You can specify default parameter values:

```
bind ?= localhost
port ?= 3000
serve:
	python -m http.server dist --bind $(bind) $(port)
```

Now they are optional when running `make`:

```bash
$ make serve bind=192.168.0.1
$ make serve port=8000
$ make serve
```

### And so much more

If basic features are not enough, there are some great in-depth guides:

-   [Learn Makefiles with the tastiest examples](https://makefiletutorial.com)
-   [Automation and Make](https://swcarpentry.github.io/make-novice/reference.html)

## In the wild

Here is a Makefile from one of my projects (podcast search tool):

-   [podsearch](https://github.com/nalgeon/podsearch-py/blob/master/Makefile)

Makefiles are great for automating routine tasks, regardless of the language you prefer. Use them!
