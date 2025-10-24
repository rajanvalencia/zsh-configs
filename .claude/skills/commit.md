---
description: commit without claude code attribution
---

Create a git commit without Claude Code attribution.

## Instructions

1. Check git status to see what changes exist
2. Show the user the diff of changes that will be committed
3. Ask the user for a commit message if not already provided
4. Stage the appropriate files (ask which files if multiple options)
5. Create a commit with ONLY the user's message - do NOT add:
   - The 🤖 Generated with Claude Code footer
   - The Co-Authored-By: Claude line
   - Any other Claude attribution
6. Use a simple git commit command like: `git commit -m "user's message"`
7. Show git log and git status after committing to confirm success

## Important Rules

- NO attribution footers whatsoever
- Keep the commit message exactly as the user provides
- This is for when the user wants full credit for the changes
- Don't use heredoc or multi-line commit format unless the user specifically requests it
