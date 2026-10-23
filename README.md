# devops-ci-reusable-lint-workflow

A reusable GitHub Actions workflow (`workflow_call`) that lints a repository's
shell scripts with shellcheck and its workflows with actionlint, plus a thin
caller workflow showing how to use it.

Other repositories can call it instead of copying the same lint job around.

## Layout

| Path | Purpose |
| --- | --- |
| `.github/workflows/lint.yml` | The reusable workflow |
| `.github/workflows/ci.yml` | Caller: runs the lint on every PR and push to `main` |
| `scripts/install-actionlint.sh` | Downloads a pinned actionlint and verifies its checksum |
| `scripts/lint.sh` | Same checks, runnable locally |

## Usage

```yaml
jobs:
  lint:
    uses: matthews-wong/devops-ci-reusable-lint-workflow/.github/workflows/lint.yml@<full-commit-sha>
    with:
      shell-paths: "scripts tests"
```

Pin the `uses:` reference to a full commit SHA, not a branch or tag.

## Validate locally

```sh
make validate
```
