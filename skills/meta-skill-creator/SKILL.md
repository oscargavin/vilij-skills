---
name: meta-skill-creator
description: Guide for creating meta-skills that combine multiple existing skills into an integrated whole. Use when users want to create a skill that references, synthesizes, or orchestrates multiple other skills together. A meta-skill provides unified guidance for projects using several technologies in combination.
---

# Meta-Skill Creator

This skill provides guidance for creating meta-skills—skills that combine multiple existing skills into a cohesive, integrated reference.

## What is a Meta-Skill?

A meta-skill is a skill that:

1. **References multiple skills** - Combines 2+ existing skills into one
2. **Synthesizes integration patterns** - Documents how the skills work together
3. **Provides unified context** - Single skill activation loads all relevant knowledge
4. **Identifies cross-cutting concerns** - Data flow, shared patterns, common pitfalls

**Example use cases:**

- A "vilij-development" meta-skill combining electron, react, tanstack-router, and claude-agent-sdk skills
- A "fullstack-nextjs" meta-skill combining nextjs, prisma, and tailwind skills
- A "data-pipeline" meta-skill combining pandas, sqlalchemy, and airflow skills

## Core Principles

### Synthesis Over Concatenation

Don't just paste skills together. Analyze how they interact:

- What data flows between them?
- What patterns are shared or conflicting?
- What are the integration points?
- What gotchas exist when using them together?

### Preserve Individual Skill Value

The meta-skill should enhance, not replace, the included skills. Users should still be able to use individual skills when they only need that specific domain.

### Focus on the Seams

The most valuable content in a meta-skill is what's NOT in the individual skills—the integration knowledge:

- How to structure a project using all these technologies
- Common architectural patterns for the combination
- Shared conventions (naming, file structure, data formats)
- Debugging strategies that span multiple layers

## Meta-Skill Creation Process

1. **Gather source skills** - Read each included skill's SKILL.md
2. **Analyze relationships** - Identify how skills connect and interact
3. **Synthesize integration patterns** - Document the cross-cutting concerns
4. **Structure the meta-skill** - Organize for progressive disclosure
5. **Write the meta-skill** - Create SKILL.md with synthesized content

### Step 1: Gather Source Skills

Read each included skill's SKILL.md completely. For each skill, note:

- Core concepts and terminology
- Key APIs or interfaces
- Common patterns and examples
- Best practices and gotchas

### Step 2: Analyze Relationships

For each pair of skills, consider:

**Data Flow:**
- What data passes between these technologies?
- What format transformations occur?
- Where are the handoff points?

**Shared Concepts:**
- Do they use similar patterns differently?
- Are there naming conflicts or conventions to reconcile?
- What abstractions span both?

**Integration Points:**
- Where does code in one technology call the other?
- What configuration connects them?
- What errors can span the boundary?

### Step 3: Synthesize Integration Patterns

This is the core value of a meta-skill. Document:

**Architecture Patterns:**
```markdown
## Project Structure

When using [Skill A] with [Skill B], organize your project:

project/
├── [skill-a-files]/
├── [skill-b-files]/
└── [integration-layer]/
```

**Data Flow Patterns:**
```markdown
## Data Flow

1. User action in [Skill A layer]
2. Data transforms via [integration point]
3. [Skill B] processes and returns
4. Result flows back through [path]
```

**Common Pitfalls:**
```markdown
## Integration Gotchas

- When using X from Skill A with Y from Skill B, remember to Z
- The naming convention in Skill A conflicts with Skill B; prefer A's convention because...
- Error handling: errors from Skill B surface in Skill A as...
```

### Step 4: Structure the Meta-Skill

Follow progressive disclosure (see references/structure.md):

1. **Overview** - What this meta-skill covers and when to use it
2. **Quick Reference** - Most common integration patterns
3. **Included Skills** - Brief summary of each skill with key concepts
4. **Integration Patterns** - The synthesized knowledge (the core value)
5. **Full Skill Content** - Complete content from each skill (in references/)

### Step 5: Write the Meta-Skill

Create SKILL.md following this template:

```markdown
---
name: [meta-skill-name]
description: [What technologies this combines]. Meta-skill combining: [skill1], [skill2], [skill3]. Use when building [type of project] that uses these technologies together.
---

# [Meta-Skill Name]

[One paragraph describing what this meta-skill enables]

## Quick Reference

[Most common patterns users will need - keep this short]

## Integration Patterns

### [Pattern 1: e.g., "Data Flow"]
[How data moves between the technologies]

### [Pattern 2: e.g., "Project Structure"]
[Recommended organization]

### [Pattern 3: e.g., "Common Workflows"]
[Step-by-step for typical tasks]

## Included Skills

### [Skill 1 Name]
[2-3 sentence summary + key concepts list]

### [Skill 2 Name]
[2-3 sentence summary + key concepts list]

## Gotchas & Tips

- [Integration-specific gotcha 1]
- [Integration-specific gotcha 2]

## References

Full content from each skill: `references/included-skills.md`
```

## Output Requirements

A complete meta-skill includes:

```
meta-skill-name/
├── SKILL.md
│   ├── Frontmatter with description mentioning all included skills
│   ├── Quick reference section
│   ├── Integration patterns (THE CORE VALUE)
│   ├── Brief skill summaries
│   └── Gotchas specific to the combination
└── references/
    └── included-skills.md (full content of each skill)
```

The `included-skills.md` file preserves the complete content of each skill so Claude can reference specific details when needed.

## Quality Checklist

Before finishing a meta-skill, verify:

- [ ] Description lists all included skill names
- [ ] Integration patterns section documents cross-cutting concerns
- [ ] Patterns focus on the "seams" between technologies
- [ ] Each included skill is summarized (not just listed)
- [ ] Full skill content is preserved in references/
- [ ] Gotchas are specific to the combination, not copied from individual skills
