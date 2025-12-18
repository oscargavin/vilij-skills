---
name: tanstack-ai
description: Use when building AI chat interfaces, streaming LLM responses, implementing tool calling, or creating agentic workflows in TypeScript apps. Triggers include React/Solid chat components, OpenAI/Anthropic/Gemini integrations, function calling, approval flows, and multimodal content handling.
---

# TanStack AI

Type-safe SDK for building production-ready AI experiences with streaming, isomorphic tools, and framework support for React/Solid.

## Quick Reference

| Task | Function/Hook |
|------|---------------|
| Stream chat responses | `chat()` + `toStreamResponse()` |
| React chat state | `useChat()` from `@tanstack/ai-react` |
| Define tools | `toolDefinition()` with `.server()` or `.client()` |
| SSE connection | `fetchServerSentEvents(url)` |
| Limit agent iterations | `maxIterations(count)` |
| Tool approval UI | `addToolApprovalResponse({ id, approved })` |

## Installation

```bash
npm install @tanstack/ai @tanstack/ai-react
npm install @tanstack/ai-openai  # or ai-anthropic, ai-gemini, ai-ollama
```

## Server Setup

### Basic Streaming Endpoint

```typescript
import { chat, toStreamResponse } from "@tanstack/ai";
import { openai } from "@tanstack/ai-openai";

export async function POST(request: Request) {
  const { messages } = await request.json();
  
  const stream = chat({
    adapter: openai(),
    messages,
    model: "gpt-4o",
  });
  
  return toStreamResponse(stream);
}
```

### With Tools

```typescript
import { chat, toolDefinition, toStreamResponse } from "@tanstack/ai";
import { openai } from "@tanstack/ai-openai";
import { z } from "zod";

const getWeatherDef = toolDefinition({
  name: "get_weather",
  description: "Get current weather for a city",
  inputSchema: z.object({
    city: z.string().describe("City name"),
  }),
  outputSchema: z.object({
    temperature: z.number(),
    conditions: z.string(),
  }),
});

const getWeather = getWeatherDef.server(async ({ city }) => {
  const response = await fetch(`https://api.weather.com/v1/${city}`);
  return await response.json();
});

export async function POST(request: Request) {
  const { messages } = await request.json();
  
  const stream = chat({
    adapter: openai(),
    messages,
    model: "gpt-4o",
    tools: [getWeather],
    agentLoopStrategy: maxIterations(5), // Limit tool iterations
  });
  
  return toStreamResponse(stream);
}
```

## React Client

### Basic Chat Component

```typescript
import { useState } from "react";
import { useChat, fetchServerSentEvents } from "@tanstack/ai-react";

