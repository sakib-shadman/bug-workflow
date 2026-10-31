# Changelog

All notable changes to the `bug-workflow` plugin are documented here. Both skills are versioned together as one plugin, and the version follows [Semantic Versioning](https://semver.org/):

- **Major:** a change to the workflow contract, such as approval gates, the report format that `fix-bug` depends on, or skill names and commands.
- **Minor:** new capabilities that keep existing reports and gates working.
- **Patch:** wording fixes, clarifications, and eval or documentation changes.

The version lives only in `.claude-plugin/plugin.json`. Users receive an update only when it changes.

## [Unreleased]

## [1.0.0] - 2026-11-01

### Added

- `investigate-bug` skill: read-only root-cause investigation from a ticket or description, ticket retrieval through authorized integrations, an evidence-labelled report (sections A–J), and Gate 1 approval before saving the report to the repository root.
- `fix-bug` skill: implements a saved report's section I after explicit Gate 2 approval, checks the report against the current code using the base commit, stops on material discrepancies, validates the change, deletes the investigation report after a complete, validated fix (unless asked to keep it), and produces a final implementation report.
- Shared workflow rules for routing between skills, approval gates, Git safety, and evidence labelling.
- Investigation report template.
- Self-contained skill folders, so each skill also installs standalone through skills.sh (`npx skills add sakib-shadman/bug-workflow`), plus a CI check that keeps the shared rules copies in sync.
- Eval suite covering automatic invocation, the "investigate and fix" path, Gate 2 before edits, fix requests without a report, and unrelated requests.

[Unreleased]: https://github.com/sakib-shadman/bug-workflow/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/sakib-shadman/bug-workflow/releases/tag/v1.0.0
