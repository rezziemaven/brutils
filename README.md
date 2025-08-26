# 🧰 brutils - Bedrock Utility CLI

A CLI to to help simplify and streamline development across multiple Bedrock configurations. Easily start and stop configurations, manage composer repositories and view local changes faster using separate main and local `composer.json` files, and perform other repetitive dev tasks, all with a few simple commands.

---

🚧 This project is not accepting external contributions (for now) as it is still under active development. Please hold off on submitting pull requests - I will update this message when I'm ready for community input. Thank you for your interest!

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Project Configuration](#project-configuration)
- [Usage](#usage)
- [Available Commands](#available-commands)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](/LICENSE)

---

## Features

- Manage your repositories, both local and remote, using separate `composer.json` and `composer.local.json` files
- Add local plugin and theme repositories to your `composer.local.json` file to preview local changes faster and boost development workflows
- Check that the local plugin and theme paths were set correctly in your `.env` file
- Use a `.brutilsrc` file to track the active `composer.json` file in each config to easily know which changes you're viewing locally, as well as the configuration name and default vendor name for in-house themes and plugins (optional)
- Automate other common Docker + Composer workflows like starting, stopping and
rebuilding containers, or updating Composer dependencies

## Requirements

- `jq` (this is necessary to modify the composer.local.json when adding local repositories)
  - Install: use the `brutils init` to configure your project to use `brutils`. This copies the `Dockerfile.composer` file to your configuration, which is then used in the `docker-compose.override.yml` file as seen in [Project Configuration](#project-configuration) below.
- The name of the configuration should have `bedrock` in the `docker-compose.yml` file for certain commands (eg. `start`, `stop`) to work as expected. You can override the container names to each service to the `docker-compose.override.yml` file using `container_name`, if necessary, eg.

```yml
# docker-compose.override.yml

php
  container_name: my-site-bedrock-php
  # ...
```

## Installation

1. Clone this repository to your preferred directory
2. Ensure that `brutils` has the correct permissions to be executable:

  ```bash
  chmod +x brutils
  ```

3. Set up a symlink to add it to the location of your other CLIs, eg.

```bash
ln -s /path/to/brutils /usr/local/bin/brutils
```

**NOTE:** If you're already using a CLI named `brutils`, you can symlink it under another name (eg. `br-utils`) to avoid conflicts. In case this command doesn't work due to permissions, you can use `sudo ln -s` instead.
4. Please see [Project Configuration](#project-configuration) to configure each Bedrock configuration to work seamlessly with this tool.

## Project Configuration

- Run `brutils init` to begin the project configuration. It will prompt you for the configuration name or use the default one shown, and you can set an optional vendor name if working with in-house plugins or themes locally. These are all stored in a `.brutilsrc` configuration file saved in each project root. This command also adds the following files:
  - `.env.local`: A copy of your `.env` file with two additional variables, `PLUGINS_PATH` and `THEMES_PATH`. If this file already exists, it will just add these variables to it. These variables let you take advantage of symlinking and improved development workflow for your plugins and themes. If for some reason these aren't set, you can use the command `brutils add-paths` to add the variables to the `.env` file. After that, you need add the local paths where your plugins and themes are stored respectively.
  - `Dockerfile.composer`: A modified composer build adding `jq` to the service.
  - `docker-compose.override.yml`: An overriding config that merges with the `docker-compose.yml` file when the `docker compose` command is used. If this file already exists, it won't create a new one, but you will have to add the additional config lines manually. You can reference the `templates/docker-compose.override.yml` file to complete the configuration correctly.
- The `.brutilsrc` file also tracks the current composer file (`composer.json` or `composer.local.json`). This allows you to switch safely between configs in multiple terminals or windows.

- After you run `brutils init`, you then need to update your `.gitignore` so it doesn't track the following files:

```bash

# Docker
# ...
docker-compose.override.yml
Dockerfile.composer

# Composer
# ...
composer.local.*

# Bedrock Utility CLI Variables
.brutilsrc
```

## Usage

```bash
brutils <command> [options]
```

Most of the commands will only work in a Bedrock configuration from the project root folder.

## Available commands

- `start`: Stop all other running Bedrock configs and start the current one
- `stop`: Stop the current Bedrock config
- `rebuild [--full]`: Rebuild the current Bedrock config via `docker compose`. The optional `--full` flag removes all containers and volumes and rebuilds from scratch.
- `cleanup`: Remove orphaned Composer containers
- `install-local`: Run `composer install` on `composer.local.json`. Adds a `composer.local.json` if not already created
- `use-local|update-local`: Switch to `composer.local.json` and update deps
- `add-local-repo <plugin|theme> <repo-name> [<vendor>]`: Adds local theme or plugin repository to `composer.local.json`
- `update|update-main|use-main <vendor/package>`: Switches to `composer.json`. Updates all dependencies if no argument is supplied, or a single dependency if the correct format is supplied.
- `add-paths`: Add `PLUGINS_PATH` and `THEMES_PATH` variables to `.env`
- `check-paths`: Verify plugin/theme paths are set in `.env` and point to your local paths
- `which`: Verify which `composer.json` file is being used
- `help|-h|--help`: Show help menu
- `-v|--version`: Display plugin version

## Troubleshooting

- **PLUGINS_PATH and THEMES_PATH variables not set?**
Make sure you have the `.env.local` file with the paths correctly set, and if you already had a `docker-compose.override.yml` file, that it mounts the volumes to `PLUGINS_PATH` and `THEMES_PATH` for `nginx`, `php` and `composer` respectively. You can reference the `templates/docker-compose.override.yml` file to set them properly.
- **COMPOSER env variable not set?**
Make sure `.brutilsrc` exists and has the correct value (eg. `COMPOSER=composer.local.json`)
- **Local repository not found?**
Double-check your plugin/ theme name and path. `brutils` assumes local repos are in the path `/opt/plugins/name-of-plugin` or `/opt/themes/name-of-theme`.

## Contributing

This CLI is currently under active development and currently not ready to accept external contributions just yet. Please feel free to explore or use the code, but hold off on submitting issues or pull requests at this time. Thanks for understanding!