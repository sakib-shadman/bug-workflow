---
name: fix-bug
description: Implement an approved bug fix using an existing investigation report. Use when a developer asks to fix a bug or implement an approved investigation report. Always require explicit implementation approval before modifying files.
when_to_use: Trigger phrases include "fix this bug", "implement the fix", "implement the approved fix in the investigation report", "apply the fix from [name]-investigation-report.md", and "go ahead with the fix". If no saved investigation report exists, the investigation runs first and no files are modified.
argument-hint: "[report-filename]"
---

# Implement an approved bug fix

Input: $ARGUMENTS

The input should name an investigation report at the repository root. If it's empty, find the report referenced in the conversation.

## Non-negotiable rules

1. **No edits before Gate 2.** Don't modify, create, or delete any file until the developer has explicitly approved implementing *this* report's section I, in a message sent after you showed them the scope. Invoking this skill, by name or automatically, is not approval. Neither is approval to investigate, run a diagnostic, save the report, or a review comment like "looks good".
2. **The saved report is the contract.** Read it from disk every time. The developer's edits to it are authoritative; never substitute an earlier version from the conversation.
3. **Stay in scope.** Implement section I and nothing else. Stop and ask before any deviation.
4. **Never commit or push.** Leave all changes uncommitted unless the developer explicitly asks.
5. **Delete the report only after a complete fix.** Once the fix is complete and validated, delete the report file you implemented (section 7). Keep it if the work is partial, blocked, or failing, or if the developer asks to keep it.

Before anything else, read the shared rules at `${CLAUDE_SKILL_DIR}/references/workflow-rules.md`. They define the approval gates, Git safety, and evidence labels used below.

## 1. Find the report

1. Get the repository root with `git rev-parse --show-toplevel`.
2. Resolve the report:
   - If a filename was given, look for it at the repository root.
   - If none was given, list `*-investigation-report.md` at the repository root. Use the one the conversation refers to. If there are several and it's unclear which, ask.
3. **No report found**: don't modify anything. Explain that a fix needs a saved, reviewed investigation report, and offer to run the investigation now with `investigate-bug`. If the developer agrees, follow that skill, which ends at its Gate 1 and doesn't implement.

## 2. Read and verify the contract

1. Read the entire report file with the Read tool. The report's Status line and the title of section I describe the document; they don't grant or withhold approval. Only Gate 2 approves implementation, so don't treat their wording as a contradiction.
2. Read the relevant `CLAUDE.md` files and follow them.
3. Record the current state: `git branch --show-current`, `git rev-parse HEAD`, `git status --short`. Note pre-existing uncommitted and untracked changes. They belong to the developer.
4. Check that the report still matches the code:
   - Every file in section I exists (or is marked as new), and the cited symbols, signatures, and `path:line` evidence for the root cause are still there.
   - If the report has a base commit, compare it with `git log --oneline <base>..HEAD -- <files>` and `git diff <base> -- <files>` for the files in section I.
   - Check whether any section I file has uncommitted changes.
   - Check for unresolved open questions or known blockers in sections H and I.
5. Classify what you found:
   - **No material change**: continue.
   - **Material discrepancy** (see section 5 of this skill): stop, present the evidence and options, and wait for direction.

Don't redo the investigation. Re-check only what the implementation depends on.

## 3. Gate 2: implementation approval

Present a short scope confirmation:

- The report file path, and that you read it from disk.
- The selected solution, in one or two sentences.
- Every file you will modify, create, or delete (from section I), and the tests you will add or update.
- The explicitly excluded scope.
- The validation commands you plan to run.
- That after a complete, validated fix you will delete the report file (give its path), unless the developer asks to keep it.
- Verification results from step 2, including pre-existing changes in any affected file.

Then ask:

> Do you approve implementing this report's section I now? I'll modify only the files listed above.

Stop and wait.

- **Never skip this gate.** Gate 2 approval must come in a developer message sent *after* you presented this scope confirmation. The request that started this skill ("fix it", "implement the report", "investigate and fix", even "implement the approved fix") is not Gate 2, however it's worded. Present the scope, ask, and end your turn without editing.
- **Ambiguous reply**: ask a clarifying question. Don't proceed.
- **Contradictory contract**: if section I contradicts itself, or you offered options, the approval must say how the contradiction is resolved or which option to use. An approval that doesn't is ambiguous. Ask again and don't implement any part of it.
- **Changes requested**: if they changed the report on disk, go back to step 2. If they gave instructions only in chat that change section I, ask them to update the report or confirm that the chat instruction amends it, then repeat this gate.

