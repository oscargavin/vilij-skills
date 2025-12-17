---
name: claude-agent-sdk
description: Build custom AI agents with the Claude Agent SDK (TypeScript). Use when creating agent applications, implementing multi-turn conversations, adding custom MCP tools, configuring subagents, or integrating Claude into Node.js applications. Covers query(), streaming input, custom tools with Zod schemas, MCP servers, hooks, structured outputs, and session management.
---

# Claude Agent SDK (TypeScript)

Build production-ready AI agents with the Claude Agent SDK.

## Installation

```bash
npm install @anthropic-ai/claude-agent-sdk
```

Set `ANTHROPIC_API_KEY` environment variable or use third-party providers (Bedrock, Vertex AI).

## Core Patterns

### Basic Query

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Analyze this codebase",
  options: {
    model: "claude-sonnet-4-5-20250929",
    maxTurns: 10
  }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

### Streaming Input (Recommended for Multi-turn)

Use async generators for multi-turn conversations, image uploads, and MCP tools:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function* generateMessages() {
  yield {
    type: "user" as const,
    message: {
      role: "user" as const,
      content: "Analyze this codebase for security issues"
    }
  };

  // Wait for user input or conditions
  await new Promise(resolve => setTimeout(resolve, 2000));

  yield {
    type: "user" as const,
    message: {
      role: "user" as const,
      content: "Now fix the critical issues you found"
    }
  };
}

for await (const message of query({
  prompt: generateMessages(),
  options: { maxTurns: 10 }
})) {
  console.log(message);
}
```

### V2 Interface (Preview)

Simplified send/receive pattern for multi-turn:

```typescript
import { unstable_v2_createSession } from "@anthropic-ai/claude-agent-sdk";

await using session = unstable_v2_createSession({
  model: "claude-sonnet-4-5-20250929"
});

await session.send("What is 5 + 3?");
for await (const msg of session.receive()) {
  console.log(msg);
}

