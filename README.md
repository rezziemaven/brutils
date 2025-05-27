# 🧰 brutils - Bedrock Utility CLI
A CLI to to help simplify and streamline development across multiple 350.org Bedrock configurations. Easily start and stop configurations, manage composer repositories and view local changes faster using separate main and local `composer.json` files, and perform other repetitive dev tasks, all with a few simple commands.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Project Configuration](#project-configuration)
- [Usage](#usage)
- [Available Commands](#available-commands)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Features

- Manage your repositories, both local and remote, using separate `composer.json` and `composer.local.json` files
- Add local plugin and theme repositories to your `composer.local.json` file to preview local changes faster and boost development workflows
- Check that the local plugin and theme paths were set correctly in your `.env` file
- Track the active `composer.json` file in each config to easily know which changes you're viewing locally
- Automate other common Docker + Composer workflows like starting, stopping and
rebuilding containers, or updating Composer dependencies

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
- `brutils` creates and tracks the current composer file (`composer.json` or `composer.local.json`) via a `.brutils_env` file saved in each project root. This allows you to switch safely between configs in multiple terminals or windows.
- Add the variables `PLUGINS_PATH` and `THEMES_PATH` to the `.env` file of the configuration to take advantage of symlinking and improved development workflow for your plugins and themes.
Both of these variables then need to be added to your `docker-compose.yml` files as follows:
```yml
php:
  #...
  volumes:
    #...
    - ${THEMES_PATH}:/opt/themes
    - ${PLUGINS_PATH}:/opt/plugins
    env_file:
      - .env

composer:
  #...
  volumes:
    #...
    - ${THEMES_PATH}:/opt/themes
    - ${PLUGINS_PATH}:/opt/plugins
    env_file:
      - .env
```
- Add the following to your `.gitignore` file so they are not accidentally committed:
```bash
# Composer
# ...
composer.local.json
composer.local.lock

# Bedrock Utility CLI Variables
.brutils_env
```

## Usage
```bash
brutils <command> [options]
```
Most of the commands will only work in a Bedrock configuration from the project root folder.

## Available commands
- `start`: Stop all other running Bedrock configs and start the current one
- `stop`: Stop the current Bedrock config
- `rebuild`: Rebuild the current config via `docker compose`
- `cleanup`: Remove orphaned Composer containers
- `install-local`: Run composer install on `composer.local.json`. Adds a `composer.local.json` if not already created
- `use-local|update-local`: Switch to `composer.local.json` and update deps
- `add-local-repo <plugin|theme> <repo-name>`: Adds local theme or plugin repository to `composer.local.json`
- `update|update-main|use-main <vendor/package>`: Switches to `composer.json`. Updates all dependencies if no argument is supplied, or a single dependency if the correct format is supplied.
- `add-paths`: Add PLUGINS_PATH and THEMES_PATH variables to `.env`
- `check-paths`: Verify plugin/theme paths are set in `.env` and point to your local paths
- `which-composer`: Verify which `composer.json` file is being used
- `help|-h|--help`: Show help menu
- `-v|--version`: Display plugin version

## Troubleshooting
- **COMPOSER env variable not set?**
Make sure `.brutils_env` exists and has the correct value (eg. `COMPOSER=composer.local.json`)
- **Local repository not found?**
Double-check your plugin/ theme name and path. `brutils` assumes local repos are in the path `/opt/plugins/name-of-plugin` or `/opt/themes/name-of-theme`.

## Contributing
This CLI was built for internal 350 use, but PRs are welcome if this ever becomes public. Feel free to fork and adapt!