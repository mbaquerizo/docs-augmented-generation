#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

# --- Terminal formatting ---

if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then
  BOLD="$(tput bold 2>/dev/null || true)"
  GREEN="$(tput setaf 2 2>/dev/null || true)"
  YELLOW="$(tput setaf 3 2>/dev/null || true)"
  BLUE="$(tput setaf 4 2>/dev/null || true)"
  RESET="$(tput sgr0 2>/dev/null || true)"
else
  BOLD=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

# --- Configuration defaults (overridable via environment) ---
: "${DAG_CONFIG_PATH:=.dag/config.json}"
: "${DAG_DOCS_DIR:=.dag/docs}"

CONFIG_FILE="$DAG_CONFIG_PATH"
DOCS_DIR="$DAG_DOCS_DIR"
ADAPTER_TYPE=""
adrPath=""
ticketPath=""
project=""

# --- State ---

BACKUP_FILE=""
COMMITTED=false

cleanup() {
  if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ] && [ "$COMMITTED" = false ]; then
    rm -f "$BACKUP_FILE"
  fi
}
trap cleanup EXIT

# --- Screen control ---

clear_screen() {
  printf "\033[2J\033[H"
}

screen_header() {
  local label="$1"
  clear_screen
  printf "${BOLD}${BLUE}  DAG init${RESET}  ${label}\n"
  printf "${BLUE}  ─────────────────────────────────────────────${RESET}\n\n"
}

# --- Utility ---

die() {
  printf "${BOLD}${YELLOW}Error${RESET}: %s\n" "$*" >&2
  exit 2
}

info() {
  printf "${GREEN}✓${RESET} %s\n" "$*"
}

warn() {
  printf "${YELLOW}!${RESET} %s\n" "$*" >&2
}

# --- Interactive menu ---
# Renders a cursor-selectable list. Arrow keys move the cursor,
# Enter selects. Falls back to numbered prompt for non-TTY stdin.

menu_select() {
  local prompt="$1"
  shift
  local options=("$@")
  local count="${#options[@]}"
  local selected=0
  local key extra i

  # Non-TTY fallback: prompt by number
  if [ ! -t 0 ]; then
    printf "\n${BOLD}%s${RESET}\n" "$prompt"
    i=0
    while [ "$i" -lt "$count" ]; do
      printf "  %d) %s\n" "$((i + 1))" "${options[$i]}"
      i=$((i + 1))
    done
    read -r key || true
    case "$key" in
      [0-9]*) selected=$((key - 1)) ;;
    esac
    if [ "$selected" -ge 0 ] && [ "$selected" -lt "$count" ]; then
      return "$selected"
    fi
    return 0
  fi

  draw_menu() {
    printf "\n${BOLD}%s${RESET}\n" "$prompt"
    i=0
    while [ "$i" -lt "$count" ]; do
      if [ "$i" -eq "$selected" ]; then
        printf "  ${BOLD}${GREEN}▸ %s${RESET}\n" "${options[$i]}"
      else
        printf "    %s\n" "${options[$i]}"
      fi
      i=$((i + 1))
    done
  }

  clear_menu() {
    i=0
    while [ "$i" -lt "$((count + 2))" ]; do
      printf "\033[A\033[K"
      i=$((i + 1))
    done
  }

  draw_menu

  while true; do
    read -s -n1 key || true
    case "$key" in
      $'\e')
        read -s -n2 extra 2>/dev/null || true
        case "$key$extra" in
          $'\e[A')
            [ "$selected" -gt 0 ] && selected=$((selected - 1))
            ;;
          $'\e[B')
            [ "$selected" -lt "$((count - 1))" ] && selected=$((selected + 1))
            ;;
        esac
        clear_menu
        draw_menu
        ;;
      '')
        printf "\n"
        return "$selected"
        ;;
    esac
  done
}

confirm() {
  local prompt="$1"
  if menu_select "$prompt" "Yes" "No"; then
    return 0
  fi
  return 1
}

# Cursor-select a default or type a custom value.
# Options: default value, "Type custom..." label.
# Selecting "Type custom..." falls through to a text prompt.
menu_select_or_type() {
  local prompt="$1"
  local default_val="$2"
  local result_var="$3"
  local custom_label="${4:-Type a path...}"
  if menu_select "$prompt" "$default_val" "$custom_label"; then
    printf -v "$result_var" "%s" "$default_val"
  else
    prompt_with_default "  Custom" "$default_val" "$result_var"
  fi
}

prompt_with_default() {
  local prompt="$1" default="$2" result_var="$3" answer
  printf "${BLUE}%s${RESET} [${BOLD}%s${RESET}]: " "$prompt" "$default"
  read -r answer || true
  if [ -z "$answer" ]; then
    answer="$default"
  fi
  printf -v "$result_var" "%s" "$answer"
}

# --- Functions ---

