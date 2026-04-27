#!/bin/bash
# Build script for TensorFlow framework version of d2l-en
# This script sets up the environment and builds the TensorFlow edition

set -e

echo "=== D2L TensorFlow Build Script ==="
echo "Starting TensorFlow framework build at $(date)"

# Source environment variables if available
if [ -f ".github/actions/setup_env_vars/action.yml" ]; then
    echo "Environment configuration found"
fi

# Verify required environment variables
if [ -z "$REPO_NAME" ]; then
    echo "WARNING: REPO_NAME not set, using default"
    REPO_NAME="d2l-en"
fi

# Install system dependencies
echo "=== Installing system dependencies ==="
apt-get update -y
apt-get install -y pandoc

# Install Python dependencies
echo "=== Installing Python dependencies ==="
pip install tensorflow
pip install d2l
pip install matplotlib
pip install pandas
pip install numpy

# Verify TensorFlow installation
python -c "import tensorflow as tf; print(f'TensorFlow version: {tf.__version__}')"

# Install notebook build tools
pip install notedown
pip install sphinxcontrib-jupyter

# Clone or use existing repository
echo "=== Setting up build directory ==="
BUILD_DIR="build_tensorflow"
mkdir -p $BUILD_DIR

# Copy TensorFlow-specific source files
if [ -d "tensorflow" ]; then
    echo "Copying TensorFlow source files..."
    cp -r tensorflow/* $BUILD_DIR/
else
    echo "ERROR: tensorflow source directory not found"
    exit 1
fi

# Execute notebook builds
echo "=== Building TensorFlow notebooks ==="
cd $BUILD_DIR

# Run d2lbook build to generate outputs
if command -v d2lbook &> /dev/null; then
    d2lbook build outputdir
else
    echo "Installing d2lbook..."
    pip install d2lbook
    d2lbook build outputdir
fi

echo "=== TensorFlow build completed at $(date) ==="
