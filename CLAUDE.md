# CLAUDE.md

Public composite GitHub Action that pushes a Squeeze CMS content schema
(`squeeze.config.ts`) with the `squeeze-schema` CLI from `@squeezecms/schema`.

- `action.yml`: inputs and outputs; the single step runs `push.sh`.
- `push.sh`: picks the project's own CLI from `node_modules` or falls back to
  `npx @squeezecms/schema@<cli-version|latest>`, parses the CLI output into the
  `changed` and `version` outputs and writes the job summary. It matches the
  CLI's `✔ schema pushed: version N` and `= schema unchanged (version N)`
  lines, so a change to that output in squeeze-sdk breaks the outputs here.
- The token only travels through `SQUEEZE_TOKEN`, never as an argument.

## Checks

`code-quality.yml` runs `shellcheck push.sh` and actionlint on GitHub-hosted
runners (public repo: never the self-hosted ones).

## Releases

Users pin `@v1`. Tag `v1.x.y` and move `v1` forward after a release; a
breaking input change needs `v2`.
