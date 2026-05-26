#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

MIGRATE_VERSION="1"
DB_PATH=".dag/dag.db"
SCHEMA_PATH="plugins/dag/scripts/schema.sql"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--db <path>] [--schema <path>]

Apply database schema migrations for the DAG DB adapter.

Options:
  --db <path>       Path to the SQLite database file (default: .dag/dag.db)
  --schema <path>   Path to the schema SQL file (default: plugins/dag/scripts/schema.sql)
  --help            Show this help message
EOF
  exit 0
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --db) DB_PATH="$2"; shift 2 ;;
    --schema) SCHEMA_PATH="$2"; shift 2 ;;
    --help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
done

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "Error: sqlite3 is not installed." >&2
  echo "Install it with your package manager (e.g. apt install sqlite3, brew install sqlite3)." >&2
  exit 2
fi

if [ ! -f "$SCHEMA_PATH" ]; then
  echo "Error: Schema file not found: $SCHEMA_PATH" >&2
  exit 2
fi

DB_DIR="$(dirname "$DB_PATH")"
if [ "$DB_DIR" != "." ]; then
  mkdir -p "$DB_DIR"
fi

DB_EXISTS=false
[ -f "$DB_PATH" ] && DB_EXISTS=true

sqlite3 "$DB_PATH" < "$SCHEMA_PATH"

if [ "$DB_EXISTS" = false ]; then
  echo "Created database: $DB_PATH"
fi

ALREADY_APPLIED=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM _migrations WHERE version = $MIGRATE_VERSION;" 2>/dev/null || echo "0")

if [ "$ALREADY_APPLIED" = "0" ]; then
  sqlite3 "$DB_PATH" "INSERT INTO _migrations (version) VALUES ($MIGRATE_VERSION);"
  echo "Applied migration v$MIGRATE_VERSION"
else
  echo "Migration v$MIGRATE_VERSION already applied, skipping"
fi

TABLE_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE '_migrations' AND name NOT LIKE 'sqlite_%';")
INDEX_COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%';")
echo "Database ready: $TABLE_COUNT tables, $INDEX_COUNT indices"
exit 0
