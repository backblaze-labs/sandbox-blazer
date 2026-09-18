#!/usr/bin/env bash
# PROPOSED CI gate for blazer -- NOT IN FORCE.
#
# Emitted by bin/ci-propose.sh in the B2 SDK harness. This is a PROPOSAL. The
# harness is report-only: it writes this file into its own repository and opens
# no PR against https://github.com/Backblaze/blazer.git. A human decides whether this is carried upstream.
#
# THIS SCRIPT IS THE GATE. The workflow beside it (blazer.yml) only calls it.
# Run it on a laptop right now:
#
#     ./blazer-ci.sh
#
# If it passes here it passes in Actions, because it is the same file. Adopting
# CI later is then "wrap the script we already run", not a rewrite.
set -euo pipefail

# Go: -race is not optional. A data race that only appears under load is the
# single most expensive class of bug to find after release, and it costs one
# flag here.
go test -race -coverprofile=coverage.out ./...

# The gate. `go tool cover -func` prints a total line; anything under the floor
# exits non-zero. Written as an explicit exit rather than a bare pipeline so a
# missing coverage.out fails loudly instead of reporting 0 and passing.
go tool cover -func=coverage.out | grep total | awk '{print $3}' \
  | awk -F'%' '{if ($1 < 80) exit 1}'