export function Chat() {
  const [input, setInput] = useState("");
  const { messages, sendMessage, isLoading } = useChat({
    connection: fetchServerSentEvents("/api/chat"),
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (input.trim() && !isLoading) {
      sendMessage(input);
      setInput("");
    }
  };

  return (
    <div>
      {messages.map((message) => (
        <div key={message.id}>
          <strong>{message.role}:</strong>
          {message.parts.map((part, idx) => {
            if (part.type === "text") return <p key={idx}>{part.content}</p>;
            if (part.type === "thinking") {
              return <p key={idx} className="italic">💭 {part.content}</p>;
            }
            return null;
          })}
        </div>
      ))}
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={(e) => setInput(e.target.value)} />
        <button disabled={isLoading}>Send</button>
      </form>
    </div>
  );
}
```

### With Client Tools (Auto-Executed)

```typescript
import { useChat, fetchServerSentEvents } from "@tanstack/ai-react";
import { clientTools, createChatClientOptions } from "@tanstack/ai-client";
import { updateUIDef } from "./tool-definitions";

function ChatWithTools() {
  const [notification, setNotification] = useState("");

  // Client tools execute automatically - no callback needed
  const updateUI = updateUIDef.client((input) => {
    setNotification(input.message);
    return { success: true };
  });

  const tools = clientTools(updateUI);
  const chatOptions = createChatClientOptions({
    connection: fetchServerSentEvents("/api/chat"),
    tools,
  });

  const { messages, sendMessage, isLoading } = useChat(chatOptions);
  // ... rest of component
}
```

### Tool Approval Flow

```typescript
const { messages, sendMessage, addToolApprovalResponse } = useChat({
  connection: fetchServerSentEvents("/api/chat"),
});

// Render approval UI for tools with needsApproval: true
{messages.map((message) => (
  <div key={message.id}>
    {message.parts.map((part) => {
      if (part.type === "tool-call" && part.state === "approval-requested") {
        return (
          <div key={part.id}>
            <p>Approve: {part.name}</p>
            <pre>{JSON.stringify(part.arguments, null, 2)}</pre>
            <button onClick={() => addToolApprovalResponse({ 
              id: part.approval!.id, 
              approved: true 
            })}>
              Approve
            </button>
            <button onClick={() => addToolApprovalResponse({ 
              id: part.approval!.id, 
              approved: false 
            })}>
              Deny
            </button>
          </div>
        );
      }
      return null;
    })}
  </div>
))}
```

## Tool Definitions

### Server Tool (Auto-Executes on Server)

```typescript
import { toolDefinition } from "@tanstack/ai";
import { z } from "zod";

const searchDbDef = toolDefinition({
  name: "search_database",
  description: "Search the database for records",
  inputSchema: z.object({
    query: z.string(),
    limit: z.number().optional().default(10),
  }),
  outputSchema: z.object({
    results: z.array(z.object({ id: z.string(), name: z.string() })),
  }),
});

// .server() creates executable tool with DB/API access
export const searchDb = searchDbDef.server(async ({ query, limit }) => {
  const results = await db.search(query, limit);
  return { results };
});
```

### Client Tool (Executes in Browser)

```typescript
const updateUIDef = toolDefinition({
  name: "update_ui",
  description: "Update the UI with a notification",
  inputSchema: z.object({
    message: z.string(),
    type: z.enum(["success", "error", "info"]),
  }),
  outputSchema: z.object({ success: z.boolean() }),
});

// .client() creates browser-executable tool
const updateUI = updateUIDef.client((input) => {
  showToast(input.message, input.type);
  return { success: true };
});
```

### Tool Requiring Approval

```typescript
const sendEmailDef = toolDefinition({
  name: "send_email",
  description: "Send an email",
  inputSchema: z.object({
    to: z.string().email(),
    subject: z.string(),
    body: z.string(),
  }),
  needsApproval: true, // Pauses for user approval
});
```

## Adapters

### OpenAI

```typescript
import { openai, createOpenAI } from "@tanstack/ai-openai";

// Uses OPENAI_API_KEY env var
const adapter = openai();

// Custom API key
const adapter = createOpenAI(process.env.OPENAI_API_KEY);

// With provider options
const stream = chat({
  adapter,
  messages,
  model: "gpt-4o",
  providerOptions: {
    temperature: 0.7,
    maxTokens: 1000,
  },
});
```

### Anthropic

```typescript
import { anthropic, createAnthropic } from "@tanstack/ai-anthropic";

const adapter = anthropic(); // Uses ANTHROPIC_API_KEY

const stream = chat({
  adapter,
  messages,
  model: "claude-3-5-sonnet-20241022",
});
```

## Multimodal Content

```typescript
const message = {
  role: "user",
  content: [
    { type: "text", text: "What's in this image?" },
    {
      type: "image",
      source: { type: "url", value: "https://example.com/photo.jpg" },
    },
  ],
};

// Or with base64
const imageMessage = {
  role: "user",
  content: [
    { type: "text", text: "Describe this" },
    {
      type: "image",
      source: { type: "data", value: base64ImageData },
      metadata: { detail: "high" },
    },
  ],
};
```

## Connection Adapters

```typescript
// SSE (recommended)
fetchServerSentEvents("/api/chat")

// With auth
fetchServerSentEvents("/api/chat", {
  headers: { Authorization: `Bearer ${token}` },
})

// Dynamic config
fetchServerSentEvents(
  () => `/api/chat?user=${userId}`,
  () => ({ headers: { Authorization: `Bearer ${getToken()}` } })
)

// HTTP stream alternative
fetchHttpStream("/api/chat")
```

## Common Mistakes

### ❌ Forgetting to pass tools to chat()

```typescript
// Wrong - tool defined but not passed
const getWeather = getWeatherDef.server(async (input) => { ... });
const stream = chat({ adapter, messages, model: "gpt-4o" });

// Correct
const stream = chat({ adapter, messages, model: "gpt-4o", tools: [getWeather] });
```

### ❌ Using .server() for browser-only operations

```typescript
// Wrong - this runs on server, can't access React state
const updateUI = updateUIDef.server(async (input) => {
  setNotification(input.message); // Won't work!
});

// Correct - use .client() for browser operations
const updateUI = updateUIDef.client((input) => {
  setNotification(input.message);
  return { success: true };
});
```

### ❌ Not wrapping client tools with clientTools()

```typescript
// Wrong - passing raw tool to useChat
const { messages } = useChat({
  connection: fetchServerSentEvents("/api/chat"),
  tools: [updateUI], // Type error
});

// Correct
const tools = clientTools(updateUI);
const chatOptions = createChatClientOptions({
  connection: fetchServerSentEvents("/api/chat"),
  tools,
});
const { messages } = useChat(chatOptions);
```

### ❌ Missing toStreamResponse() on server

```typescript
// Wrong - returns raw stream
export async function POST(req: Request) {
  const stream = chat({ adapter, messages, model: "gpt-4o" });
  return stream; // Client can't read this
}

// Correct
return toStreamResponse(stream);
```

### ❌ Expecting onToolCall for client tools

```typescript
// Wrong - onToolCall is obsolete for automatic execution
const { messages } = useChat({
  connection: fetchServerSentEvents("/api/chat"),
  onToolCall: async ({ toolName, input }) => { ... }, // Not needed
});

// Correct - client tools auto-execute via clientTools()
```

## Stream Chunk Types

When processing streams manually:

- `content` - Text being generated
- `thinking` - Model reasoning (displays separately)
- `tool-call` - Function call initiated
- `tool-result` - Function result returned
- `done` - Stream complete
- `error` - Error occurred

## Tool States

Observable in UI for feedback:

- `awaiting-input` - Model intends to call tool
- `input-streaming` - Arguments streaming in
- `input-complete` - Ready for execution
- `approval-requested` - Waiting for user approval
- `completed` - Finished with result

## References

See `api.md` for complete type definitions and `guide.md` for advanced patterns.