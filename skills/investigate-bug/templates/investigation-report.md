# Investigation report: {{Bug title}}

| Field | Value |
| :- | :- |
| Report file | `{{bug-title}}-investigation-report.md` |
| Ticket | {{URL and identifier, or "None, from developer description"}} |
| Ticket access | {{Retrieved via <tool> / Not accessible: <reason> / Not provided}} |
| Repository | {{repository name}} |
| Branch at investigation | `{{branch}}` |
| Base commit | `{{full commit SHA from git rev-parse HEAD}}` |
| Working tree at investigation | {{clean / list of pre-existing uncommitted changes}} |
| Date | {{YYYY-MM-DD}} |
| Status | Draft for developer review. Implementation is approved separately, when `fix-bug` asks (Gate 2). |

Evidence labels used below: **Confirmed**, **Hypothesis**, **Assumption**, **Unknown**.

---

## A. Bug summary

- **Title:** {{title}}
- **Description:** {{description, quoting the ticket where available}}
- **Expected behavior:** {{expected}}
- **Actual behavior:** {{actual}}
- **Reproduction steps:**
  1. {{step}}
- **Reproduction status:** {{Reproduced by running <command> / Reasoned from code only, not executed / Not reproducible: <why>}}
- **Scope and impact:** {{who or what is affected, how often, severity}}

## B. Root cause

{{Detailed explanation of the defect.}}

**Evidence**

- `{{path/to/file.ext:line}}`: {{what this code does and why it's wrong}} (**Confirmed**)

```{{language}}
{{minimal excerpt of the relevant code}}
```

**Causal chain:** {{how the defect produces the observed behavior, step by step}}

**Impact of the root cause:** {{what else this defect affects}}

## C. Current execution flow

{{Narrative of the relevant execution path, with `path:line` references.}}

```mermaid
flowchart TD
    A[{{entry point}}] --> B[{{step}}]
    B --> C{{{decision}}}
    C -->|{{condition}}| D[{{defect location}}]
```

## D. Other occurrences

| Location | Same root cause? | Evidence | Notes |
| :- | :- | :- | :- |
| `{{path:line}}` | {{Yes / No / Unknown}} | {{why}} | {{include in fix? yes/no}} |

**Search performed:** {{patterns and tools used}}
**Unresolved scope:** {{areas not searched or not determinable}}

## E. Possible solutions

### Option 1: {{name}}
- **Approach:** {{description}}
- **Pros:** {{...}}
- **Cons / risks:** {{...}}
- **Effort:** {{small / medium / large}}

### Option 2: {{name}}
- ...

**Recommendation:** Option {{n}}, because {{justification}}.

## F. Proposed implementation

| File | Change | Purpose |
| :- | :- | :- |
| `{{path}}` | {{modify / create / delete}} | {{why}} |

**API or interface changes:** {{None / list each public signature change and its compatibility impact}}

## G. Test strategy

- **Existing tests to update:** {{path: what changes}}
- **New tests:**
  - Normal: {{scenario}}
  - Edge: {{scenario}}
  - Failure: {{scenario}}
  - Regression (fails before the fix, passes after): {{scenario}}
  - Lifecycle / async / callback ordering, if relevant: {{scenario}}
- **Coverage for each occurrence in section D:** {{mapping}}
- **Validation commands (suggested, not yet run):**
  ```sh
  {{targeted test command}}
  {{broader test / lint / build commands}}
  ```

## H. Risks and open questions

- **Technical risks:** {{...}}
- **Assumptions:** {{...}}
- **Compatibility concerns:** {{platforms, versions, public API, interop}}
- **Open questions for the developer:**
  1. {{question}}

## I. Approved implementation specification

> This section is the implementation contract for `fix-bug`. Edit it freely before approving; the saved file is authoritative. Saving the report does not approve implementation. Approval is given separately when `fix-bug` asks for it. After a complete, validated fix, `fix-bug` deletes this file unless you ask to keep it.

- **Selected solution:** {{option name and one-paragraph summary}}
- **Approved source changes:**
  - `{{path}}`: {{change}}
- **Approved test changes:**
  - `{{path}}`: {{tests to add or update}}
- **Explicitly excluded scope:**
  - {{what must not be changed}}
- **Dependencies:** {{None / name, version, and why. New dependencies need explicit approval}}
- **Compatibility constraints:** {{public API, minimum platform or language versions, interop requirements}}
- **Required validation checks:**
  - {{command and expected result}}
- **Known blockers:** {{None / list}}

## J. Developer review checklist

- [ ] The expected and actual behavior match my understanding of the bug.
- [ ] The root cause is supported by the cited code, not only by inference.
- [ ] Hypotheses, assumptions, and unknowns are clearly marked and acceptable.
- [ ] Every relevant occurrence is listed, and the in/out-of-scope decisions are right.
- [ ] The recommended solution is the one I want implemented.
- [ ] Section I lists every file I expect to change, and nothing more.
- [ ] The excluded scope is correct.
- [ ] No new dependency or public API change is needed, or it is explicitly approved in section I.
- [ ] The test strategy covers normal, edge, failure, and regression cases.
- [ ] The validation commands are correct for this project.
- [ ] Open questions are answered or accepted as risks.
