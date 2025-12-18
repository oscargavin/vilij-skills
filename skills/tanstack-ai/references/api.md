# TanStack AI API Reference

## Core Types

### ModelMessage

```typescript
interface ModelMessage {
  role: "user" | "assistant" | "system" | "tool";
  content: string | ContentPart[];
  toolCallId?: string;
}
```

### UIMessage

```typescript
interface UIMessage {
  id: string;
  role: "user" | "assistant" | "system" | "tool";
  parts: MessagePart[];
}
```

### MessagePart Types

```typescript
type MessagePart = 
  | TextPart 
  | ThinkingPart 
  | ToolCallPart 
  | ToolResultPart;

interface TextPart {
  type: "text";
  content: string;
}

interface ThinkingPart {
  type: "thinking";
  id: string;
  content: string;
}

interface ToolCallPart {
  type: "tool-call";
  id: string;
  name: string;
  arguments: Record<string, any>;
  state: "awaiting-input" | "input-streaming" | "input-complete" | 
         "approval-requested" | "executing" | "completed";
  output?: any;
  approval?: { id: string };
}
```

### ContentPart (Multimodal)

```typescript
type ContentPart = TextPart | ImagePart | AudioPart | VideoPart | DocumentPart;

interface ImagePart {
  type: "image";
  source: { type: "url" | "data"; value: string };
  metadata?: { detail?: "low" | "high" | "auto"; mimeType?: string };
}

interface DocumentPart {
  type: "document";
  source: { type: "data"; value: string }; // base64 PDF
}
```

### StreamChunk Types

```typescript
type StreamChunk =
  | ContentStreamChunk
  | ThinkingStreamChunk
  | ToolCallStreamChunk
  | ToolResultStreamChunk
  | DoneStreamChunk
  | ErrorStreamChunk;

interface ContentStreamChunk {
  type: "content";
  delta: string;
  content: string; // accumulated
}

interface ThinkingStreamChunk {
  type: "thinking";
  id: string;
  delta?: string;
  content: string;
}

interface ToolCallStreamChunk {
  type: "tool-call";
  id: string;
  name: string;
  arguments?: string; // JSON string, may be partial
}

interface ToolResultStreamChunk {
  type: "tool-result";
  toolCallId: string;
  output: any;
}
```

## chat() Function

```typescript
function chat(options: ChatOptions): AsyncIterable<StreamChunk>;

interface ChatOptions {
  adapter: AIAdapter;
  messages: ModelMessage[];
  model: string;
  tools?: Tool[];
  systemPrompts?: string[];
  agentLoopStrategy?: AgentLoopStrategy;
  abortController?: AbortController;
  providerOptions?: Record<string, any>;
}
```

## toolDefinition() Function

```typescript
function toolDefinition<TInput, TOutput>(config: {
  name: string;
  description: string;
  inputSchema: ZodSchema<TInput>;
  outputSchema?: ZodSchema<TOutput>;
  needsApproval?: boolean;
  metadata?: Record<string, any>;
}): ToolDefinition<TInput, TOutput>;

interface ToolDefinition<TInput, TOutput> {
  server(execute: (input: TInput) => Promise<TOutput>): ServerTool;
  client(execute: (input: TInput) => TOutput): ClientTool;
}
```

## useChat() Hook (React)

```typescript
function useChat(options: ChatClientOptions): UseChatReturn;

interface ChatClientOptions {
  connection: ConnectionAdapter;
  tools?: ClientTool[];
  initialMessages?: UIMessage[];
  id?: string;
  body?: Record<string, any>;
  onResponse?: (response: Response) => void;
  onChunk?: (chunk: StreamChunk) => void;
  onFinish?: () => void;
  onError?: (error: Error) => void;
}

interface UseChatReturn {
  messages: UIMessage[];
  sendMessage: (content: string) => Promise<void>;
  append: (message: ModelMessage | UIMessage) => Promise<void>;
  addToolResult: (result: ToolResult) => Promise<void>;
  addToolApprovalResponse: (response: { id: string; approved: boolean }) => Promise<void>;
  reload: () => Promise<void>;
  stop: () => void;
  isLoading: boolean;
  error: Error | undefined;
  setMessages: (messages: UIMessage[]) => void;
  clear: () => void;
}
```

