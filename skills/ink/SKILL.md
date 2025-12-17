---
name: ink
description: Build interactive CLI applications with React using Ink. Use when creating terminal UIs, CLI tools with React components, or interactive command-line interfaces.
---

# ink

Build interactive CLI applications with React using Ink. Use when creating terminal UIs, CLI tools with React components, or interactive command-line interfaces.

## When to Use

Use this skill when working with ink.

## Documentation



### https://github.com/vadimdemedes/ink (README)
# Ink: React for CLIs - Quick Reference

## Overview
"React for CLIs. Build and test your CLI output using components." Ink uses Yoga (Facebook's Flexbox engine) to render terminal layouts with familiar CSS-like properties.

## Installation
```sh
npm install ink react
```

## Core Components

**`<Text>`** - Renders styled text with properties for color, bold, italic, underline, strikethrough, and text wrapping/truncation.

**`<Box>`** - Flexbox container (all elements are flex by default). Supports dimensions, padding, margin, gaps, flex properties, borders, and background colors.

**`<Newline>`** - Inserts newline characters within `<Text>`.

**`<Spacer>`** - Flexible space that expands along the primary axis.

**`<Static>`** - Permanently renders output above dynamic content, ideal for logs or completed items.

**`<Transform>`** - Transforms string output before rendering, enabling effects like gradients or links.

## Essential Hooks

**`useInput(handler, options)`** - Captures keyboard input with key state detection.

**`useApp()`** - Provides `exit()` method to unmount the app.

**`useStdin()` / `useStdout()` / `useStderr()`** - Access streams for reading/writing.

**`useFocus()` / `useFocusManager()`** - Tab-based focus management between components.

**`useIsScreenReaderEnabled()`** - Detects screen reader status for accessible output.

## Key API Methods

**`render(tree, options)`** - Mounts component; returns instance with `rerender()`, `unmount()`, `waitUntilExit()`, and `clear()`.

**`measureElement(ref)`** - Returns `{width, height}` of a `<Box>` after render.

## Testing
Use [ink-testing-library](https://github.com/vadimdemedes/ink-testing-library) for component testing with `lastFrame()` output capture.

### https://github.com/vadimdemedes/ink-ui
# Ink UI - Concise Reference

## Core Components

**Input Components:**
- `TextInput` - Single-line text entry with optional autocomplete
- `EmailInput` - Email input with domain autocomplete suggestions
- `PasswordInput` - Masked text input for sensitive data
- `ConfirmInput` - Y/n confirmation prompt

**Selection Components:**
- `Select` - Scrollable single-option picker
- `MultiSelect` - Multi-option picker returning array

**Feedback Components:**
- `Spinner` - Loading indicator with label
- `ProgressBar` - Progress indicator (0-100 value)
- `Badge` - Status indicator with color variants
- `StatusMessage` - Status display with variant (success/error/warning/info)
- `Alert` - High-prominence message display

**List Components:**
- `UnorderedList` / `UnorderedList.Item` - Bulleted lists (nested capable)
- `OrderedList` / `OrderedList.Item` - Numbered lists (nested capable)

## Key Patterns

**Basic Input:**
```jsx
<TextInput placeholder="..." onSubmit={value => {}} />
```

**Theme Customization:**
```jsx
const custom = extendTheme(defaultTheme, {
  components: { Spinner: { styles: { frame: () => ({color: 'magenta'}) } } }
});
<ThemeProvider theme={custom}><Spinner /></ThemeProvider>
```

**Custom Component Theming:**
```jsx
const {styles} = useComponentTheme('ComponentName');
<Text {...styles.label()} />
```

## Best Practices

- Style functions in themes receive component props/state for conditional rendering
- Theme `config` object handles non-style behavior (e.g., list markers)
- All components read styles via React context automatically
- Wrap app with `ThemeProvider` to apply custom themes globally
- Use `useComponentTheme` hook when building custom themed components
