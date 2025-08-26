# lib/utils.sh
# readonly SELF_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# source "$SELF_DIR/styles.sh"

set -e

check_if_bedrock_config() {
  if docker compose config 2>/dev/null | grep -q 'bedrock'; then
    echo -e "${GREEN_BG}✅ Bedrock configuration detected.${ENDSTYLE}"
  else
    echo -e "${YELLOW_BG}❌ Not a Bedrock configuration. Exiting.${ENDSTYLE}"
    exit 1
  fi
}

check_if_init() {
  if (( is_initialized )); then
    return 0
  else
    echo -e "${BOLD}${RED}fatal:${ENDSTYLE} could not find config; run ${BOLD}brutils init${ENDSTYLE} to initialize."
    echo "missing: .brutilsrc"
    exit 1
  fi
}

get_config_name() {
  source .brutilsrc
  if [[ -n "${CONFIG_NAME}" ]]; then
    echo "$CONFIG_NAME"
  else
    if docker compose config >/dev/null 2>&1; then
      result=$(docker compose config 2>/dev/null | grep -m 1 'bedrock')
      name=${result#*: }
      update_var_in_brutilsrc CONFIG_NAME "$name"
      echo "$name"
    fi
  fi
}

update_var_in_brutilsrc() {
  VAR_NAME=$1
  VAR_VALUE=$2

  if grep -q "^$VAR_NAME=" .brutilsrc; then
    sed -i '' "s|^$VAR_NAME=.*|$VAR_NAME=$VAR_VALUE|" .brutilsrc
  else
    echo "$VAR_NAME=$VAR_VALUE" >> .brutilsrc
  fi
}

add_path_variables() {
  add_local_env
  if cat "$LOCAL_ENV" | grep -qE 'THEMES_PATH|PLUGINS_PATH'; then
    echo -e "${YELLOW_BG}❌ Variables already added to .env.local. Exiting.${ENDSTYLE}"
    return 1
  fi
  echo -e "${BOLD}⚙️ Adding path variables to .env.local ...${ENDSTYLE}"
  echo -e "


# PHP and Composer Environment Variables
# These values are used to load the local paths to your theme and plugin folders
THEMES_PATH=your-local-themes-path
PLUGINS_PATH=your-local-plugins-path
  " >> .env.local
  echo "✅ Done!"
}

get_package_name() {
  if ! command -v jq &> /dev/null; then
  echo "${YELLOW_BG}❌ Error: 'jq' is required but not installed. Please install it using 'brew install jq' (macOS) or 'sudo apt install jq' (Linux).${ENDSTYLE}"
  exit 1
  fi

  echo "$(jq -r '.name' "$REPO_PATH/composer.json")"
}

copy_composer_dockerfile() {
  echo "Adding Dockerfile.composer ..."
  cp $BRUTILS_DIR/templates/Dockerfile.composer .
  echo "✅ Added Dockerfile.composer."
}

add_docker_config_override() {
  if ! [ -f "docker-compose.override.yml" ]; then
    echo "Adding Docker config override ..."
    cp $BRUTILS_DIR/templates/docker-compose.override.yml .
    echo "✅ Added docker-compose.override.yml."
  else
    echo "Docker override already exists. Follow the steps below to complete configuration."
    echo "$(cat $BRUTILS_DIR/templates/docker-compose.override.yml)"
  fi
}

add_local_env() {
  if [ -f ".env" ] && ! [ -f ".env.local" ]; then
    echo "Creating .env.local from .env ..."
    cp .env .env.local
    echo "✅ .env.local created."
  fi
}

add_local_composer() {
  if ! [ -f "composer.local.json" ]; then
    echo "Creating composer.local.json from composer.json ..."
    cp composer.json composer.local.json
    echo "✅ composer.local.json created."
  fi
}

show_help_commands() {
  echo -e "${BOLD}Available commands:${ENDSTYLE}"
  echo -e "  ${GREEN}start            Stop all other running Bedrock configs and "
  echo    "                   start the current one"
  echo    "  stop             Stop the current Bedrock config"
  echo    "  rebuild [--full] Rebuild the current Bedrock config via docker compose. "
  echo    "                   The --full flag removes all containers and volumes and "
  echo    "                   rebuilds from scratch."
  echo    "  cleanup          Remove orphaned Composer containers"
  echo    "  install-local    Run composer install on composer.local.json"
  echo    "  use-local|update-local"
  echo    "                   Switch to composer.local.json and update deps."
  echo    "  add-local-repo <plugin|theme> <repo-name> [<vendor>]"
  echo    "                   Adds local theme or plugin repository to "
  echo    "                   composer.local.json"
  echo    "  update|update-main|use-main <vendor/package>"
  echo    "                   Switches to composer.json. Updates all dependencies "
  echo    "                   if no argument is supplied, or a single dependency "
  echo    "                   if the correct format is supplied."
  echo    "  add-paths        Add PLUGINS_PATH and THEMES_PATH variables to .env"
  echo    "  check-paths      Verify plugin/theme paths are set in .env and "
  echo    "                   point to your local paths"
  echo    "  which"
  echo    "                   Verify which composer.json file is being used"
  echo    "  help|-h|--help"
  echo    "                   Show help menu"
  echo -e "  -v|--version     Display plugin version${ENDSTYLE}"
  echo    ""
  echo -e "${BOLD}💡 Pro tip: brutils commands should be run from the project root!${ENDSTYLE}"
}

show_last_init_steps() {
  echo "✅ Done!"
  echo ""
  echo -e "${BOLD}Here's the next steps:${ENDSTYLE}"
  echo -e "1. Add the local paths to your plugins and themes in your ${CYAN}.env.local${ENDSTYLE} file"
  echo -e "2. If you already had a docker-compose.override.yml file, add the following:"
  echo -e "

      nginx:
        volumes:
          ${GRAY}#...${ENDSTYLE}
          ${GREEN}- \${THEMES_PATH}:/opt/themes
          - \${PLUGINS_PATH}:/opt/plugins${ENDSTYLE}


      php:
        volumes:
          ${GRAY}#...${ENDSTYLE}
          ${GREEN}- \${THEMES_PATH}:/opt/themes
          - \${PLUGINS_PATH}:/opt/plugins${ENDSTYLE}

      composer:
        ${GREEN}build:
          context: .
          dockerfile: Dockerfile.composer${ENDSTYLE}
        volumes:
          ${GRAY}#...${ENDSTYLE}
          ${GREEN}- \${THEMES_PATH}:/opt/themes
          - \${PLUGINS_PATH}:/opt/plugins${ENDSTYLE}
        "
  echo -e "3. Add the following to your .gitignore file:"
  echo -e "
          # Docker
          ${GRAY}# ...${ENDSTYLE}
          ${GREEN}docker-compose.override.yml
          Dockerfile.composer${ENDSTYLE}

          # Composer
          ${GRAY}# ...${ENDSTYLE}
          ${GREEN}composer.local.*

          # Bedrock Utility CLI Config
          .brutilsrc${ENDSTYLE}
      "

}