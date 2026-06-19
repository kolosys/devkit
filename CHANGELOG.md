# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `security-audit` subagent for auth boundary review, input validation, secret scanning, CSP/CORS, and dependency auditing.
- `security` skill with reference docs: `nextjs-security.md`, `dependency-audit.md`.
- `kolosys:audit-security` command for full project security audits.
- `promptSignals` routing metadata in all 10 agent frontmatter blocks.
- "When to Use" / "When NOT to Use" sections in all agents.
- `title` and `description` frontmatter on all 14 skill reference docs.

### Changed

- Narrowed `nextjs.mdc` glob from `**/*.{ts,tsx}` to `src/**/*.{ts,tsx}`.
- Narrowed `ai.mdc` glob `**/agents/**` to `**/lib/agents/**` and `**/tools/**` to `**/lib/tools/**`.
- Orchestrator now includes `security-audit` in roster, decision rules, and commands.
- Subagent hook injects context for `security-audit` agent.

## [0.1.0] - 2026-06-19

### Added

- Plugin manifest (`.cursor-plugin/plugin.json`) with name, version, and component paths.
- 6 scoped rules: `kolosys.mdc` (always-on persona), `nextjs.mdc`, `design-system.mdc`, `typescript-standards.mdc`, `go-standards.mdc`, `ai.mdc`.
- 6 skills with reference docs: `nextjs-feature`, `go-library`, `design-system`, `public-content`, `seo-geo`, `ai-integration`.
- 9 subagents: `orchestrator`, `architecture`, `solutions-engineer`, `ai-engineer`, `design`, `content`, `marketing`, `performance-engineer`, `explore-research`.
- 6 commands: `scaffold-route`, `scaffold-go-lib`, `scaffold-ai-feature`, `verify`, `launch-page`, `perf-audit`.
- 3 lifecycle hooks: session-start stack detection, destructive shell guard, subagent context injection.
- `validate.sh` structural validator with frontmatter, cross-reference, and file-size checks.
- Helper scripts: `check-coverage.sh` (Go), `validate-metadata.ts` (SEO).
