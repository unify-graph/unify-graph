#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Building..."
./build.sh

echo ""
echo "Deploying to surge..."
surge site/ unify-missing-links.surge.sh

echo ""
echo "Live at: https://unify-missing-links.surge.sh"