## 4. Implement

Follow section I faithfully:

- Make minimal, focused changes that follow the project's existing architecture, naming, error handling, and test patterns.
- Apply SOLID and sound object-oriented design where the codebase does. Don't introduce new abstractions the fix doesn't need.
- Keep public APIs compatible unless section I approves a change. Respect platform, compiler, language-version, and deployment-target constraints, and any interop the project requires (for example Objective-C visibility of Swift APIs).
- Add no third-party dependency unless section I approves it.
- Don't refactor unrelated code, reformat untouched lines, or "improve" things outside scope.
- Resolve small unspecified details with the smallest choice consistent with the report and the codebase, and record each one for the final summary.
- If a file in scope has pre-existing uncommitted changes, edit around them carefully and never discard them. If that isn't possible, stop and ask.

**Tests.** Add or update automated tests for the normal, edge, failure, and regression cases in section G, plus lifecycle, asynchronous, and callback-ordering behavior where relevant. Cover every occurrence from section D that section I includes. The regression test should fail without the fix. Where practical, show this by running it before applying the fix. Never weaken, skip, or delete unrelated tests to get a green run.

## 5. Stop for material discrepancies

Stop work on the affected part and ask for renewed approval if:

- current code contradicts the documented root cause;
- files, symbols, or interfaces in section I have changed materially since the base commit;
- the approved solution can't be implemented as written;
- a new dependency is needed;
- an unplanned public API or compatibility change is needed;
- the fix needs files or behavior outside section I.

Present the evidence (`path:line`, command output) and two or three concrete options, such as "adjust the approach like this", "expand scope to include X", or "stop and re-investigate". Wait for the developer's choice. An approved deviation covers only what you presented. Note it in the final report.

## 6. Validate

Run what the project supports, starting narrow:

1. The targeted tests for the change.
2. Broader test suites where practical.
3. Static analysis, linters, and format checks, in check-only mode. Don't auto-format files outside your change.
4. A build of the affected targets where practical.
5. Review `git status --short` and `git diff`, and read every untracked file you created.
6. Check for accidental public API changes, unrelated modifications, missing tests, and unintended configuration, lockfile, or generated-file changes.
7. Fix problems your change introduced and re-run the affected checks.

Before running a command, check whether it rewrites generated files, lockfiles, or project files, and avoid or flag that. Separate failures your change caused from pre-existing failures and environment limits. Confirm a failure is pre-existing (for example the same test fails on a clean checkout of the base) before calling it that. Report exact commands and real results. Never report a check as passed if you didn't run it.

## 7. Delete the investigation report

The report has served its purpose once the fix is in. Delete it only if all of these hold:

- every change in section I was implemented, and any deviations were approved;
- the required validation checks from section I ran and passed, apart from failures you confirmed were pre-existing;
- the developer hasn't asked to keep the report.

If they hold, delete exactly the report file you read in step 1, for example with `rm -- "<repository root>/<name>-investigation-report.md"`. Delete nothing else. Check `git ls-files --error-unmatch <report>` first: if the report is tracked, the deletion shows up as a working-tree change the developer can restore with Git; if it's untracked, the deletion is permanent, so say so in the final report.

If any condition fails, keep the report and explain why in the final report. It still holds the contract for finishing the work.

## 8. Final implementation report

Report, in this order:

1. **Summary of the fix.**
2. **Files changed**: every modified, created, or deleted file and its purpose, including whether the investigation report was deleted or kept, and why.
3. **Design decisions**, including small details you resolved yourself.
4. **Tests executed**: commands and actual results.
5. **Build, lint, and static analysis**: commands and actual results, or why they weren't run.
6. **Unverified behavior**: what couldn't be tested here.
7. **Remaining risks and limitations.**
8. **Deviations from the report**, each with the approval that covered it, or "None".
9. **Final Git status**: `git status --short` output, separating pre-existing changes from changes made by this workflow.

End by noting that nothing was staged, committed, or pushed, and ask whether the developer wants to review the diff or take a next step.
