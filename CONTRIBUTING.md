# Contributing

Thanks for helping improve `bug-workflow`. Bug reports, wording fixes, and new eval cases are all welcome.

## Reporting issues

Open an issue at <https://github.com/sakib-shadman/bug-workflow/issues> using the **Bug report** template. Include:

- your Claude Code version (`claude --version`) and OS;
- the plugin version (`claude plugin list`);
- what you asked, in your own words, and whether you used natural language or a slash command;
- what you expected and what happened, such as the wrong skill triggering, a gate skipped, or a file modified too early;
- relevant transcript excerpts.

**Don't include** secrets, tokens, private ticket contents, proprietary code, or internal URLs. Replace them with placeholders.

Approval-gate problems (a file modified before Gate 1 or Gate 2, or a commit made without a request) are the highest priority. Please flag them in the title.

## Development setup

```bash
git clone https://github.com/sakib-shadman/bug-workflow.git
cd bug-workflow

# Load your working copy for one session without installing it
claude --plugin-dir .
```

If you also have the published plugin installed, disable it while you test (`claude plugin disable bug-workflow@galacticos-labs`), so the two copies don't compete.

## Before opening a pull request

1. **Validate** the plugin:

   ```bash
   claude plugin validate .
   ```

2. **Run the evals** if you changed a skill description or any gate logic:

   ```bash
   claude plugin eval . --scaffold \
     --allow-tools Write Edit "Bash(git *)" "Bash(ls *)" \
     --runs 2 --ablation none
   ```

   Add a case under `evals/` for any new behavior you rely on.

3. **Keep each skill self-contained.** Every skill must work both as part of the plugin and when installed standalone (for example with `npx skills add`). So:
   - Files a skill reads live inside its own folder and are referenced with `${CLAUDE_SKILL_DIR}`, never `${CLAUDE_PLUGIN_ROOT}`.
   - Routing, gates, Git safety, and evidence labels live in `skills/investigate-bug/references/workflow-rules.md`, the canonical copy. `skills/fix-bug/references/workflow-rules.md` must be identical. Edit the canonical file, copy it over, and run `scripts/check-shared-files.sh` (CI runs it too).
   - Skills summarize the non-negotiable rules at the top and link to the rules file. Don't add conflicting copies elsewhere.

4. **Keep examples generic.** No company names, proprietary SDKs, internal URLs, or personal data.

5. **Update `CHANGELOG.md`** under `[Unreleased]`.

## Versioning and releases

Both skills ship as one plugin with one version, following [Semantic Versioning](https://semver.org/). See the changelog for what counts as major, minor, or patch.

To release:

1. Move the `[Unreleased]` entries in `CHANGELOG.md` under a new version heading with the date.
2. Bump `version` in `.claude-plugin/plugin.json`. This is the only place the version is set. Don't add it to the catalog entry in the `galacticos-labs` marketplace ([sakib-shadman/claude-skills](https://github.com/sakib-shadman/claude-skills)).
3. Run `claude plugin validate .` and the eval suite.
4. Merge to `main`, then tag the release: `git tag v<version> && git push origin v<version>`, and create a GitHub release from the tag with the changelog entry.

The catalog entry tracks this repository's default branch, so the catalog needs no change for a release. Users receive the update when `version` changes, through auto-update or `claude plugin update bug-workflow@galacticos-labs`.

Never rename the plugin. If a rename is unavoidable, add a `renames` entry to the catalog's `marketplace.json`.

## Code of conduct

Be respectful and constructive. Maintainers may close issues or pull requests that aren't.
