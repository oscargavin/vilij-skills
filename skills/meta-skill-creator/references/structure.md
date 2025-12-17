# Meta-Skill Structure Patterns

## Progressive Disclosure for Meta-Skills

Meta-skills can be large since they combine multiple skills. Structure them for efficient context usage:

### Level 1: Always Loaded (SKILL.md body)

Keep under 500 lines. Include:

- Overview and when to use
- Quick reference (most common patterns)
- Integration patterns summary
- Brief skill summaries (2-3 sentences each)
- Gotchas list

### Level 2: On-Demand (references/)

Load when Claude needs deeper detail:

- `included-skills.md` - Full content from each source skill
- Individual skill files if the combined file is too large

## Structuring Large Meta-Skills

When combining 4+ skills or skills with substantial content:

### Option A: Single Reference File

```
meta-skill/
├── SKILL.md (integration focus)
└── references/
    └── included-skills.md (all skills, separated by ---)
```

Best for: 2-4 skills with moderate content

### Option B: Separate Skill Files

```
meta-skill/
├── SKILL.md (integration focus)
└── references/
    ├── skill-a.md
    ├── skill-b.md
    └── skill-c.md
```

Best for: 4+ skills or skills with very detailed content

### Option C: Grouped by Domain

```
meta-skill/
├── SKILL.md (integration focus)
└── references/
    ├── frontend.md (react + tailwind content)
    ├── backend.md (node + database content)
    └── infra.md (docker + deployment content)
```

Best for: Large meta-skills where skills naturally group

## Integration Patterns Section

This is the most valuable part of a meta-skill. Structure it as:

```markdown
## Integration Patterns

### Project Structure
[How to organize files when using all these technologies]

### Data Flow
[How information moves between layers/technologies]

### Development Workflow
[Typical sequence: start dev server, make changes, test, deploy]

### Error Handling
[How errors propagate across technology boundaries]

### Testing Strategy
[How to test integrations between the technologies]
```

## Frontmatter Best Practices

The description is critical for triggering. Include:

1. What the combination enables
2. All included skill names (for searchability)
3. When to use this vs individual skills

Example:
```yaml
description: Build full-stack Electron apps with React and MCP integration. Meta-skill combining: electron, react, tanstack-router, mcp-server. Use when building desktop applications that need Claude integration via Model Context Protocol.
```
