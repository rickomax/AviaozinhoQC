# QuakeC Scripts – Aviãozinho do Tráfico 3

This repository contains the **QuakeC scripts** used in the game _"Aviãozinho do Tráfico 3"_.

## Features

- Custom game logic written in QuakeC.
- Includes support for **Steam achievements and stat tracking**.

## Available Functions

```c
void unlock_achievement(string name);
void update_stat(string name, int value);
```

This code supports unlocking achievements through trigger messages.  
To use it, simply set the message to `unlock_achievement("name")`, and the achievement will be triggered.
