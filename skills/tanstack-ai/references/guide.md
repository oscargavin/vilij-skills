# TanStack AI Patterns Guide

## Agentic Cycle Pattern

The agentic cycle enables LLMs to repeatedly call tools until task completion:

```typescript
// User: "Find flights to Paris under $500 and book the cheapest"
// Cycle 1: searchFlights({destination: "Paris", maxPrice: 500})
// Cycle 2: bookFlight({flightId: "cheapest"}) - requires approval
// Cycle 3: Generate response with booking confirmation
```

Control iteration limits:

```typescript
import { chat, maxIterations } from "@tanstack/ai";

const stream = chat({
  adapter,
  messages,
  model: "gpt-4o",
  tools: [searchFlights, bookFlight],
  agentLoopStrategy: maxIterations(10), // Default is 5
});
```

## Hybrid Tools (Server + Client)

Tools that work in both environments:

```typescript
const addToCartDef = toolDefinition({
  name: "add_to_cart",
  description: "Add item to shopping cart",
  inputSchema: z.object({
    productId: z.string(),
    quantity: z.number(),
  }),
  outputSchema: z.object({
    cartId: z.string(),
    total: z.number(),
  }),
});

// Server implementation (persists to DB)
export const addToCartServer = addToCartDef.server(async (input) => {
  const cart = await db.carts.addItem(input.productId, input.quantity);
  return { cartId: cart.id, total: cart.total };
});

// Client implementation (optimistic UI)
const addToCartClient = addToCartDef.client((input) => {
  updateLocalCart(input.productId, input.quantity);
  return { cartId: "local", total: calculateTotal() };
});
```

## Stream Processing Strategies

Control how content streams to UI:

```typescript
import { 
  ImmediateStrategy,
  BatchStrategy,
  WordBoundaryStrategy,
  PunctuationStrategy,
  CompositeStrategy 
} from "@tanstack/ai";

// Emit every chunk immediately
const immediate = new ImmediateStrategy();

// Emit every 5 chunks
const batched = new BatchStrategy(5);

// Emit on word boundaries
const wordBased = new WordBoundaryStrategy();

// Emit on punctuation
const punctuated = new PunctuationStrategy();

// Combine strategies (OR logic)
const composite = new CompositeStrategy([
  new BatchStrategy(10),
  new PunctuationStrategy(),
]);
```

## Custom Connection Adapter

```typescript
import { stream, type ConnectionAdapter } from "@tanstack/ai-react";

const websocketAdapter: ConnectionAdapter = stream(
  async (messages, data, signal) => {
    return new ReadableStream({
      async start(controller) {
        const ws = new WebSocket("/api/chat-ws");
        
        ws.onopen = () => {
          ws.send(JSON.stringify({ messages, ...data }));
        };
        
        ws.onmessage = (event) => {
          controller.enqueue(JSON.parse(event.data));
        };
        
        ws.onerror = (error) => controller.error(error);
        ws.onclose = () => controller.close();
        
        signal?.addEventListener("abort", () => ws.close());
      },
    });
  }
);
```

## Error Handling in Tools

Return meaningful errors within schema:

```typescript
const searchDef = toolDefinition({
  name: "search",
  description: "Search database",
  inputSchema: z.object({ query: z.string() }),
  outputSchema: z.object({
    results: z.array(z.object({ id: z.string() })).optional(),
    error: z.string().optional(),
  }),
});

const search = searchDef.server(async ({ query }) => {
  try {
    const results = await db.search(query);
    return { results };
  } catch (e) {
    return { error: `Search failed: ${e.message}` };
  }
});
```

## Thinking/Reasoning Display

Handle model reasoning in UI:

```typescript
{message.parts.map((part, idx) => {
  if (part.type === "thinking") {
    return (
      <details key={idx} className="thinking-block">
        <summary>💭 Model reasoning</summary>
        <pre>{part.content}</pre>
      </details>
    );
  }
  if (part.type === "text") {
    return <p key={idx}>{part.content}</p>;
  }
  return null;
})}
```

## Tool State UI Feedback

```typescript
function ToolCallIndicator({ part }: { part: ToolCallPart }) {
  switch (part.state) {
    case "awaiting-input":
      return <span>🔄 Preparing {part.name}...</span>;
    case "input-streaming":
      return <span>📥 Receiving arguments...</span>;
    case "input-complete":
      return <span>⚡ Executing {part.name}...</span>;
    case "approval-requested":
      return <ApprovalDialog part={part} />;
    case "completed":
      return <span>✅ {part.name} complete</span>;
  }
}
```

## SolidJS Differences

```typescript
import { useChat, fetchServerSentEvents } from "@tanstack/ai-solid";

function Chat() {
  // In Solid, these are Accessors - must be called as functions
  const { messages, isLoading, error, sendMessage } = useChat({
    connection: fetchServerSentEvents("/api/chat"),
  });

  return (
    <div>
      {/* Call as functions in Solid */}
      <For each={messages()}>
        {(message) => <div>{message.role}</div>}
      </For>
      {isLoading() && <span>Loading...</span>}
      {error() && <span>Error: {error().message}</span>}
    </div>
  );
}
```

## Per-Model Type Safety

TypeScript enforces valid options per model:

```typescript
// ✅ Valid - GPT-5 supports structured outputs
const stream = chat({
  adapter: openai(),
  model: "gpt-5",
  messages,
  providerOptions: {
    text: { type: "json_schema", json_schema: { /* ... */ } },
  },
});

// ❌ TypeScript error - GPT-4-turbo doesn't support this
const stream = chat({
  adapter: openai(),
  model: "gpt-4-turbo",
  messages,
  providerOptions: {
    text: {}, // Error: 'text' does not exist
  },
});
```

## Multimodal Provider Support

| Provider | Text | Image | Audio | Video | PDF |
|----------|------|-------|-------|-------|-----|
| OpenAI (gpt-4o) | ✅ | ✅ | ❌ | ❌ | ❌ |
| OpenAI (audio-preview) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Anthropic Claude 3 | ✅ | ✅ | ❌ | ❌ | ❌ |
| Anthropic Claude 3.5 | ✅ | ✅ | ❌ | ❌ | ✅ |
| Gemini 1.5/2.0 | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ollama | ✅ | ✅* | ❌ | ❌ | ❌ |

*Ollama image support varies by model