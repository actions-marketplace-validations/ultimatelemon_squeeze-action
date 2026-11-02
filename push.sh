#!/usr/bin/env bash
# Runs `squeeze-schema push` and exposes the result as step outputs and a job
# summary. The token comes in through SQUEEZE_TOKEN, never on the command line.
set -euo pipefail

if [ -z "${SQUEEZE_TOKEN:-}" ]; then
  echo "::error::token is empty. Pass a Schema push key (sqz_push_...) from a secret."
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "::error::Node.js not found. Add actions/setup-node (Node 20.19+ or 22.12+) before this step."
  exit 1
fi

args=(push --config "${INPUT_CONFIG:-squeeze.config.ts}")
if [ "${INPUT_FORCE:-false}" = "true" ]; then
  args+=(--force)
fi

# Prefer the CLI the project installs: its config imports the same package.
if [ -z "${INPUT_CLI_VERSION:-}" ] && [ -x node_modules/.bin/squeeze-schema ]; then
  cli=(node_modules/.bin/squeeze-schema)
else
  cli=(npx --yes --package "@squeezecms/schema@${INPUT_CLI_VERSION:-latest}" squeeze-schema)
fi

log="$(mktemp)"
status=0
"${cli[@]}" "${args[@]}" 2>&1 | tee "$log" || status=$?

changed=false
version=""
if line="$(grep -E '^✔ schema pushed: version [0-9]+' "$log")"; then
  changed=true
  version="$(sed -E 's/.*version ([0-9]+).*/\1/' <<<"$line")"
elif line="$(grep -E '^= schema unchanged \(version [0-9]+\)' "$log")"; then
  version="$(sed -E 's/.*version ([0-9]+).*/\1/' <<<"$line")"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "changed=$changed"
    echo "version=$version"
  } >>"$GITHUB_OUTPUT"
fi

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Squeeze schema push"
    echo
    echo '```'
    cat "$log"
    echo '```'
  } >>"$GITHUB_STEP_SUMMARY"
fi

if [ "$status" -ne 0 ]; then
  echo "::error::Squeeze schema push failed. See the log above."
fi
exit "$status"
