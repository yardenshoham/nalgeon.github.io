+++
date = 2023-03-11T12:30:00Z
title = "ChatGPT Bot in Python"
description = "A Telegram chatbot that works via the official OpenAI API."
image = "/pokitoki/cover.png"
slug = "pokitoki"
tags = ["python"]
featured = true
+++

In the last few months, people have been releasing a record number of AI-powered software. Of course I could not stay out of it.

And so the [**pokitoki**](https://github.com/nalgeon/pokitoki) project was born. It's a a Telegram chat bot built using the ChatGPT (GPT-3.5 or GPT-4) language model from OpenAI.

Notable features:

-   Both one-on-one and group chats.
-   Direct questions, mentions, follow-ups.
-   Access external links (articles, code, data).
-   Shortcuts (custom AI commands).

## Personal chats

The bot acts as your personal assistant:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-1.png" alt="Sample chat" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

To allow other users to use the bot, list them in the `telegram_usernames` config property.

The bot has a terrible memory, so don't expect it to remember any chat context by default. You can, however, reply with a follow-up question (`Ctrl/Cmd + ↑`). Alternatively, use a plus sign to follow up:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-2.png" alt="Follow-up by reply" width="400" class="img-bordered-thin">
    <figcaption>follow up by replying<figcaption>
</figure>
</div>
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-3.png" alt="Follow-up by plus sign" width="400" class="img-bordered-thin">
    <figcaption>or by writing a `+` sign<figcaption>
</figure>
</div>
</div>

Available commands:

-   `/retry` - retry answering the last question
-   `/help` - show help
-   `/version` - show bot info

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

To make the bot reply to group members, list the group id in the `telegram_chat_ids` config property. Otherwise, the bot will ignore questions from group members unless they are listed in the `telegram_usernames` config property.

If you don't know the group id, run the `/version` bot command in a group to find it:

```
Chat information:
- id: -1001405001234
- title: My Favorite Group
- type: supergroup
...
```

## External links

If you ask "vanilla" ChatGPT about external resources, it will either hallucinate or admit that it doesn't have access to remote content:

> Q: What is the content of https://sqlime.org/employees.sql? Make no assumptions.
>
> A: As an AI language model, I cannot access external URLs on the internet.

The bot solves the problem by fetching the remote content and feeding it to the model:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-7.png" alt="External links" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

Currently only supports text content (articles, code, data), not PDFs, images or audio.

## Shortcuts

Use short commands to save time and ask the bot to do something specific with your questions. For example, ask it to proofread your writing with a `!proofread` command:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-6.png" alt="Shortcuts" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

There are several built-in shortcuts:

-   `bugfix` fixes your code.
-   `proofread` fixes your writing.
-   `translate` translates your text into English.
-   `summarize` gives a two paragraph summary of a text.

You can add your own shortcuts. See `config.example.yml` for details.

## Other useful features

The convenience of working with a bot is made up of small details. Here are some situations where it can save you time and effort.

### Forwarding

Say you received a message from a colleague or read a post on a channel and want to ask a question. Simply forward the message to the bot and answer the clarifying question it asks:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-8.png" alt="Forwarding 1" width="400" class="img-bordered-thin">
    <figcaption>forward the message<figcaption>
</figure>
</div>
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-9.png" alt="Forwarding 2" width="400" class="img-bordered-thin">
    <figcaption>and specify the task<figcaption>
</figure>
</div>
</div>

### Reply with attachment

Sometimes the AI's reply exceeds the maximum message length set by Telegram. In this case, the bot will not fail or spam you with messages. Instead, it will send the answer as an attached markdown file:

<div class="row">
<div class="col-xs-12 col-sm-6">
<figure>
    <img src="./chat-10.png" alt="Reply with attachment" width="400" class="img-bordered-thin">
</figure>
</div>
</div>

### Editing questions

To rephrase or add to the last question, edit it (`↑` shortcut). The bot will notice this and respond to the clarified question.

## Bot information

Use the `/version` commands to print detailed information about the current chat, bot, and AI model:

```
Chat information:
- id: -1001405001234
- title: My Favorite Group
- type: supergroup

Bot information:
- id: 5930739038
- name: @pokitokibot
- version: 70
- usernames: 6 users
- chat IDs: []
- access to messages: True

AI information:
- model: gpt-3.5-turbo
- history depth: 3
- shortcuts: ['bugfix', 'proofread', 'summarize', 'translate']
```

## Setup

1. Get your [OpenAI API](https://openai.com/api/) key
2. Get your Telegram bot token from [@BotFather](https://t.me/BotFather)
3. Copy `config.example.yml` to `config.yml` and specify your tokens there.
4. Start the bot:

```bash
docker compose up --build --detach
```

To stop the bot:

```bash
docker compose stop
```

For older Docker distributions, use `docker-compose` instead of `docker compose`.

[Source code on GitHub](https://github.com/nalgeon/pokitoki)
