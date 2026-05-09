#!/usr/bin/env bash
set -euo pipefail

# ───────────────────────────────
# One-command GitHub uploader (SSH)
# ───────────────────────────────

# Usage:
# ./git-upload.sh "commit message" REPO_NAME
# Example: ./git-upload.sh "initial commit" Angry_Penguin

MSG="$1"
REPO_NAME="$2"
USERNAME="jofr27"  # your GitHub username

if [ -z "$MSG" ] || [ -z "$REPO_NAME" ]; then
  echo "Usage: ./git-upload.sh \"commit message\" REPO_NAME"
  exit 1
fi

# Ensure git is installed
command -v git >/dev/null 2>&1 || { echo "Git is not installed."; exit 1; }

# Initialize git if not initialized
[ -d .git ] || git init

# Set branch to main
git branch -M main

# Add all files
git add .

# Commit
git commit -m "$MSG" || echo "Nothing to commit"

# Check if remote exists
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
  # Set SSH remote
  REMOTE="git@github.com:$USERNAME/$REPO_NAME.git"
  echo "Setting remote to $REMOTE"
  git remote add origin "$REMOTE"
fi

# Test SSH connection
ssh -T git@github.com >/dev/null 2>&1 || {
  echo "SSH authentication failed. Make sure your key is added to GitHub."
  exit 1
}

# Push to GitHub
git push -u origin main

echo "✅ All done! Your folder is now on GitHub: git@github.com:$USERNAME/$REPO_NAME.git"
