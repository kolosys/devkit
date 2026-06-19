---
name: design-system
description: Builds and extends Tailwind design systems with primitives, composites, theme switching, and 2026 glass-morphism patterns. Use when creating UI components or enforcing design consistency.
metadata:
  pathPatterns:
    - "src/design-system/**"
    - "src/app/**/components/**"
  importPatterns:
    - "@/design-system"
  promptSignals:
    phrases:
      - "design system"
      - "primitive"
      - "composite"
      - "glass-morphism"
      - "theme"
      - "tailwind component"
chainTo:
  - pattern: "src/app/.*/page\\.tsx|actions\\.ts|queries\\.ts"
    targetSkill: nextjs-feature
    message: "Route module files detected — loading Next.js feature guidance."
---

# Design System Development

TRIGGER when: creating or modifying UI components, primitives, composites, variants, or theme tokens.
DO NOT TRIGGER when: working on Server Actions, Go code, content, or SEO metadata.

## Rules

Apply `design-system.mdc` strictly. Summary:

- Primitives -> composites -> route components (one-way deps)
- Max 4 inline Tailwind utilities on consumer elements
- No hardcoded colors; no consumer-side `dark:` variants
- Class logic in `design-system/utils/variants.ts`
- Barrel imports: `import { Button } from '@/design-system'`

## References

- [Glass-morphism](references/glass-morphism.md) — 2026 glass/blur/elevation patterns

## Creating a Primitive

1. Check if existing primitive accepts a new `variant` prop.
2. Add variant logic to `variants.ts`.
3. Create minimal component file in `primitives/`.
4. Export from `design-system/index.ts`.
5. Support light + dark + theme-switch internally.

## Theme Switching

- CSS variables in `design-system/index.css`
- `prefers-color-scheme` fallback
- Toggle via root `class` or `data-theme` — handled in layout, not per-page

## Verification

- [ ] `tsc --noEmit` passes
- [ ] Both themes visually correct
- [ ] Focus rings meet contrast requirements
- [ ] No deep imports from app code into design-system internals

## Paired Agents

- `design` — primary agent for UI decisions
- `solutions-engineer` — wiring components to data/actions
- `performance-engineer` — images, animations, CLS impact
