#!/bin/sh

set -e

# Feature-specific tests
bash -c "nvim --help"

# If any of the checks above exited with a non-zero exit code, the test will fail.
