# OpenTofu template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with an
[OpenTofu](https://opentofu.org) root module laid on top.

**This repo is a job, not a service.** Its container runs `tofu fmt -check`, `init`,
`validate` and `plan`, then exits — 0 when all of it passes. Nothing listens on `$PORT`.

## What is in it

| file | |
|---|---|
| `versions.tf` | `required_version` and the providers, all credential-free: `hashicorp/random`, `hashicorp/null`, `hashicorp/local` (served by `registry.opentofu.org`) |
| `variables.tf` | inputs, typed, described and validated |
| `main.tf` | `random_pet` + `random_id` names, a `null_resource`, a `local_file` manifest |
| `outputs.tf` | the generated names and the manifest path |
| `.terraform.lock.hcl` | provider pins with hashes for linux/darwin amd64+arm64 and windows amd64 — commit it |
| `terraform.tfvars.example` | copy to `terraform.tfvars` (git-ignored) to override defaults |
| `scripts/check.sh` | the job: `tofu fmt -check -recursive`, `init -lockfile=readonly`, `validate`, `plan` |

Files keep the `.tf` extension so the module also works with Terraform; rename a file to
`.tofu` to use OpenTofu-only features (e.g. state encryption, provider `for_each`).

## Run it

**On the fleet:** `bin/run` builds the image (`docker compose build`) and stops there —
`DOCKER_START_CMD` is empty because there is no server. Run the job with
`docker compose run --rm app`.

**With docker:**

    docker compose build
    docker compose run --rm app        # exit 0 = fmt, init, validate and plan all passed

**Without docker** (needs `tofu` >= 1.9 on `PATH`):

    tofu init
    sh scripts/check.sh
    tofu apply                         # optional: really creates the random names + out/manifest.json
    tofu destroy

`FLEET_RUNTIME=process bin/run` runs `INSTALL_CMD` (`tofu init`) and `BUILD_CMD`
(`tofu validate`) and then stops at the start step, by design.

## Origin

    hand-written — OpenTofu ships no project generator

Laid out as the standard module structure (`main.tf`, `variables.tf`, `outputs.tf`,
`versions.tf`). The lock file came from the official image:

    docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -v "$PWD":/w -w /w ghcr.io/opentofu/opentofu:1.13.1 init -backend=false
    docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -v "$PWD":/w -w /w ghcr.io/opentofu/opentofu:1.13.1 \
      providers lock -platform=linux_amd64 -platform=linux_arm64 -platform=darwin_amd64 -platform=darwin_arm64 -platform=windows_amd64

## Deviations, and why

- `Dockerfile` is a job image on `alpine:3.22` with `tofu` copied from
  `ghcr.io/opentofu/opentofu:1.13.1-minimal` — OpenTofu's images refuse to be used as a
  base image since 1.10 (an `ONBUILD` that exits 1), and copying the binary is the
  documented replacement. `git` is installed so git-sourced modules work.
- Providers are installed at build time against the lock file, so the job needs no
  registry access when it runs. Runs as a non-root `app` user (uid 10001).
- `plan` runs with `-lock=false` and the default local backend: there is no state to lock
  and nothing is written. Configure a remote backend before using `apply` in CI.

## Verified

2026-10-05, on the docker daemon of the build host:

    docker compose build                 # ok
    docker compose run --rm app          # fmt ok, init ok, validate "Success!", plan "4 to add" -> exit 0
    docker compose down --rmi local -v

## Serving over HTTP

There is no HTTP surface. If you add one, listen on `0.0.0.0:$PORT`, serve at `/`, set
`PORT`, `HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD` in `fleet.conf`, and publish
`"${PORT}:${PORT}"` in `compose.yaml`. See `docs/fleet-lifecycle.md`.
