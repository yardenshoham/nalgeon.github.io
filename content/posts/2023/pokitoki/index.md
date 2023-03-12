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
    <img src="./chat-1.png" alt="Sample chat" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

This is how it can be useful to you (in my deeply subjective view):

-   Learn how to write basic Telegram bots in Python.
-   Learn how to integrate with OpenAI.
-   Learn how to run Python applications in Docker.

And of course, you can connect it to your Telegram (if you manage to sign up with OpenAI).

I've intentionally kept the bot as simple as possible so you can quickly understand the code.

## Personal chats

The bot acts as your personal assistant in a personal chat. To allow other users to use the bot, list them in the `telegram_usernames` config property.

The bot has a terrible memory, so don't expect it to remember any chat context by default. But you can ask follow-up questions using a plus sign:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-2.png" alt="Question" width="400" class="img-bordered-thin">
    <figcaption>the question...<figcaption>
</figure>
</div>
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-3.png" alt="Follow-up question" width="400" class="img-bordered-thin">
    <figcaption>and the follow-up<figcaption>
</figure>
</div>
</div>

Available commands:

-   `/retry` - retry answering the last question
-   `/help` - show help

## Groups

To get an answer from the bot in a group, mention it in a reply to a question, or ask a question directly:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-4.png" alt="Reply with mention" width="400" class="img-bordered-thin">
    <figcaption>reply with mention<figcaption>
</figure>
</div>
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-5.png" alt="Direct question" width="400" class="img-bordered-thin">
    <figcaption>direct question<figcaption>
</figure>
</div>
</div>

The bot will ignore questions from group members unless they are listed in the `telegram_usernames` config property.

## Setup

1. Get your [OpenAI API](https://openai.com/api/) key
2. Get your Telegram bot token from [@BotFather](https://t.me/BotFather)
3. Copy `config.example.yml` to `config.yml` and specify your tokens there.
4. Start the bot:

```bash
docker compose up --build
```

[Source code on GitHub](https://github.com/nalgeon/pokitoki)
