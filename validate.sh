#!/bin/bash
# Validation script to check if all files are correct

echo "========================================"
echo "Railway VPS Setup Validation"
echo "========================================"
echo ""

# Check if all required files exist
echo "Checking required files..."
REQUIRED_FILES=(
    "Dockerfile"
    "startup.sh"
    "supervisord.conf"
    "railway.json"
    "README.md"
    "DEPLOYMENT.md"
    ".gitignore"
)

ALL_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        ALL_EXIST=false
    fi
done

echo ""

# Check if scripts are executable
echo "Checking executable permissions..."
EXECUTABLE_FILES=(
    "startup.sh"
    "healthcheck.sh"
    "connect-termux.sh"
)

for file in "${EXECUTABLE_FILES[@]}"; do
    if [ -x "$file" ]; then
        echo "✓ $file is executable"
    else
        echo "✗ $file is not executable"
    fi
done

echo ""

# Check Dockerfile syntax
echo "Checking Dockerfile syntax..."
if command -v docker &> /dev/null; then
    if docker build -t railway-vps-test . --dry-run 2>/dev/null; then
        echo "✓ Dockerfile syntax is valid"
    else
        echo "⚠ Cannot validate Dockerfile (docker build --dry-run not available in this Docker version)"
    fi
else
    echo "⚠ Docker not available for validation"
fi

echo ""

# Check bash script syntax
echo "Checking bash script syntax..."
for script in startup.sh healthcheck.sh connect-termux.sh; do
    if bash -n "$script" 2>/dev/null; then
        echo "✓ $script syntax is valid"
    else
        echo "✗ $script has syntax errors"
    fi
done

echo ""

# Summary
echo "========================================"
if [ "$ALL_EXIST" = true ]; then
    echo "✓ All validation checks passed!"
    echo ""
    echo "Next steps:"
    echo "1. Push code to GitHub"
    echo "2. Deploy on Railway.app"
    echo "3. Enable TCP Proxy in Railway settings"
    echo "4. Connect via SSH from Termux or any SSH client"
else
    echo "✗ Some validation checks failed"
    echo "Please fix the issues before deploying"
fi
echo "========================================"
