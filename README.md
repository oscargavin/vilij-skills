# 🎯 My Vilij Skills

A collection of [Claude Code](https://claude.ai/claude-code) skills published via [Vilij](https://github.com/vilij-community/vilij).

## What are Skills?

Skills are reusable instructions that enhance Claude Code's capabilities. Each skill in the `skills/` directory contains a `SKILL.md` file that Claude loads when the skill is invoked.

## Structure

```
skills/
├── skill-name/
│   ├── SKILL.md          # Main skill instructions
│   ├── references/       # Supporting documentation
│   ├── scripts/          # Helper scripts
│   └── assets/           # Images, templates, etc.
```

## Installing Skills

Skills from this repo can be installed via the Vilij marketplace or manually:

```bash
# Clone a skill to your local skills directory
cp -r skills/skill-name ~/.claude/skills/
```

## Publishing

Skills in this repo were published using [Vilij](https://github.com/vilij-community/vilij), a desktop app for creating and managing Claude Code skills.

---

*Published with [Vilij](https://github.com/vilij-community/vilij) • Skills for [Claude Code](https://claude.ai/claude-code)*