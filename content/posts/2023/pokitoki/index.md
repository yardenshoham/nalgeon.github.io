+++
date = 2023-03-11T12:30:00Z
title = "ChatGPT Bot in Python"
description = "A Telegram chatbot that works via the official OpenAI API."
image = "/pokitoki/cover.png"
slug = "pokitoki"
tags = ["python"]
+++

In the last few months, people have been releasing a record number of OpenAI-powered software. Of course I could not stay out of it.

And so the [**pokitoki**](https://github.com/nalgeon/pokitoki) project was born. It's a Telegram chatbot that works via the official OpenAI API.

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-1.png" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

This is how it can be useful to you (in my deeply subjective view):

-   Learn how to write basic Telegram bots in Python.
-   Learn how to integrate with OpenAI.
-   Learn how to run Python applications in Docker.

I've intentionally kept the bot as simple as possible so you can quickly understand the code.

And of course, you can connect it to your Telegram (if you manage to sign up with OpenAI).

The bot has a terrible memory, so don't expect it to remember any chat context by default. But you can ask follow-up questions using a plus sign:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-2.png" width="400" class="img-bordered-thin">
    <figcaption>the question...<figcaption>
</figure>
</div>
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-3.png" width="400" class="img-bordered-thin">
    <figcaption>and the follow-up<figcaption>
</figure>
</div>
</div>

Available commands:

-   `/retry` - retry answering the last question
-   `/help` - show help

## Setup

1. Get your [OpenAI API](https://openai.com/api/) key
2. Get your Telegram bot token from [@BotFather](https://t.me/BotFather)
3. Copy `config.example.yml` to `config.yml` and specify your tokens there.
4. Start the bot:

```bash
docker compose up --build
```

[Source code on GitHub](https://github.com/nalgeon/pokitoki)
