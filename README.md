# Kolosys DevKit

Cursor plugin for open source **Go libraries** and **Next.js 16+** public sites. Bundles rules, skills, subagents, hooks, and commands used across Kolosys projects.

## Components

### Rules

| Rule | Scope | Purpose |
|------|-------|---------|
| `kolosys.mdc` | Always | Persona, safety defaults, available resources index |
| `nextjs.mdc` | `src/**/*.{ts,tsx}` | Architecture, routing, caching, Server Actions, performance, SEO, forbidden patterns |
| `design-system.mdc` | `**/*.tsx` | Component layers, Tailwind discipline, theme tokens, import boundaries |
| `typescript-standards.mdc` | `**/*.{ts,tsx}` | Strict TS conventions, code style, error handling |
| `go-standards.mdc` | `**/*.{go,mod,sum}` | Go library standards, performance, code style |
| `ai.mdc` | `**/ai/**`, `**/lib/agents/**` | AI integration patterns, provider abstraction, cost discipline |

### Skills

| Skill | When to use |
|-------|-------------|
| `go-library` | Building Go packages and tests |
| `nextjs-feature` | App Router features and Server Actions |
| `design-system` | Primitives, composites, theming |
| `public-content` | READMEs, blogs, docs, changelogs |
| `seo-geo` | SEO metadata, sitemaps, llms.txt |
| `ai-integration` | LLM integration, RAG, agents, MCP, embeddings |
| `security` | Auth boundaries, CSP/CORS, secrets, dependency auditing |

### Subagents

| Agent | Role |
|-------|------|
| `orchestrator` | Coordinates all specialists |
| `architecture` | Structure, boundaries, caching, API design |
| `solutions-engineer` | Go + Next.js implementation — performant, readable, minimal comments |
| `ai-engineer` | AI features — LLM integration, RAG, agents, MCP, eval |
| `content` | Public copy and technical writing |
| `design` | Tailwind, design system, 2026 UI patterns |
| `marketing` | SEO, GEO, launch discoverability |
| `performance-engineer` | Page load, queries, bundle, SQL, AI cost/latency |
| `explore-research` | Read-only discovery (readonly) |
| `security-audit` | Auth review, secret scanning, CSP/CORS, dependency audit |

### Commands

| Command | Description |
|---------|-------------|
| `kolosys:scaffold-route` | Generate a Next.js 16+ route module |
| `kolosys:scaffold-go-lib` | Generate a Go library skeleton |
| `kolosys:scaffold-ai-feature` | Generate an AI feature scaffold (chat, agent, RAG) |
| `kolosys:verify` | Run full verification — tests, build, types, lint, architecture |
| `kolosys:launch-page` | Orchestrate a complete page launch |
| `kolosys:perf-audit` | Audit Core Web Vitals, bundle, caching, queries |
| `kolosys:audit-security` | Security audit — auth, secrets, CSP, dependencies |

### Hooks

| Event | Behavior |
|-------|----------|
| `SessionStart` | Detects project stack, injects contextual guidance |
| `PreToolUse` (Bash) | Blocks destructive git/rm commands |
| `SubagentStart` | Injects role-specific guidance per agent type |

## Try Asking...

- "Build a pricing page for the ion library docs site"
- "Scaffold a new Go library called synapse"
- "Why is the dashboard page slow?"
- "Add a chat interface powered by Claude"
- "Audit SEO for the marketing site"
- "Review the architecture of the cart feature"
- "Write a blog post announcing photon v2"
- "Build a RAG pipeline over our documentation"
- "Run a security audit on the checkout flow"
- "Audit our dependencies for vulnerabilities"

## Local Installation

```bash
ln -s /path/to/kolosys-devkit ~/.cursor/plugins/local/kolosys-devkit
```

Restart Cursor after installing. Enable the plugin in **Cursor Settings > Plugins**.

## Usage

- **Multi-domain tasks**: invoke `orchestrator` agent to delegate.
- **Next.js features**: `nextjs.mdc` + `design-system.mdc` apply on `.tsx` files; use `nextjs-feature` skill for workflows.
- **Go libraries**: `go-standards.mdc` applies on `.go` files; use `go-library` skill.
- **AI features**: `ai.mdc` applies on AI-related files; use `ai-integration` skill and `ai-engineer` agent.
- **Public site launch**: chain `content` + `marketing` agents with `seo-geo` skill.
- **Scaffolding**: use `kolosys:scaffold-route`, `kolosys:scaffold-go-lib`, or `kolosys:scaffold-ai-feature`.
- **Security**: use `security-audit` agent or `kolosys:audit-security` for auth, dependency, and infra reviews.
- **Verification**: run `kolosys:verify` before shipping.

## Validation

Run the validator to check plugin structure, cross-references, and frontmatter:

```bash
./scripts/validate.sh
```

## Contributing

1. Follow existing file structure conventions (agents, skills, rules, commands, hooks).
2. Every agent must reference at least one skill in a "Skills" section.
3. Every skill must name its paired agent(s) in a "Paired Agents" section.
4. Skills should include `metadata` frontmatter with `pathPatterns` and `promptSignals`.
5. Keep files under 500 lines.
6. Run `./scripts/validate.sh` before submitting changes.

## License

MIT
