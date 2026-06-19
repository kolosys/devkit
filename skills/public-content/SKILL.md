---
name: public-content
description: Writes and structures public-facing content for open source projects — READMEs, blogs, docs, changelogs, and landing copy. Use when creating or editing published text.
metadata:
  pathPatterns:
    - "**/README.md"
    - "**/CHANGELOG.md"
    - "src/app/blog/**"
    - "src/app/docs/**"
    - "content/**"
  promptSignals:
    phrases:
      - "readme"
      - "blog post"
      - "changelog"
      - "documentation"
      - "landing page copy"
chainTo:
  - pattern: "sitemap|robots|opengraph|llms.txt"
    targetSkill: seo-geo
    message: "SEO metadata referenced — loading SEO/GEO guidance."
---

# Public Content Writing

TRIGGER when: creating or editing READMEs, blog posts, documentation, changelogs, or landing page copy.
DO NOT TRIGGER when: writing code, designing components, or configuring infrastructure.

## Workflow

1. Identify content type (README, blog, docs, changelog, landing).
2. Gather technical facts from codebase — do not invent APIs.
3. Draft in markdown with scannable structure.
4. Pair with `seo-geo` skill for metadata and discoverability.

## Templates

### README (library)

```markdown
# Project Name
One-line value proposition.

## Install
\`\`\`bash
go get module/path
\`\`\`

## Quick Example
[minimal working code]

## Documentation
[link to full docs]

## License
MIT
```

### Blog Post

- **Title**: specific, benefit-driven
- **Hook**: problem in 2 sentences
- **Body**: approach -> code -> results
- **Close**: takeaway + link to docs/repo

### Changelog Entry

Follow [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [1.2.0] - 2026-06-19
### Added
- Feature X

### Changed
- Breaking: Y — migrate with `...`
```

## Quality Gates

- [ ] Code examples are accurate and tested
- [ ] No vague marketing language
- [ ] Links resolve
- [ ] Suggested title + meta description included

## Paired Agents

- `content` — primary agent for writing and editing
- `marketing` — SEO metadata, launch checklist
- `solutions-engineer` — code example verification
