#!/bin/bash
set -x
set -e

# macOS strips DYLD_FALLBACK_LIBRARY_PATH from child processes so this
# wrapper script exists

LD_LIBRARY_PATH="$GITHUB_WORKSPACE/out/hl" \
    DYLD_FALLBACK_LIBRARY_PATH="$GITHUB_WORKSPACE/out/hl:/usr/local/lib:/lib:/usr/lib" \
    DYLD_PRINT_LIBRARIES=1 \
    hl test.hl
