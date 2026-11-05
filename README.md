# Push Squeeze CMS Schema

Push the content schema of a [Squeeze CMS](https://squeezecms.com) site from
GitHub Actions. Define your types in `squeeze.config.ts` with
[`@squeezecms/schema`](https://www.npmjs.com/package/@squeezecms/schema), and
every push to `main` updates the schema in Squeeze.

## Usage

Create a **Schema push** key (`sqz_push_...`) for your site in the Squeeze
dashboard under API-sleutels, and store it as the repository secret
`SQUEEZE_SCHEMA_TOKEN`.

```yaml
name: Squeeze Schema

on:
  push:
    branches: [main]
    paths: [squeeze.config.ts]

jobs:
  push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version: 26
      - run: npm ci
      - uses: ultimatelemon/squeeze-action@v1
        with:
          token: ${{ secrets.SQUEEZE_SCHEMA_TOKEN }}
```

`npm ci` is only needed when your config imports `@squeezecms/schema`
(`defineSchema`, `defineType`). The action then runs the CLI version your
project installs. Without it, the action runs the latest
`@squeezecms/schema` through `npx`.

## Inputs

| Input               | Default                      | Description                                                                                           |
| ------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| `token`             | (required)                   | Schema push key (`sqz_push_...`). Pass it from a secret.                                              |
| `config`            | `squeeze.config.ts`          | Path to the schema config, relative to `working-directory`.                                           |
| `working-directory` | `.`                          | Directory with the config, e.g. `apps/web` in a monorepo.                                             |
| `api-url`           | `https://api.squeezecms.com` | Squeeze API URL.                                                                                      |
| `force`             | `false`                      | Push even when types or fields that hold content are removed. Removed field values are lost for good. |
| `cli-version`       | (project or latest)          | Pin a version of `@squeezecms/schema`, e.g. `0.1.3`.                                                  |

## Outputs

| Output    | Description                                        |
| --------- | -------------------------------------------------- |
| `changed` | `true` when the push created a new schema version. |
| `version` | The schema version that is live after the push.    |

The CLI output also lands in the job summary.

## When the push fails

- **Validation errors** list the field paths that are wrong.
- **Conflicts** mean the push would remove types or fields that still hold
  content. Move or delete that content first, or set `force: true` if losing
  it is intended.
- **401** means the key is wrong or revoked; **403** that it is not a Schema
  push key.

Requires Node.js 20.19+ or 22.12+ on the runner; add `actions/setup-node` if
the runner has an older version.

## License

MIT
