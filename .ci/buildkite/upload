#!/bin/bash

set -eu

# Makes sure all the steps run on this same agent
sed "s/\$XCODE/$BUILDKITE_AGENT_META_DATA_XCODE/;s/\$COMMIT/$BUILDKITE_COMMIT/" .ci/buildkite/pipeline.template.yml