print_banner() {
  printf "${BOLD}${BLUE}"
  printf "  ╔══════════════════════════════════════════════╗\n"
  printf "  ║  ${BOLD}${GREEN}DAG init${RESET}${BOLD}${BLUE} ── Docs Augmented Generation  ║\n"
  printf "  ╚══════════════════════════════════════════════╝\n"
  printf "${RESET}\n"
  printf "Creates ${BOLD}.dag/config.json${RESET} and document directories\n"
  printf "for ADRs and tickets.\n\n"
  printf "Press ${BOLD}Ctrl+C${RESET} anytime to cancel — no files are\n"
  printf "modified until you confirm.\n\n"
  printf "${BLUE}────────────────────────────────────────────────${RESET}\n"
  printf "Press ${BOLD}Enter${RESET} to begin"
  read -r || true
}

check_existing_config() {
  if [ -f "$CONFIG_FILE" ]; then
    screen_header "Existing config"
    warn "${CONFIG_FILE} exists"
    if confirm "Overwrite? Backup saved to ${CONFIG_FILE}.bak"; then
      BACKUP_FILE="${CONFIG_FILE}.bak"
      cp "$CONFIG_FILE" "$BACKUP_FILE" || die "Failed to create backup"
      info "Backup saved to ${BACKUP_FILE}"
    else
      exit 1
    fi
  fi
}

screen_adapter() {
  screen_header "Adapter"
  printf "Choose a documentation adapter. Cloud adapters coming later.\n"
  menu_select "Adapter type" "local (writes to filesystem)"
  ADAPTER_TYPE="local"
}

screen_paths() {
  screen_header "Documentation storage"
  printf "ADRs and code explorations will be markdown files.\n\n"
  menu_select_or_type "Directory for ADRs and explorations" "./${DOCS_DIR}/adr" adrPath

  screen_header "Ticket storage"
  printf "Tickets will be numbered markdown files (e.g. ${BOLD}PROJ-1-title${RESET}).\n\n"
  menu_select_or_type "Directory for tickets" "./${DOCS_DIR}/tickets" ticketPath

  screen_header "Project prefix"
  printf "Prefix appears in filenames (e.g. ${BOLD}PROJ-1-add-auth${RESET}). Uppercased, max 10 chars.\n"
  prompt_project
}

prompt_project() {
  local raw sanitized
  while true; do
    menu_select_or_type "Prefix" "PROJ" raw "Type a custom prefix..."
    sanitized="$(sanitize_project "$raw")"
    if [ "${#raw}" -gt 10 ]; then
      printf "\n  ${YELLOW}Too long (%d chars). Try: %s${RESET}\n" "${#raw}" "$sanitized" >&2
    else
      project="$sanitized"
      return 0
    fi
  done
}

sanitize_project() {
  local raw="$1" cleaned
  cleaned="$(printf "%s" "$raw" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]_-')"
  printf "%s" "$cleaned" | cut -c1-10
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  printf "%s" "$s"
}

generate_config_json() {
  local escaped_adrPath escaped_ticketPath escaped_project
  escaped_adrPath="$(json_escape "$adrPath")"
  escaped_ticketPath="$(json_escape "$ticketPath")"
  escaped_project="$(json_escape "$project")"

  case "$ADAPTER_TYPE" in
    local)
      cat <<EOF
{
  "adapters": {
    "documentation": {
      "type": "local",
      "config": {
        "adrPath": "${escaped_adrPath}"
      }
    },
    "issue-tracking": {
      "type": "local",
      "config": {
        "project": "${escaped_project}",
        "ticketPath": "${escaped_ticketPath}"
      }
    }
  }
}
EOF
      ;;
    *)
      die "Unknown adapter type: $ADAPTER_TYPE"
      ;;
  esac
}

preview_config() {
  local json
  json="$(generate_config_json)"
  screen_header "Review"
  printf "%s\n" "$json"
  printf "\n"
  if confirm "Looks good? Write ${CONFIG_FILE} and create the directories"; then
    return 0
  else
    exit 1
  fi
}

write_config() {
  local tmpfile dir
  dir="$(dirname "$CONFIG_FILE")"
  mkdir -p "$dir" || die "Failed to create directory: $dir"
  tmpfile="$(mktemp -t dag-init.XXXX)" || die "Failed to create temp file"
  generate_config_json > "$tmpfile"
  mv "$tmpfile" "$CONFIG_FILE" || die "Failed to write config"
  COMMITTED=true
}

post_write() {
  case "$ADAPTER_TYPE" in
    local)
      mkdir -p "$adrPath" "$ticketPath"
      touch "$adrPath/.gitkeep" "$ticketPath/.gitkeep"
      ;;
  esac
}

print_summary() {
  screen_header "Done"
  info "Configuration → ${BOLD}${CONFIG_FILE}${RESET}"
  info "ADRs          → ${BOLD}${adrPath}${RESET}"
  info "Tickets       → ${BOLD}${ticketPath}${RESET}"
  printf "\n${BOLD}Next step${RESET}:\n"
  printf "  ${BOLD}/dag:plan-feature <your feature description>${RESET}\n"
}

# --- Main ---

main() {
  print_banner
  check_existing_config
  screen_adapter
  screen_paths
  preview_config
  write_config
  post_write
  print_summary
  exit 0
}

main
