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
docsDestination=""
ticketDestination=""
project=""
daggerDestination=""
daggerProject=""

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
  printf "Choose an adapter for documentation and issue-tracking.\n"
  printf "Both sections share the same adapter.\n\n"
  menu_select "Adapter type" "local (writes to filesystem)" "dagger (Dagger service via HTTP/MCP)"
  local choice=$?
  case $choice in
    0) ADAPTER_TYPE="local" ;;
    1) ADAPTER_TYPE="dagger" ;;
    *) die "Invalid adapter selection" ;;
  esac
}

screen_paths() {
  case "$ADAPTER_TYPE" in
    local)
      screen_header "Documentation storage"
      printf "ADRs, explorations, and pitches will be markdown files under one directory.\n\n"
      menu_select_or_type "Directory for docs" "./${DOCS_DIR}" docsDestination

      screen_header "Ticket storage"
      printf "Tickets will be numbered markdown files (e.g. ${BOLD}PROJ-1-title${RESET}).\n\n"
      menu_select_or_type "Directory for tickets" "./${DOCS_DIR}/tickets" ticketDestination

      screen_header "Project prefix"
      printf "Prefix appears in filenames (e.g. ${BOLD}PROJ-1-add-auth${RESET}). Uppercased, max 10 chars.\n"
      prompt_project
      ;;
    dagger)
      screen_header "Dagger destination"
      printf "Base URL of the Dagger API (e.g. https://api.dagger-ai.com).\n\n"
      menu_select_or_type "Destination" "https://api.dagger-ai.com" daggerDestination

      screen_header "Dagger project"
      printf "Numeric project ID (e.g. 1). Slug resolution not yet supported.\n\n"
      prompt_dagger_project
      ;;
  esac
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

prompt_dagger_project() {
  local raw
  while true; do
    prompt_with_default "Project ID" "" raw
    if [ -z "$raw" ]; then
      printf "\n  ${YELLOW}Project ID is required${RESET}\n" >&2
      continue
    fi
    # Validate numeric only for now
    case "$raw" in
      ''|*[!0-9]*)
        printf "\n  ${YELLOW}Project ID must be numeric (e.g. 1). Slug resolution not yet supported.${RESET}\n" >&2
        ;;
      *)
        daggerProject="$raw"
        return 0
        ;;
    esac
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

validate_dagger() {
  screen_header "Validating API key"
  
  # Check DAGGER_API_KEY is set
  if [ -z "${DAGGER_API_KEY:-}" ]; then
    die "DAGGER_API_KEY environment variable not set. Export it before running dag-init."
  fi

  # Validate connectivity and key with 5s timeout
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 \
    -H "Authorization: Bearer ${DAGGER_API_KEY}" \
    "${daggerDestination}/api/v1/issues?status=open" 2>/dev/null) || http_code=000

  case "$http_code" in
    200)
      info "API key valid (200 OK)"
      warn "Caveat: project access not verified — first publish will 403 if key is scoped to a different project"
      ;;
    401)
      die "Invalid or expired API key (401 Unauthorized)"
      ;;
    000)
      die "Cannot reach ${daggerDestination} — check URL and network (timeout or TLS error)"
      ;;
    404)
      die "Endpoint not found (404) — verify destination URL: ${daggerDestination}"
      ;;
    *)
      die "Unexpected response (HTTP ${http_code}) from ${daggerDestination}/api/v1/issues"
      ;;
  esac
}

generate_config_json() {
  local escaped_docsDestination escaped_ticketDestination escaped_project
  local escaped_daggerDestination escaped_daggerProject
  escaped_docsDestination="$(json_escape "$docsDestination")"
  escaped_ticketDestination="$(json_escape "$ticketDestination")"
  escaped_project="$(json_escape "$project")"
  escaped_daggerDestination="$(json_escape "$daggerDestination")"
  escaped_daggerProject="$(json_escape "$daggerProject")"

  case "$ADAPTER_TYPE" in
    local)
      cat <<EOF
{
  "adapters": {
    "documentation": {
      "type": "local",
      "config": {
        "destination": "${escaped_docsDestination}"
      }
    },
    "issue-tracking": {
      "type": "local",
      "config": {
        "project": "${escaped_project}",
        "destination": "${escaped_ticketDestination}"
      }
    }
  }
}
EOF
      ;;
    dagger)
      cat <<EOF
{
  "adapters": {
    "documentation": {
      "type": "dagger",
      "config": {
        "destination": "${escaped_daggerDestination}",
        "project": ${escaped_daggerProject}
      }
    },
    "issue-tracking": {
      "type": "dagger",
      "config": {
        "destination": "${escaped_daggerDestination}",
        "project": ${escaped_daggerProject}
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
      mkdir -p "$docsDestination/adr" "$docsDestination/pitches" "$ticketDestination"
      touch "$docsDestination/adr/.gitkeep" "$docsDestination/pitches/.gitkeep" "$ticketDestination/.gitkeep"
      ;;
    dagger)
      # No filesystem directories to create
      ;;
  esac
}

print_summary() {
  screen_header "Done"
  info "Configuration → ${BOLD}${CONFIG_FILE}${RESET}"
  case "$ADAPTER_TYPE" in
    local)
      info "Docs          → ${BOLD}${docsDestination}${RESET}"
      info "Tickets       → ${BOLD}${ticketDestination}${RESET}"
      ;;
    dagger)
      info "Destination   → ${BOLD}${daggerDestination}${RESET}"
      info "Project ID    → ${BOLD}${daggerProject}${RESET}"
      printf "\n${BOLD}Next steps${RESET}:\n"
      printf "  1. ${BOLD}export DAGGER_API_KEY=your-key${RESET} (add to shell profile)\n"
      printf "  2. Configure MCP in your client (see docs-augmented-generation docs)\n"
      ;;
  esac
  printf "\n  ${BOLD}/dag:plan-feature <your feature description>${RESET}\n"
}

# --- Main ---

main() {
  print_banner
  check_existing_config
  screen_adapter
  screen_paths
  
  # Dagger-specific validation before preview
  if [ "$ADAPTER_TYPE" = "dagger" ]; then
    validate_dagger
  fi
  
  preview_config
  write_config
  post_write
  print_summary
  exit 0
}

main