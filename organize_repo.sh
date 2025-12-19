#!/bin/bash

# Create archive folder for non-curriculum files
mkdir -p _archived_files

# Move demo and test files to archive
mv demo-app _archived_files/ 2>/dev/null || true
mv terragrunt _archived_files/ 2>/dev/null || true
mv rackspace_prep.ipynb _archived_files/ 2>/dev/null || true

# Keep only curriculum-related items in root
echo "Repository reorganization complete"