## ChatClient Class (Framework-Agnostic)

```typescript
class ChatClient {
  constructor(options: ChatClientOptions);
  
  messages: UIMessage[];
  isLoading: boolean;
  error: Error | undefined;
  
  sendMessage(content: string): Promise<void>;
  append(message: ModelMessage | UIMessage): Promise<void>;
  addToolResult(result: ToolResult): Promise<void>;
  addToolApprovalResponse(response: { id: string; approved: boolean }): Promise<void>;
  reload(): Promise<void>;
  stop(): void;
  clear(): void;
  setMessagesManually(messages: UIMessage[]): void;
}
```

## Connection Adapters

```typescript
// SSE adapter
function fetchServerSentEvents(
  url: string | (() => string),
  options?: RequestInit | (() => RequestInit)
): ConnectionAdapter;

// HTTP stream adapter
function fetchHttpStream(
  url: string | (() => string),
  options?: RequestInit | (() => RequestInit)
): ConnectionAdapter;

// Custom stream adapter
function stream(
  connectFn: (
    messages: ModelMessage[],
    data?: Record<string, any>,
    signal?: AbortSignal
  ) => Promise<ReadableStream<StreamChunk>>
): ConnectionAdapter;
```

## Helper Functions

```typescript
// Convert stream to SSE format
function toServerSentEventsStream(
  stream: AsyncIterable<StreamChunk>,
  abortController?: AbortController
): ReadableStream<Uint8Array>;

// Convert stream to HTTP Response
function toStreamResponse(
  stream: AsyncIterable<StreamChunk>,
  init?: ResponseInit
): Response;

// Agent loop iteration limit
function maxIterations(count: number): AgentLoopStrategy;

// Wrap client tools for useChat
function clientTools(...tools: ClientTool[]): ClientTool[];

// Create typed chat options
function createChatClientOptions(options: ChatClientOptions): ChatClientOptions;

// Infer message types from options
type InferChatMessages<T extends ChatClientOptions> = UIMessage[];
```

## Adapter Creation

### OpenAI

```typescript
import { openai, createOpenAI, type OpenAIConfig } from "@tanstack/ai-openai";

function openai(config?: OpenAIConfig): OpenAIAdapter;
function createOpenAI(apiKey: string, config?: OpenAIConfig): OpenAIAdapter;

interface OpenAIConfig {
  organization?: string;
  baseURL?: string;
}

// Models: "gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo", etc.
```

### Anthropic

```typescript
import { anthropic, createAnthropic, type AnthropicConfig } from "@tanstack/ai-anthropic";

function anthropic(config?: AnthropicConfig): AnthropicAdapter;
function createAnthropic(apiKey: string, config?: AnthropicConfig): AnthropicAdapter;

// Models: "claude-3-5-sonnet-20241022", "claude-3-opus-20240229", etc.
```

### Gemini

```typescript
import { gemini, createGemini } from "@tanstack/ai-gemini";

// Models: "gemini-1.5-pro", "gemini-1.5-flash", "gemini-2.0-flash"
```

### Ollama

```typescript
import { ollama, createOllama } from "@tanstack/ai-ollama";

// Uses local Ollama instance
```

## Event Client (Observability)

```typescript
import { aiEventClient } from "@tanstack/ai/event-client";

// Server-side events
aiEventClient.on("chat:started", (e) => { ... });

// Client-side events  
aiEventClient.on("client:tool-call-updated", (e) => { ... });

// Returns cleanup function
const cleanup = aiEventClient.on("event", handler);
cleanup(); // Unsubscribe
```

## Provider Options

### OpenAI

```typescript
providerOptions: {
  temperature?: number;      // 0-2
  maxTokens?: number;
  topP?: number;             // 0-1
  frequencyPenalty?: number; // 0-2
  presencePenalty?: number;  // 0-2
  reasoning?: {              // GPT-5+ only
    effort: "none" | "minimal" | "low" | "medium" | "high";
    summary?: "auto" | "detailed";
  };
}
```

### Anthropic

```typescript
providerOptions: {
  temperature?: number;
  maxTokens?: number;
  topP?: number;
  topK?: number;
}
```