await session.send("Multiply that by 2");
for await (const msg of session.receive()) {
  console.log(msg);
}
```

## Custom Tools with MCP

Create in-process MCP servers with type-safe tools using Zod:

```typescript
import { query, tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myServer = createSdkMcpServer({
  name: "my-tools",
  version: "1.0.0",
  tools: [
    tool(
      "get_weather",
      "Get current temperature for a location",
      {
        latitude: z.number().describe("Latitude"),
        longitude: z.number().describe("Longitude")
      },
      async (args) => {
        const response = await fetch(
          `https://api.open-meteo.com/v1/forecast?latitude=${args.latitude}&longitude=${args.longitude}&current=temperature_2m`
        );
        const data = await response.json();
        return {
          content: [{ type: "text", text: `Temperature: ${data.current.temperature_2m}C` }]
        };
      }
    )
  ]
});

// Custom tools require streaming input
async function* messages() {
  yield {
    type: "user" as const,
    message: { role: "user" as const, content: "What's the weather in London?" }
  };
}

for await (const msg of query({
  prompt: messages(),
  options: {
    mcpServers: { "my-tools": myServer },
    allowedTools: ["mcp__my-tools__get_weather"]
  }
})) {
  if (msg.type === "result") console.log(msg.result);
}
```

Tool naming format: `mcp__{server_name}__{tool_name}`

## System Prompts

SDK uses empty system prompt by default. Options:

```typescript
// Use Claude Code's system prompt (includes tool instructions)
options: {
  systemPrompt: { type: "preset", preset: "claude_code" }
}

// Extend Claude Code's prompt
options: {
  systemPrompt: {
    type: "preset",
    preset: "claude_code",
    append: "Always include type hints in code examples."
  }
}

// Custom system prompt
options: {
  systemPrompt: "You are a security-focused code reviewer..."
}
```

## Loading CLAUDE.md Files

CLAUDE.md files are NOT loaded by default. Explicitly enable:

```typescript
options: {
  systemPrompt: { type: "preset", preset: "claude_code" },
  settingSources: ["project"]  // Loads CLAUDE.md from project
}
```

## Subagents

Define specialized agents programmatically:

```typescript
options: {
  agents: {
    "code-reviewer": {
      description: "Expert code review specialist. Use for security and quality reviews.",
      prompt: `You are a code review specialist with security expertise.
When reviewing: identify vulnerabilities, check performance, suggest improvements.`,
      tools: ["Read", "Grep", "Glob"],
      model: "sonnet"
    },
    "test-runner": {
      description: "Runs and analyzes test suites.",
      prompt: "You are a test execution specialist...",
      tools: ["Bash", "Read", "Grep"]
    }
  }
}
```

## Structured Outputs

Get validated JSON from agent workflows:

```typescript
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";

const AnalysisResult = z.object({
  summary: z.string(),
  issues: z.array(z.object({
    severity: z.enum(["low", "medium", "high"]),
    description: z.string(),
    file: z.string()
  })),
  score: z.number().min(0).max(100)
});

for await (const msg of query({
  prompt: "Analyze src/ for security issues",
  options: {
    outputFormat: {
      type: "json_schema",
      schema: zodToJsonSchema(AnalysisResult, { $refStrategy: "root" })
    }
  }
})) {
  if (msg.type === "result" && msg.structured_output) {
    const result = AnalysisResult.parse(msg.structured_output);
    console.log(`Score: ${result.score}, Issues: ${result.issues.length}`);
  }
}
```

## Hooks

Intercept events during execution:

```typescript
options: {
  hooks: {
    PreToolUse: [{
      matcher: "Bash",  // Only for Bash tool
      hooks: [async (input, toolUseId) => {
        if (input.tool_input.command?.includes("rm -rf")) {
          return {
            hookSpecificOutput: {
              hookEventName: "PreToolUse",
              permissionDecision: "deny",
              permissionDecisionReason: "Dangerous command blocked"
            }
          };
        }
        return {};
      }]
    }],
    PostToolUse: [{
      hooks: [async (input) => {
        console.log(`Tool ${input.tool_name} completed`);
        return {};
      }]
    }]
  }
}
```

Hook events: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PermissionRequest`

## Permission Modes

```typescript
options: {
  permissionMode: "default"         // Standard behavior
  // permissionMode: "acceptEdits"  // Auto-accept file edits
  // permissionMode: "plan"         // Planning only, no execution
  // permissionMode: "bypassPermissions"  // Bypass all checks (requires allowDangerouslySkipPermissions: true)
}
```

Custom permission handler:

```typescript
options: {
  canUseTool: async (toolName, input, { signal, suggestions }) => {
    if (toolName === "Write" && input.file_path?.startsWith("/system/")) {
      return { behavior: "deny", message: "System writes blocked" };
    }
    return { behavior: "allow", updatedInput: input };
  }
}
```

## Key Options Reference

| Option | Type | Description |
|--------|------|-------------|
| `model` | string | Claude model to use |
| `maxTurns` | number | Maximum conversation turns |
| `maxBudgetUsd` | number | Maximum budget in USD |
| `allowedTools` | string[] | Whitelist of tool names |
| `disallowedTools` | string[] | Blacklist of tool names |
| `mcpServers` | Record | MCP server configurations |
| `systemPrompt` | string \| preset | System prompt configuration |
| `settingSources` | array | Which settings to load: "user", "project", "local" |
| `agents` | Record | Programmatic subagent definitions |
| `hooks` | Record | Event hook configurations |
| `outputFormat` | object | JSON schema for structured outputs |
| `cwd` | string | Working directory |
| `resume` | string | Session ID to resume |
| `continue` | boolean | Continue most recent conversation |

## Message Types

```typescript
for await (const msg of query({ prompt: "..." })) {
  switch (msg.type) {
    case "system":
      // msg.subtype: "init" | "compact_boundary"
      // Init contains: session_id, tools, mcp_servers, model
      break;
    case "user":
      // User message (input or replay)
      break;
    case "assistant":
      // msg.message.content contains TextBlock, ToolUseBlock, ThinkingBlock
      break;
    case "result":
      // msg.subtype: "success" | "error_max_turns" | "error_during_execution" | "error_max_budget_usd"
      // Success: msg.result, msg.total_cost_usd, msg.usage, msg.structured_output
      break;
  }
}
```

## External MCP Servers

```typescript
options: {
  mcpServers: {
    // stdio server
    "filesystem": {
      command: "npx",
      args: ["@modelcontextprotocol/server-filesystem"],
      env: { ALLOWED_PATHS: "/Users/me/projects" }
    },
    // SSE server
    "remote-api": {
      type: "sse",
      url: "https://api.example.com/mcp/sse",
      headers: { Authorization: "Bearer ${API_TOKEN}" }
    },
    // HTTP server
    "http-service": {
      type: "http",
      url: "https://api.example.com/mcp"
    }
  }
}
```

## Plugins

Load custom plugins:

```typescript
options: {
  plugins: [
    { type: "local", path: "./my-plugin" },
    { type: "local", path: "/absolute/path/to/plugin" }
  ]
}
```

Plugin commands use namespace: `plugin-name:command-name`

## Error Handling

```typescript
for await (const msg of query({ prompt: "...", options })) {
  if (msg.type === "result") {
    if (msg.subtype === "success") {
      console.log(msg.result);
    } else if (msg.subtype === "error_max_turns") {
      console.error("Max turns reached");
    } else if (msg.subtype === "error_during_execution") {
      console.error("Execution error:", msg.errors);
    } else if (msg.subtype === "error_max_budget_usd") {
      console.error("Budget exceeded");
    }
  }
}
```

## Query Object Methods

The `query()` return value has additional methods:

```typescript
const q = query({ prompt: generateMessages(), options });

// Interrupt execution (streaming input only)
await q.interrupt();

// Change settings mid-session
await q.setPermissionMode("acceptEdits");
await q.setModel("claude-opus-4-20250514");

// Get info
const commands = await q.supportedCommands();
const models = await q.supportedModels();
const mcpStatus = await q.mcpServerStatus();
const account = await q.accountInfo();
```
