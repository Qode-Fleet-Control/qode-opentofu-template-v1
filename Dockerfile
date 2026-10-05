# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: the default command runs scripts/check.sh
# (fmt -check, init, validate, plan) and exits 0 when all of it passes. It never
# listens on $PORT.
#
# OpenTofu's own images are not meant as base images since 1.10 (they fail on
# ONBUILD); the documented way is to copy the binary out of the -minimal image.
# Providers are downloaded at BUILD time (`tofu init`, checked against the
# committed .terraform.lock.hcl), so the job itself needs no registry access.

FROM ghcr.io/opentofu/opentofu:1.13.1-minimal AS tofu

FROM alpine:3.22 AS runtime
ARG BUILD_ID=""
ENV BUILD_ID=$BUILD_ID TF_IN_AUTOMATION=1 TF_INPUT=0 HOME=/home/app
RUN apk add --no-cache ca-certificates git \
 && adduser -D -u 10001 -h /home/app app \
 && mkdir /app && chown app:app /app
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu
WORKDIR /app
COPY --chown=app:app . .
USER app
RUN tofu init -input=false -lockfile=readonly
CMD ["sh", "scripts/check.sh"]
