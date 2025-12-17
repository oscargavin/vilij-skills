---
name: tanstack-table
description: Work with tanstack-table
---

# tanstack-table

Work with tanstack-table

⚠️ **WARNING:** Superpowers now uses Claude Code's skills system. Custom skills in ~/.config/superpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/superpowers/skills

# TanStack Table - Skill Reference

## Overview

TanStack Table is a **headless** table library - it provides logic and state management but zero UI components. You build all markup and styles yourself.

## Core Concepts

| Concept | Purpose |
|---------|---------|
| **Table Instance** | Main object managing state, features, data processing |
| **Column Defs** | Configuration objects defining column structure/behavior |
| **Row Model** | Determines displayed rows (after filtering, sorting, pagination) |
| **Header Groups** | Hierarchical column header organization |
| **Rows/Cells** | Data elements and their accessors |

## Basic Setup (React)

```tsx
import { useReactTable, getCoreRowModel, flexRender } from '@tanstack/react-table'

const columns = [
  columnHelper.accessor('name', { header: 'Name' }),
  columnHelper.accessor('age', { header: 'Age' }),
]

const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
})

// Render
<table>
  <thead>
    {table.getHeaderGroups().map(headerGroup => (
      <tr key={headerGroup.id}>
        {headerGroup.headers.map(header => (
          <th key={header.id}>
            {flexRender(header.column.columnDef.header, header.getContext())}
          </th>
        ))}
      </tr>
    ))}
  </thead>
  <tbody>
    {table.getRowModel().rows.map(row => (
      <tr key={row.id}>
        {row.getVisibleCells().map(cell => (
          <td key={cell.id}>
            {flexRender(cell.column.columnDef.cell, cell.getContext())}
          </td>
        ))}
      </tr>
    ))}
  </tbody>
</table>
```

## Features (Enable via Options)

- **Sorting**: `getSortedRowModel()`, state: `sorting`
- **Filtering**: `getFilteredRowModel()`, state: `columnFilters` / `globalFilter`
- **Pagination**: `getPaginationRowModel()`, state: `pagination`
- **Selection**: state: `rowSelection`
- **Column Pinning**: state: `columnPinning`
- **Virtualization**: Use `@tanstack/react-virtual` for large datasets

## State Management

```tsx
const [sorting, setSorting] = useState([])

const table = useReactTable({
  // ...
  state: { sorting },
  onSortingChange: setSorting,
})

// Read state
table.getState().sorting
```

## Critical Gotchas

1. **No pre-styled components** - you provide ALL markup and CSS
2. **Framework adapters required** - use `@tanstack/react-table`, `@tanstack/vue-table`, etc.
3. **Immutable data** - avoid direct array mutations; use spread/map for updates
4. **Row models for performance** - always use appropriate row model functions
5. **State is yours** - library doesn't dictate state management approach

## Sources

- https://tanstack.com/table/latest/docs/introduction
