#!/bin/sh
# The job: format check, init, validate, plan. Exits non-zero on the first failure.
set -eu
cd "$(dirname "$0")/.."
echo "==> tofu fmt -check";  tofu fmt -check -recursive -diff
echo "==> tofu init";        tofu init -input=false -lockfile=readonly
echo "==> tofu validate";    tofu validate
echo "==> tofu plan";        tofu plan -input=false -lock=false
