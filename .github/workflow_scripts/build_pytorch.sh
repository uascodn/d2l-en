#!/bin/bash
# Build script for PyTorch framework version of d2l-en
# This script compiles the notebook sources using the PyTorch backend
# and runs them to verify correctness.

set -e

# Source environment variables set by the setup_env_vars action
if [ -f "$GITHUB_ENV" ]; then
    source "$GITHUB_ENV" 2>/dev/null || true
fi

echo "========================================"
echo "Building d2l-en with PyTorch backend"
echo "========================================"

# Determine the chapter/folder to build (passed as argument or build all)
FOLDER=${1:-""}

# Activate the conda/virtual environment if present
if [ -n "$CONDA_ENV" ]; then
    source activate "$CONDA_ENV"
elif [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Verify PyTorch installation
echo "Verifying PyTorch installation..."
python -c "import torch; print('PyTorch version:', torch.__version__)"
python -c "import torch; print('CUDA available:', torch.cuda.is_available())"

# Verify d2l package installation
echo "Verifying d2l package..."
python -c "import d2l; print('d2l version:', d2l.__version__)"

# Set the framework environment variable for sphinxcontrib-d2lbook
export D2L_BACKEND=pytorch

# Determine build target
if [ -n "$FOLDER" ]; then
    echo "Building chapter: $FOLDER"
    d2lbook build eval --tab pytorch "$FOLDER"
else
    echo "Building all chapters..."
    d2lbook build eval --tab pytorch
fi

# Check exit status
if [ $? -ne 0 ]; then
    echo "ERROR: PyTorch build failed!"
    exit 1
fi

echo "========================================"
echo "PyTorch build completed successfully."
echo "========================================"
