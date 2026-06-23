---
name: commit-push
description: Stage all changes, commit, and push to remote. Use when user says "commit and push", "commit push", "commit-push", or similar.
---

# Commit and Push

Stage all changes, create a git commit, and push to remote.

## Steps

### 1. Pre-commit verification

**Why:** Catch issues before they enter git history — fixing later requires amend/revert.

1. If `install.sh` (or any `*.sh` file) was modified, run `bash -n install.sh` to verify shell syntax.
2. If the managed-block or `.zsh-config` logic changed, sanity-check with `zsh -n .zsh-config`.
3. If any check fails, fix the issue before proceeding — do NOT skip verification.

### 2. Stage and commit

1. `git add -A` — stage ALL changes (never commit partially)
2. Generate a concise commit message using conventional commit format (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `style:`)
3. `git commit` with that message

### 3. Push

1. `git push` to the current tracking branch
2. If no upstream is set: `git push -u origin HEAD`

## Rules

- No Claude attribution in commit messages — do NOT add Co-Authored-By or any AI attribution lines
- Always include ALL unstaged changes — never commit partially
- Commit message in English, conventional commit format
