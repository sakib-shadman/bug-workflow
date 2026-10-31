---
name: investigate-bug
description: Investigate software bugs, trace root causes, inspect repository code and tests, and prepare an evidence-based investigation report. Use when a developer reports a bug, provides a bug ticket, asks why something is not working, or requests investigation of unexpected behavior. Read-only; never modifies application files.
when_to_use: Trigger phrases include "investigate this bug", "why is X not working", "X is broken", "look into this issue/ticket", "find the root cause", a pasted GitHub/GitLab/Jira issue URL or key, and "investigate and fix". For "investigate and fix", run this skill first; implementation waits for separate approval.
argument-hint: "[ticket-url-or-id | bug description]"
---

# Investigate a bug

Input: $ARGUMENTS

If the input is empty, use the bug described in the conversation.

## Non-negotiable rules

1. **Read-only.** Don't edit, create, delete, format, or generate repository files. Don't install or update dependencies, switch branches, stage, commit, or push. The only file this skill may ever write is the report, and only after Gate 1.
2. **Present before saving.** Show the full report in the conversation first. Write it to disk only after the developer explicitly approves saving it (Gate 1).
3. **Stop after saving.** Saving the report does not approve implementation. Never start `fix-bug` or edit source files from this skill, even if the developer asked to "investigate and fix".

Before anything else, read the shared rules at `${CLAUDE_PLUGIN_ROOT}/references/workflow-rules.md`. They define the approval gates, Git safety, and evidence labels used below.

## 1. Orient

1. Run `git rev-parse --show-toplevel`, `git branch --show-current`, `git rev-parse HEAD`, and `git status --short`. Note any uncommitted or untracked changes as pre-existing developer work.
2. Read the relevant `CLAUDE.md` files (repository root and the directories you investigate) and follow them.
3. Learn enough of the architecture and conventions to trace the bug: build system, module layout, test framework and test locations.

If the session is in plan mode, stay in it for the whole investigation.

## 2. Get the bug details

**If a ticket URL or identifier is given**, fetch it through an integration that's already available:

- GitHub: `gh issue view <number-or-url> --comments`
- GitLab: `glab issue view <id> --comments`, or a connected GitLab MCP server
- Jira, Linear, and others: a connected MCP server or an authenticated CLI; public pages with a web fetch

Collect the title, description, comments, reproduction steps, acceptance criteria, environment, and attachments you can reach. If access fails, diagnose why (not authenticated, no integration, private project, wrong ID), tell the developer what would fix it, and ask them to paste the ticket content instead. Record the access result in the report. Never claim you read something you didn't retrieve, and never ask for credentials.

**If only a description is given**, work from it. Ask focused questions only for essential facts you can't get from the repository, such as observed behavior, environment, or exact steps. Batch them into one message. If a `grill-me` skill is available and the description is thin, you may use it to draw out the details. Otherwise proceed and mark gaps as **Unknown**.

## 3. Investigate

Work through these in order, citing `path:line` for every code claim:

1. Expected vs actual behavior.
2. Reproduction conditions (inputs, configuration, platform, timing).
3. The execution path from entry point to the defect: read the code, follow calls, check configuration and documentation.
4. The root cause, with code evidence and the causal chain to the observed symptom. Use `git log -L`, `git log -S`, or `git blame` when history explains how the defect arrived.
5. Other occurrences: search for the same pattern, sibling implementations, and copies of the defective logic.
6. Whether each occurrence shares the root cause.
7. Existing tests for the affected code, and the coverage gaps that let the bug through.
8. Candidate solutions and their tradeoffs.
9. A recommendation with justification.
10. A file-by-file implementation plan and test plan.

**Commands with side effects.** Before running any command, check what it writes. Builds, test runs, package managers, code generators, and formatters often write build output, caches, lockfiles, or generated sources. Running project code, whether a script, a REPL snippet, or a test, can also write files or make network calls. Do it without asking only after reading the code path and confirming it has no side effects. Prefer static analysis. If a diagnostic genuinely needs such a command, explain what it will run, what it may write, and why it's needed, then wait for approval. That approval covers only that diagnostic. Never say a test or reproduction was run unless you ran it, and report its real output.

Use subagents for broad searches if available, but verify their findings yourself before putting them in the report.

## 4. Write the report

Fill in the template at `${CLAUDE_PLUGIN_ROOT}/templates/investigation-report.md`. Keep every section, A through J, in order. Write "None" or "Not applicable" rather than deleting a section.

- Filename: `<bug-title>-investigation-report.md`, where `<bug-title>` is a short lowercase kebab-case slug of the bug title (for example `checkout-total-nan-with-coupon-investigation-report.md`). If a file with that name already exists at the repository root, choose a distinct slug and mention it. Never overwrite an existing report.
- Fill the header: base commit SHA, branch, working-tree state, date, and ticket access result. `fix-bug` uses the base commit to detect drift.
- Label claims **Confirmed**, **Hypothesis**, **Assumption**, or **Unknown**.
- Include a Mermaid diagram in section C when the flow has more than a couple of steps.
- Section I is the implementation contract. List exactly the source and test changes you recommend, what's excluded, and the validation commands.
- Keep the template's status line unchanged.

## 5. Present, then Gate 1

1. Present the complete report in the conversation, not a summary.
2. Then ask exactly:

   > Would you like me to save this investigation report to the repository root?

3. Stop and wait for the reply.

- **Approved** ("yes", "save it"): write the report to `<repository root>/<bug-title>-investigation-report.md` with the content you presented, including any changes the developer requested. If the session is in plan mode, ask the developer to leave plan mode so the file can be written. Leaving plan mode is not implementation approval, and don't use a plan-approval prompt for this.
- **Changes requested**: revise, present the updated report in full, and ask the Gate 1 question again.
- **Declined**: don't write anything. The report stays in the conversation.

## 6. After saving: stop

Confirm the exact absolute path of the saved file, then end with:

> The report is saved. Review and edit it as needed. Your edits are authoritative. When you want the fix implemented, ask me to implement it or run `/bug-workflow:fix-bug <report-filename>`. I won't modify any other files until you explicitly approve implementation.

Don't start implementation in this turn, even if the original request was "investigate and fix".
