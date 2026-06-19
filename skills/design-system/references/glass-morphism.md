---
title: Glass-morphism Patterns (2026)
description: Frosted-glass surfaces using backdrop-blur, token-backed opacity, elevation layers, and variants.ts patterns for 2026 UI design.
---

# Glass-morphism Patterns (2026)

## Core Technique

Frosted-glass surfaces using backdrop-blur, semi-transparent backgrounds, and subtle borders. Define in `variants.ts`, never inline.

```ts
// design-system/utils/variants.ts

export const glass = {
  surface: 'bg-surface/80 backdrop-blur-md border border-white/10',
  elevated: 'bg-surface/90 backdrop-blur-lg border border-white/15 shadow-lg',
  subtle: 'bg-surface/60 backdrop-blur-sm border border-white/5',
} as const
```

## Usage in Primitives

```tsx
// design-system/primitives/GlassCard.tsx
import { glass } from '../utils/variants'

interface GlassCardProps {
  elevation?: keyof typeof glass
  children: React.ReactNode
}

export function GlassCard({ elevation = 'surface', children }: GlassCardProps) {
  return <div className={glass[elevation]}>{children}</div>
}
```

## Dark Mode Considerations

- `bg-surface` should resolve to different CSS variables per theme.
- White borders (`border-white/10`) work on dark backgrounds; switch to `border-black/10` for light via CSS variable or conditional class.
- Test contrast ratios — text on glass must meet WCAG 2.2 AA (4.5:1).

## Depth & Elevation

Use glass intensity to communicate depth:

| Layer | Blur | Opacity | Use case |
|-------|------|---------|----------|
| Background | `sm` | 60% | Page-level sections |
| Surface | `md` | 80% | Cards, panels |
| Elevated | `lg` | 90% | Modals, popovers, dropdowns |

## Anti-patterns

- Inline `backdrop-blur-md bg-white/50` on consumer elements — define in `variants.ts`.
- Stacking multiple glass layers (performance degrades; visual muddiness).
- Glass on low-contrast backgrounds — content becomes unreadable.
- Missing `border` — glass surfaces need subtle edges to feel "real."
