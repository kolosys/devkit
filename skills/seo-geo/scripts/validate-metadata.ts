#!/usr/bin/env npx tsx
/**
 * Validates SEO metadata consistency:
 * - sitemap.ts exists
 * - robots.ts exists
 * - llms.txt exists and has content
 * - Root layout has metadataBase
 *
 * Usage: npx tsx skills/seo-geo/scripts/validate-metadata.ts [project-root]
 */

import { existsSync, readFileSync } from 'fs'
import { join } from 'path'

const root = process.argv[2] || process.cwd()
const issues: string[] = []

const checks = [
  { path: 'src/app/sitemap.ts', label: 'sitemap.ts' },
  { path: 'src/app/robots.ts', label: 'robots.ts' },
  { path: 'public/llms.txt', label: 'llms.txt' },
]

for (const { path, label } of checks) {
  const full = join(root, path)
  if (!existsSync(full)) {
    issues.push(`MISSING: ${label} — expected at ${path}`)
  } else {
    const content = readFileSync(full, 'utf-8').trim()
    if (!content) issues.push(`EMPTY: ${label} at ${path}`)
  }
}

const layoutPath = join(root, 'src/app/layout.tsx')
if (existsSync(layoutPath)) {
  const layout = readFileSync(layoutPath, 'utf-8')
  if (!layout.includes('metadataBase')) {
    issues.push('MISSING: metadataBase not found in src/app/layout.tsx')
  }
} else {
  issues.push('MISSING: src/app/layout.tsx not found')
}

if (issues.length === 0) {
  console.log('PASS: All SEO metadata checks passed')
  process.exit(0)
} else {
  console.log(`FAIL: ${issues.length} issue(s) found:`)
  issues.forEach((i) => console.log(`  - ${i}`))
  process.exit(1)
}
