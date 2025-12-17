# Documentation Reference

Fetched documentation for better-auth skill.


### https://www.better-auth.com/docs/integrations/tanstack
# Better Auth + TanStack Start Integration Reference

## Core API/Components

- **`auth.handler(request)`** - Main handler that processes GET/POST auth requests
- **`auth.api.signInEmail()`** - Sign in with email/password credentials
- **`auth.api.signUpEmail()`** - Register new user with email
- **`auth.api.getSession()`** - Retrieve current session from headers
- **`tanstackStartCookies()`** - Plugin for automatic cookie management in TanStack Start

## Key Usage Patterns

1. **Mount handler** in `/src/routes/api/auth/$.ts` to route authentication requests through `auth.handler()`

2. **Enable cookie handling** by adding `tanstackStartCookies()` plugin to your Better Auth config (must be last in plugins array)

3. **Protect routes** using middleware that calls `auth.api.getSession()` and redirects unauthenticated users to login

## Best Practices & Gotchas

- Use client SDK or `authClient` instead of server actions with `auth.api` where possible
- "When you call functions that need to set cookies (like `signInEmail` or `signUpEmail`)" - use the TanStack cookies plugin
- Middleware must explicitly check session validity before granting route access
- Always pass `request.headers` to `getSession()` for proper session verification
- Configure Better Auth instance before implementing integration endpoints

### https://www.better-auth.com/docs/concepts/api
# Better Auth API - Skill Reference

## Core Components
- **`auth` instance**: Main Better Auth object providing access to all endpoints
- **`api` object**: Exposes every endpoint in your Better Auth instance for server-side interaction
- **`APIError`**: Exception class thrown when API endpoint requests fail

## Key Patterns

**Basic server-side endpoint call:**
```ts
await auth.api.getSession({ headers: await headers() })
```

**Passing parameters (body, headers, query):**
```ts
await auth.api.signInEmail({
  body: { email: "user@example.com", password: "pass" },
  headers: await headers()
})
```

**Retrieving response headers/cookies:**
```ts
const { headers, response } = await auth.api.signUpEmail({
  returnHeaders: true,
  body: { email, password, name }
})
```

## Best Practices

- Import `auth` instance to access `api` object server-side
- Pass `headers` parameter when available for IP/user-agent context
- Use `returnHeaders: true` option to access cookies or custom response headers
- Wrap API calls in try-catch and check for `APIError` instances for proper error handling
- All endpoints built on "better-call" framework allow function-style calls with type inference

### https://www.better-auth.com/docs/plugins/open-api
# Better Auth - Open API Plugin Reference

## Core Components
- **openAPI()** - Plugin that generates OpenAPI 3.0 specification for all auth endpoints
- **auth.api.generateOpenAPISchema()** - Programmatic access to the generated schema as JSON
- **Scalar UI** - Integrated documentation viewer with endpoint testing capabilities

## Key Usage Patterns

**1. Basic Installation**
```ts
import { betterAuth } from "better-auth"
import { openAPI } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [openAPI()]
})
```

**2. Access Documentation**
Navigate to `/api/auth/reference` to view auto-generated OpenAPI docs with grouped endpoints (by plugin, core, and models).

**3. Integrate with Existing Scalar Docs**
```ts
app.get("/docs", Scalar({
  sources: [
    { url: "/api/open-api", title: "API" },
    { url: "/api/auth/open-api/generate-schema", title: "Auth" }
  ]
}))
```

## Important Gotchas & Best Practices
- Plugin is "still in the early stages of development" with gaps being filled
- Default reference path is `/api/auth/reference`—customizable via `path` configuration
- Use `nonce` parameter for CSP-compliant inline scripts
- Set `disableDefaultReference: true` to use custom UI instead of built-in Scalar
- Endpoints automatically grouped: plugin name, "Default" (core), and "Models" (schemas)

### https://www.better-auth.com/docs/basic-usage
# Better Auth - Skill Reference

## Core API/Components

| Component | Purpose |
|-----------|---------|
| `betterAuth()` | Server-side auth instance configuration |
| `createAuthClient()` | Client-side auth client initialization |
| `authClient.signUp.email()` | Register user with email/password |
| `authClient.signIn.email()` | Authenticate user with credentials |
| `authClient.signIn.social()` | Authenticate via social providers |
| `authClient.signOut()` | Terminate user session |
| `authClient.useSession()` | Hook to access session data client-side |
| `authClient.getSession()` | Retrieve session without hook dependency |
| `auth.api.getSession()` | Server-side session retrieval |

## Key Usage Patterns

**Enable Email/Password Authentication:**
```ts
export const auth = betterAuth({
    emailAndPassword: { enabled: true, autoSignIn: true }
})
```

**Client-Side Session Access (React):**
```ts
const { data: session, isPending, error } = authClient.useSession()
```

**Server-Side Session Retrieval (Next.js):**
```ts
const session = await auth.api.getSession({ headers: await headers() })
```

## Important Best Practices

- **Client-only methods**: Always invoke `authClient` methods from client-side; use `auth.api` for server operations
- **Minimum password**: Default enforces 8-character minimum for passwords
- **Auto sign-in control**: Set `autoSignIn: false` to prevent automatic login after signup
- **Social provider setup**: Configure provider credentials via `socialProviders` option with `clientId` and `clientSecret`
- **Plugin pattern**: Add complex features (2FA, magic links) via `plugins` array, then migrate database schema

### https://www.better-auth.com/docs/plugins/api-key
# Better Auth - API Key Plugin Reference

## Core Components

**apiKey()** - Server plugin enabling API key creation, verification, and management with rate limiting and storage options.

**apiKeyClient()** - Client-side plugin for API key operations (create, verify, get, update, delete, list).

**auth.api.createApiKey()** - Generate new API key with optional expiration, rate limits, and metadata.

**auth.api.verifyApiKey()** - Validate API key and check permissions; returns `{valid, error, key}`.

**auth.api.getApiKey()** - Retrieve API key details by ID (excludes key value itself).

**authClient.apiKey.list()** - Fetch all API keys for current user.

## Key Patterns

```ts
// Basic setup
export const auth = betterAuth({
  plugins: [apiKey()]
})

// Create with custom options
const key = await auth.api.createApiKey({
  body: {
    name: "my-key",
    expiresIn: 7 * 24 * 60 * 60, // seconds
    remaining: 1000,
    metadata: { plan: "premium" }
  }
})

// Verify with permissions check
const result = await auth.api.verifyApiKey({
  body: {
    key: apiKeyValue,
    permissions: { files: ["read"] }
  }
})
```

## Important Gotchas & Best Practices

- **API keys assigned to users** - "API keys are assigned to a user"
- **Double rate-limit increment risk** - Manually verifying then fetching session separately counts twice; use `enableSessionForAPIKeys: true` instead
- **Session from API keys security warning** - "A leaked api key can be used to impersonate a user" when using `enableSessionForAPIKeys`
- **Key hashing enabled by default** - Strongly recommended to keep; disabling exposes keys to plaintext database breaches
- **Custom prefix recommended** - Append underscore (e.g., `hello_`) for better identifiability in logs

### https://www.better-auth.com/docs/reference/options
# Better Auth - Skill Reference

## Core API/Components

| Component | Description |
|-----------|-------------|
| `betterAuth()` | Main initialization function for auth configuration |
| `appName` | Application identifier for auth system |
| `baseURL` | Root server URL (checks `BETTER_AUTH_URL` env var) |
| `basePath` | Route mounting path (default: `/api/auth`) |
| `secret` | Encryption/signing key (checks `BETTER_AUTH_SECRET` env) |
| `database` | DB adapter config (PostgreSQL, MySQL, SQLite) |
| `emailAndPassword` | Email/password auth with verification & reset |
| `socialProviders` | OAuth config (Google, GitHub, etc.) |
| `plugins` | Extensibility layer (e.g., emailOTP) |
| `session` | Token expiry, refresh, cookie storage config |
| `user` | Model customization, email changes, deletion |
| `rateLimit` | Request throttling with custom path rules |
| `hooks` | Request lifecycle middleware (before/after) |

## Key Patterns

**1. Basic Setup**
```ts
import { betterAuth } from "better-auth";
export const auth = betterAuth({
  appName: "My App",
  baseURL: "https://example.com",
  secret: process.env.BETTER_AUTH_SECRET
});
```

**2. Email + Password Authentication**
```ts
emailAndPassword: {
  enabled: true,
  minPasswordLength: 8,
  requireEmailVerification: true,
  sendResetPassword: async ({ user, url, token }) => { /* */ }
}
```

**3. Trusted Origins with Wildcards**
```ts
trustedOrigins: [
  "https://*.example.com",
  "http://localhost:3000"
]
```

## Best Practices

- **Security**: Always set `secret` explicitly in production; avoid default fallback
- **Protocol Required**: Use full protocol in wildcard origins (`https://` not just domain)
- **Rate Limiting**: Enable by default in production; customize per-path via `customRules`
- **Session Storage**: Use `secondaryStorage` for scalability; consider `storeSessionInDatabase: true` for consistency
- **Disable CSRF Check**: Only when unavoidable (significant security risk) via `advanced.disableCSRFCheck`

### https://www.better-auth.com/docs/installation
# Better Auth - Quick Reference

## Core API/Components

- **betterAuth()** - Main function to initialize authentication instance with database and auth methods
- **createAuthClient()** - Client-side library to interact with auth server from frontend frameworks
- **Database Adapters** - Support for SQLite, PostgreSQL, MySQL, Drizzle, Prisma, MongoDB
- **Auth Handler** - Route handler mounted at `/api/auth/*` to process authentication requests
- **emailAndPassword** - Built-in authentication method for email/password sign-in
- **socialProviders** - OAuth integration (e.g., GitHub) for social sign-on

## Key Patterns & Usage Examples

**1. Server Setup:**
```ts
import { betterAuth } from "better-auth";
export const auth = betterAuth({
  database: new Database("./sqlite.db"),
  emailAndPassword: { enabled: true }
});
```

**2. API Route Handler (Next.js App Router):**
```ts
import { toNextJsHandler } from "better-auth/next-js";
export const { POST, GET } = toNextJsHandler(auth);
```

**3. Client Usage:**
```ts
import { createAuthClient } from "better-auth/react";
export const authClient = createAuthClient({ baseURL: "http://localhost:3000" });
```

## Best Practices & Gotchas

- **Environment Variables**: `BETTER_AUTH_SECRET` must be ≥32 characters with high entropy; use `openssl rand -base64 32`
- **Database Requirement**: Most plugins require a database; stateless mode available but limited functionality
- **Dual Installation**: Install better-auth in both client and server for separate setups
- **Base URL Config**: Set `BETTER_AUTH_URL` to your app's base URL; required for proper OAuth flows
- **CLI Commands**: Use `npx @better-auth/cli generate` for schema or `migrate` for direct table creation

### https://www.better-auth.com/docs/concepts/client
# Better Auth Client - Skill Reference

## Core API/Components

- **`createAuthClient()`** - Initializes auth client for your framework (React, Vue, Svelte, Solid, vanilla)
- **`signIn.email()`** - Authenticate with email/password credentials
- **`signIn.social()`** - Social provider authentication (e.g., GitHub)
- **`signOut()`** - Terminate user session
- **`useSession()`** - Hook returning session data, loading state, errors, and refetch capability
- **`updateUser()`** - Modify user profile information
- **`$ERROR_CODES`** - Object containing all server error codes for custom handling

## Key Usage Patterns

1. **Initialize client** - Import framework-specific package, call `createAuthClient()` with baseURL, export instance
2. **Use hooks reactively** - Call `useSession()` to access reactive session data with `isPending` and `error` states
3. **Handle responses** - Destructure `{ data, error }` from async calls; check error object for `message`, `status`, `statusText`

## Best Practices & Gotchas

- Pass full URL including custom paths (e.g., `http://localhost:3000/custom-path/auth`) if deviating from `/api/auth`
- Set `disableSignal: true` in fetch options when updates shouldn't trigger hook rerenders
- Use `onSuccess()` or `onError()` callbacks via second argument or nested `fetchOptions` property
- Leverage error codes with `error?.code` for internationalized error messages
- Extend functionality with plugins (e.g., `magicLinkClient()`) passed to `createAuthClient()`

### https://www.better-auth.com/docs/introduction
# Better Auth Skill Reference

## Core Components

- **Better Auth Framework**: "framework-agnostic, universal authentication and authorization framework for TypeScript"
- **Plugin Ecosystem**: Extensible system for advanced features (2FA, passkeys, multi-tenancy, SSO, IDP)
- **MCP Server**: Model Context Protocol integration for AI model compatibility
- **LLMs.txt**: Standardized documentation at `/llms.txt` for AI integration

## Key Patterns

1. **CLI-driven Setup**: Use `npx @better-auth/cli mcp` with flags (`--cursor`, `--claude-code`, `--open-code`, `--manual`) to configure AI tooling integration

2. **MCP Configuration**: Register MCP endpoints via client-specific methods:
   - Claude Code: `claude mcp add --transport http`
   - Open Code: Update `opencode.json` with remote URL
   - Manual: Direct `mcp.json` configuration

3. **Enterprise Features**: Plugin-based approach enables SSO, custom IDPs, and multi-session support without custom development

## Best Practices

- Leverage built-in features before building custom auth logic
- Use the MCP server for AI-assisted development workflows
- Configure via CLI when available (reduces manual steps)
- Integrate `LLMs.txt` exposure for AI model context
- Consider Chonkie or Context7 as alternative MCP providers

### https://www.better-auth.com/docs/authentication/github
# Better-Auth GitHub Provider Reference

## Core API Components

- **`betterAuth()`** - Main auth instance factory accepting configuration options
- **`socialProviders`** - Config object for OAuth providers (e.g., GitHub)
- **`createAuthClient()`** - Client-side auth client factory
- **`signIn.social()`** - Method for initiating social provider authentication

## Key Usage Patterns

1. **Server Setup**: Import `betterAuth`, pass GitHub credentials and redirect URL to `socialProviders` config
2. **Client Sign-In**: Call `authClient.signIn.social({ provider: "github" })` to trigger OAuth flow
3. **Environment Config**: Store `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` as env vars

## Important Gotchas & Best Practices

- **GitHub Apps require email scope**: Configure "Account Permissions > Email Addresses" to "Read-Only" to avoid `email_not_found` errors
- **Redirect URL configuration**: Set to `http://localhost:3000/api/auth/callback/github` for dev; update for production and custom auth paths
- **No refresh tokens**: GitHub OAuth tokens remain valid indefinitely unless revoked or unused for 12 months—no short-lived expiration
- **OAuth vs GitHub Apps**: OAuth apps work out-of-box; GitHub Apps need explicit email permission setup
- **Required scope**: Must include `user:email` scope in GitHub app configuration

### https://www.better-auth.com/docs/concepts/hooks
# Better Auth Hooks - Skill Reference

## Core API/Components

- **`betterAuth()`** - Main configuration function accepting hooks configuration
- **`createAuthMiddleware()`** - Wraps hook logic, receives `ctx` object with request/response utilities
- **`APIError`** - Throw with status code and message for error responses
- **`ctx.path`** - Current endpoint path string
- **`ctx.body`** - Parsed POST request body
- **`ctx.context`** - Auth-related data (newSession, secret, password hasher, adapter, cookies config)

## Key Patterns

**Before Hook - Validation:**
```ts
hooks: { before: createAuthMiddleware(async (ctx) => {
    if (ctx.path !== "/sign-up/email") return;
    if (!ctx.body?.email.endsWith("@example.com")) {
        throw new APIError("BAD_REQUEST", {message: "Invalid domain"});
    }
})}
```

**After Hook - Side Effects:**
```ts
hooks: { after: createAuthMiddleware(async (ctx) => {
    if(ctx.path.startsWith("/sign-up") && ctx.context.newSession) {
        sendNotification(ctx.context.newSession.user);
    }
})}
```

**Response Methods:** `ctx.json()`, `ctx.redirect()`, `ctx.setCookies()`, `ctx.setSignedCookie()`

## Best Practices

- Use hooks for "custom adjustments to an endpoint rather than making another endpoint"
- Access `ctx.context.newSession` only in after hooks (doesn't exist in before)
- Prefer `ctx.context.internalAdapter` for DB operations to enable hooks/secondary storage
- Use `ctx.context.password.hash/verify` for password operations
- For cross-endpoint reuse, convert to a plugin instead of duplicating hooks

### https://www.better-auth.com/docs/concepts/api\n-
Request failed with status code 404

### https://www.better-auth.com/docs/plugins/open-api\n-
Request failed with status code 404

### https://www.better-auth.com/docs/plugins/api-key\n-
Request failed with status code 404

### https://www.better-auth.com/docs/reference/options\n-
Request failed with status code 404

### https://www.better-auth.com/docs/concepts/client\n-
Request failed with status code 404

### https://www.better-auth.com/docs/basic-usage\n-
Request failed with status code 404

### https://www.better-auth.com/docs/installation\n-
Request failed with status code 404

### https://www.better-auth.com/docs/concepts/api
# Better Auth API Reference

## Core Components
- **`auth` instance**: Main Better Auth object with `api` property exposing all endpoints
- **`api` object**: Exposes every endpoint from core and plugins as callable functions
- **`APIError`**: Error class thrown on failed API calls with `message` and `status` properties

## Key Usage Patterns

**Server-side endpoint calls:**
```ts
await auth.api.getSession({ headers: await headers() })
```

**Passing parameters (body, headers, query):**
```ts
await auth.api.signInEmail({
  body: { email: "user@example.com", password: "pass" },
  headers: await headers(),
  query: { token: "value" }
})
```

**Retrieve response metadata:**
```ts
const { headers, response } = await auth.api.signUpEmail({
  returnHeaders: true,
  body: { email, password, name }
})
// OR use asResponse: true for full Response object
```

## Best Practices & Gotchas

- Pass `headers` to endpoints when available—enables IP/user agent tracking
- Better Auth API built on "better-call," enabling direct function calls to REST endpoints
- Server calls return plain objects/arrays; use `returnHeaders` or `asResponse` for HTTP metadata
- Always wrap server calls in try-catch; errors are `APIError` instances with diagnostic properties
- Cookies accessible via `headers.get("set-cookie")` when using `returnHeaders: true`

### https://www.better-auth.com/docs/plugins/open-api
# Better Auth - Open API Plugin Reference

## Core Components
- **openAPI()** - Plugin that generates OpenAPI 3.0 specification for all auth endpoints
- **auth.api.generateOpenAPISchema()** - Returns OpenAPI schema as JSON object
- **Scalar** - Library used to render interactive API documentation UI

## Key Patterns

1. **Basic Installation**
```ts
import { openAPI } from "better-auth/plugins"
export const auth = betterAuth({
    plugins: [openAPI()]
})
```

2. **Access Documentation**
Navigate to `/api/auth/reference` to view auto-generated endpoint docs with grouped sections for plugins, core, and models.

3. **Multi-API Integration**
```ts
app.get("/docs", Scalar({
  sources: [
    { url: "/api/open-api", title: "API" },
    { url: "/api/auth/open-api/generate-schema", title: "Auth" }
  ]
}))
```

## Best Practices & Gotchas
- Plugin is "still in the early stages" - expect evolving features
- Configure `path` parameter to avoid URL conflicts; appends to base auth path
- Use `nonce` parameter for CSP compliance with inline scripts
- Set `disableDefaultReference: true` only if building custom UI
- Endpoints automatically grouped by origin (plugin name, "Default" for core)

### https://www.better-auth.com/docs/basic-usage
# Better Auth - Skill Reference

## Core API/Components

**Server-Side:**
- `betterAuth()` - Initialize auth instance with configuration options
- `auth.api.signInEmail()` - Server-side email authentication
- `auth.api.getSession()` - Retrieve session data with request headers

**Client-Side:**
- `authClient.signUp.email()` - Register new user via email/password
- `authClient.signIn.email()` - Authenticate existing user
- `authClient.signIn.social()` - OAuth via social providers (Google, GitHub, Apple, etc.)
- `authClient.useSession()` - React/Vue/Svelte hook for reactive session access
- `authClient.getSession()` - Promise-based session retrieval
- `authClient.signOut()` - Terminate user session

## Key Patterns

**Email & Password Setup:**
```ts
export const auth = betterAuth({
    emailAndPassword: { enabled: true }
})
```

**Social Provider Configuration:**
```ts
socialProviders: {
    github: {
        clientId: process.env.GITHUB_CLIENT_ID!,
        clientSecret: process.env.GITHUB_CLIENT_SECRET!
    }
}
```

**Plugin Integration (2FA Example):**
```ts
plugins: [twoFactor()]
// Then: authClient.twoFactor.enable(), .disable(), .verifyTOTP()
```

## Best Practices & Gotchas

- **Client-only:** "Always invoke client methods from the client side. Don't call them from the server."
- Auto sign-in enabled by default post-signup; disable via `autoSignIn: false` if needed
- Password minimum 8 characters by default
- For server-side auth in non-Next.js frameworks, manually parse/set cookies unless plugin provided
- Database schema migration required after plugin installation (`npx @better-auth/cli migrate`)

### https://www.better-auth.com/docs/plugins/api-key
# Better Auth - API Key Plugin Reference

## Core API/Components

| Component | Description |
|-----------|-------------|
| `apiKey()` | Server plugin enabling API key creation, verification, and management |
| `apiKeyClient()` | Client-side plugin for API key operations |
| `auth.api.createApiKey()` | Generate new API key with optional expiration/rate limits |
| `auth.api.verifyApiKey()` | Validate key and check permissions |
| `auth.api.getApiKey()` | Retrieve key details (excludes actual key value) |
| `auth.api.updateApiKey()` | Modify name, remaining count, refill settings, metadata |
| `auth.api.deleteApiKey()` | Remove specific API key |
| `auth.api.listApiKeys()` | Fetch all keys for authenticated user |

## Key Patterns

**Basic Setup:**
```ts
import { apiKey } from "better-auth/plugins"
export const auth = betterAuth({
  plugins: [apiKey()]
})
```

**Verify with Permissions:**
```ts
const result = await auth.api.verifyApiKey({
  body: { key: "your_key", permissions: { files: ["read"] } }
})
```

**Secondary Storage (Redis):**
```ts
apiKey({
  storage: "secondary-storage",
  fallbackToDatabase: true
})
// Must configure secondaryStorage in betterAuth options
```

## Important Gotchas & Best Practices

- **Double Rate-Limit Increment**: Manually verifying then fetching session separately doubles the counter; use `enableSessionForAPIKeys: true` instead
- **API Key Security**: "Storing API keys in plaintext makes them vulnerable to database breaches"—keep hashing enabled (default)
- **Session Impersonation Risk**: "A leaked api key can be used to impersonate a user" when `sessionForAPIKeys` enabled
- **Automatic Expiration**: System auto-deletes expired keys on endpoint calls (10-second cooldown between cleanup attempts)
- **Metadata & Permissions**: Both are optional features—enable explicitly (`enableMetadata: true`) if needed for your use case

### https://www.better-auth.com/docs/reference/options
# Better Auth Skill Reference

## Core Components

- **betterAuth()** - Main configuration function for initializing authentication
- **appName** - Application identifier
- **baseURL/basePath** - Server location and route mounting
- **database** - Primary data storage (PostgreSQL, MySQL, SQLite)
- **secondaryStorage** - Cache layer for sessions and rate limits
- **socialProviders** - OAuth integrations (Google, GitHub, etc.)
- **plugins** - Extensible feature modules (emailOTP, etc.)

## Key Configuration Patterns

**Basic Setup:**
```ts
import { betterAuth } from "better-auth";
export const auth = betterAuth({
  appName: "MyApp",
  baseURL: "https://example.com",
  secret: "your-secret-key"
});
```

**Email/Password Authentication:**
```ts
emailAndPassword: {
  enabled: true,
  requireEmailVerification: true,
  minPasswordLength: 8
}
```

**Email Verification:**
```ts
emailVerification: {
  sendVerificationEmail: async ({ user, url, token }) => { /* ... */ },
  sendOnSignUp: true,
  expiresIn: 3600
}
```

## Important Best Practices

- **Secret Management**: Use environment variables (`BETTER_AUTH_SECRET` or `AUTH_SECRET`); generate with `openssl rand -base64 32`
- **Trusted Origins**: Always include protocol prefix for wildcard patterns (`https://*.example.com` not `*.example.com`)
- **Rate Limiting**: "enabled: true in production, false in development" by default
- **Session Storage**: Use `storeSessionInDatabase: true` when secondary storage is configured
- **Security**: Never disable CSRF checks (`disableCSRFCheck`) in production; OAuth tokens encrypted by default (`encryptOAuthTokens: true`)

### https://www.better-auth.com/docs/installation
# Better Auth - Skill Reference

## Core API/Components

- **`betterAuth()`** - Main factory function to initialize authentication instance with config options
- **`createAuthClient()`** - Client-side factory for framework-specific auth interactions (React, Vue, Svelte, Solid, Vanilla)
- **`toNextJsHandler()`, `toNodeHandler()`, etc.** - Framework adapters to mount auth handlers on server routes
- **Database Adapters** - Built-in support: Drizzle, Prisma, MongoDB, plus native SQLite/PostgreSQL/MySQL
- **Authentication Methods** - `emailAndPassword`, `socialProviders` config for built-in auth strategies

## Key Patterns & Usage Examples

1. **Server Setup**: Create `auth.ts` file, import `betterAuth()`, configure database and auth methods, export as `auth`

2. **Route Handler**: Mount auth on `/api/auth/*` catch-all route using framework-specific handler (e.g., `toNextJsHandler(auth)` for Next.js App Router)

3. **Client Usage**: Import `createAuthClient()` from framework package, optionally specify `baseURL`, destructure methods like `signIn`, `signUp`, `useSession`

## Important Gotchas & Best Practices

- **Environment Variables Required**: Set `BETTER_AUTH_SECRET` (32+ chars) and `BETTER_AUTH_URL` in `.env`
- **Database Setup**: Run `npx @better-auth/cli generate` or `migrate` to create schema; most plugins require database
- **Separate Client/Server**: Install better-auth in both parts if using separate setups
- **Custom Base Path**: When using non-default `/api/auth` path, pass full URL including path to `createAuthClient()`
- **Framework-Specific Handlers**: Express v5+ requires `/{*any}` syntax instead of `*` for catch-all routes

### https://www.better-auth.com/docs/concepts/client
# Better Auth Client - Skill Reference

## Core API/Components

- **createAuthClient()** - Factory function initializing the authentication client with baseURL and fetchOptions
- **signIn.email()** - Email/password authentication method
- **signIn.social()** - OAuth provider authentication (GitHub, etc.)
- **signOut()** - Terminates user session
- **useSession()** - Reactive hook returning session data, loading state, errors, and refetch capability
- **updateUser()** - Modifies user profile information
- **$ERROR_CODES** - Object containing all server error codes for custom handling

## Key Usage Patterns

1. **Client Setup**: Import framework-specific client (`better-auth/react`, `/vue`, `/svelte`), call createAuthClient with baseURL
2. **Authentication Flow**: Use `signIn.email()` or `signIn.social()`, handle response object containing `data` and `error`
3. **UI Reactivity**: Leverage `useSession()` hook to access `isPending`, `error`, and trigger `refetch()` when needed

## Important Gotchas & Best Practices

- If using custom auth path other than `/api/auth`, must provide full URL including path
- Hook rerenders trigger automatically on successful endpoint calls; use `disableSignal: true` to prevent
- Response objects always return `{ data, error }` structure; check error before accessing data
- Pass `onError()` callback in fetchOptions for error handling or check error post-request
- Framework-specific imports required for hook functionality; vanilla JS uses `better-auth/client`

### https://www.better-auth.com/docs/introduction
# Better Auth Skill Reference

## Core Components

- **Better Auth Framework**: "framework-agnostic, universal authentication and authorization framework for TypeScript"
- **Plugin Ecosystem**: Extensible system for advanced functionalities (2FA, passkeys, multi-tenancy, SSO)
- **LLMs.txt**: Machine-readable authentication integration documentation
- **MCP Server**: Model Context Protocol integration for AI tooling support

## Key Patterns

1. **CLI Integration**: Use `npx @better-auth/cli mcp [flag]` to add MCP support to Cursor, Claude Code, or Open Code
2. **Manual MCP Setup**: Configure via JSON in client-specific files (mcp.json, opencode.json, etc.)
3. **Feature-First Approach**: Leverage built-in capabilities (multi-session, enterprise SSO) before custom plugins

## Best Practices

- Enterprise features (SSO, IDP creation) are natively supported—avoid reimplementing
- AI tooling integration available via LLMs.txt and official MCP for enhanced automation
- Use CLI commands for streamlined MCP client setup rather than manual configuration
- Plugin ecosystem reduces development overhead for advanced auth requirements
- Framework-agnostic design allows flexible integration across TypeScript projects

### https://www.better-auth.com/docs/authentication/github
# better-auth GitHub Provider Reference

## Core API/Components
- **`betterAuth()`** – Main auth instance factory accepting configuration options
- **`socialProviders`** – Configuration object for OAuth providers including GitHub
- **`createAuthClient()`** – Client-side auth client factory for sign-in operations
- **`signIn.social()`** – Client function to initiate OAuth sign-in flow

## Key Usage Patterns

**1. Server-side provider setup:**
```ts
export const auth = betterAuth({
  socialProviders: { github: { clientId, clientSecret } }
})
```

**2. Client-side authentication:**
```ts
const authClient = createAuthClient()
authClient.signIn.social({ provider: "github" })
```

**3. Redirect configuration:**
Set callback URL to `http://localhost:3000/api/auth/callback/github` (local) or production domain

## Best Practices & Gotchas

- **Email scope required:** "You MUST include the user:email scope in your GitHub app"
- **GitHub Apps vs OAuth apps:** GitHub Apps require explicit "Read-Only" email permission configuration; regular OAuth apps don't
- **No refresh tokens:** GitHub doesn't issue refresh tokens; access tokens remain valid indefinitely unless revoked or unused for 1 year
- **Missing email error:** "email_not_found" indicates GitHub App without proper email permissions configuration
- **Base path updates:** If auth routes' base path changes, update redirect URL accordingly

### https://www.better-auth.com/docs/concepts/hooks
# Better Auth Hooks - Quick Reference

## Core Components

- **Before Hooks**: Execute before endpoint runs; modify requests, validate data, or return early
- **After Hooks**: Execute after endpoint runs; modify responses or trigger side effects
- **createAuthMiddleware**: Wrapper function that provides context object (`ctx`) to hooks
- **APIError**: Custom error class for throwing errors with specific HTTP status codes

## Key Patterns

**1. Request Validation**
```ts
if (!ctx.body?.email.endsWith("@example.com")) {
    throw new APIError("BAD_REQUEST", { message: "Invalid email" });
}
```

**2. Modify Context Before Processing**
Return modified context to alter request data before endpoint execution

**3. Post-Action Side Effects**
Access `ctx.context.newSession` in after hooks to trigger notifications or logging

## Critical Context Properties

- `ctx.path`: Current endpoint path
- `ctx.body`: Parsed POST request body
- `ctx.headers`, `ctx.query`: Request metadata
- `ctx.context.newSession`: Available only in after hooks (new session object)
- `ctx.context.secret`, `ctx.context.password`: Auth utilities
- `ctx.context.authCookies`: Cookie configuration

## Best Practices

- **Prefer hooks over external endpoints** for custom behavior modifications
- Use `ctx.json()`, `ctx.redirect()` for responses; throw `APIError` for failures
- Access `ctx.context.adapter` or `ctx.context.internalAdapter` for DB operations
- Cookie methods: `setCookies()`, `setSignedCookie()`, `getCookies()`, `getSignedCookie()`
- Reuse logic across endpoints via plugins rather than duplicating hooks

### https://www.better-auth.com/docs
# Better Auth - Skill Reference

## Core Features
- **Universal Authentication Framework**: TypeScript-based, framework-agnostic auth system
- **Built-in Capabilities**: 2FA, passkeys, multi-tenancy, multi-session support, SSO, custom IDP creation
- **Plugin Ecosystem**: Extensible architecture for advanced functionalities
- **AI Tooling**: LLMs.txt exposure and MCP server support

## Key Usage Patterns

1. **Framework Integration**: "framework-agnostic, universal authentication and authorization framework for TypeScript"
2. **Feature Extension**: Leverage plugins to add enterprise features without building from scratch
3. **AI Model Integration**: Expose authentication system via LLMs.txt at `https://better-auth.com/llms.txt` or use MCP server

## Important Practices

- Use CLI commands for quick MCP setup: `npx @better-auth/cli mcp --[client-name]`
- Supports multiple MCP clients (Cursor, Claude Code, Open Code) with both automated and manual configuration
- First-party MCP powered by Chonkie; alternative providers like context7 available
- Configuration varies by client (bash commands vs. JSON files)
- Manual MCP setup requires endpoint URL: `https://mcp.chonkie.ai/better-auth/better-auth-builder/mcp`

### https://www.better-auth.com/docs/concepts/api
# Better Auth API Reference

## Core Components
- **`auth` instance**: Main Better Auth object with an `api` property exposing all endpoints
- **`api` object**: Provides access to every endpoint from core and plugins as callable functions
- **`APIError`**: Exception class thrown when API calls fail on the server

## Key Usage Patterns

**Server-side endpoint calls:**
```ts
await auth.api.getSession({ headers: await headers() })
await auth.api.signInEmail({
  body: { email: "user@example.com", password: "pass" },
  headers: await headers()
})
```

**Accessing response metadata:**
```ts
const { headers, response } = await auth.api.signUpEmail({
  returnHeaders: true,
  body: { email, password, name }
});
const cookies = headers.get("set-cookie");
```

**Error handling:**
```ts
try {
  await auth.api.signInEmail({ body: { email, password } })
} catch (error) {
  if (error instanceof APIError) {
    console.log(error.message, error.status)
  }
}
```

## Best Practices & Gotchas
- Pass request context via `headers` parameter for IP/user-agent data
- Use `returnHeaders: true` or `asResponse: true` to retrieve HTTP metadata
- Parameters must be wrapped in `body`, `headers`, or `query` keys on server
- API endpoints function as regular JS functions when called server-side (no HTTP overhead)
- Built on "better-call" framework for type-safe client inference

### https://www.better-auth.com/docs/plugins/open-api
# Better Auth - Open API Plugin Reference

## Core API/Components

- **openAPI()** - Plugin that generates OpenAPI 3.0 documentation for all Better Auth endpoints and plugins
- **auth.api.generateOpenAPISchema()** - Returns generated OpenAPI schema as JSON object
- **Scalar** - Library used to display interactive OpenAPI reference with testing capabilities

## Key Usage Patterns

1. **Basic Installation**: Import and add `openAPI()` to the plugins array in your auth config
2. **Access Documentation**: Navigate to `/api/auth/reference` to view endpoints grouped by plugin or core
3. **Integrate with Existing API Docs**: Add Better Auth schema via `sources` array in Scalar configuration alongside main API endpoints

## Best Practices & Gotchas

- ⚠️ Plugin is "still in the early stages of development" with ongoing feature additions
- Endpoints are automatically grouped: plugins by name, core endpoints under "Default", schemas under "Models"
- Customize the reference path via `path` config option (default: `/api/auth/reference`)
- Use `nonce` parameter for Content Security Policy compliance on inline scripts
- Set `disableDefaultReference: true` to hide the built-in UI when using external documentation tools

### https://www.better-auth.com/docs/basic-usage
# Better Auth - Quick Reference

## Core API/Components

| Component | Purpose |
|-----------|---------|
| `betterAuth()` | Server-side auth instance configuration |
| `createAuthClient()` | Client-side auth client initialization |
| `authClient.signUp.email()` | Register user with email/password |
| `authClient.signIn.email()` | Authenticate user with credentials |
| `authClient.signIn.social()` | OAuth sign-in via social providers |
| `authClient.signOut()` | Terminate user session |
| `authClient.useSession()` | Hook to access session data (reactive) |
| `authClient.getSession()` | Fetch current session data |
| `auth.api.getSession()` | Server-side session retrieval |
| `auth.api.signInEmail()` | Server-side email authentication |

## Key Patterns

**1. Enable Email/Password Auth:**
```ts
export const auth = betterAuth({
    emailAndPassword: { enabled: true }
})
```

**2. Social Provider Setup:**
```ts
export const auth = betterAuth({
    socialProviders: {
        github: { clientId: process.env.GITHUB_CLIENT_ID! }
    }
})
```

**3. Plugin Integration (2FA Example):**
```ts
// Server
plugins: [twoFactor()]

// Client
plugins: [twoFactorClient({ twoFactorPage: "/two-factor" })]
```

## Best Practices & Gotchas

- **Client-only methods:** "Always invoke client methods from the client side. Don't call them from the server"
- **Auto sign-in control:** Set `autoSignIn: false` to prevent automatic sign-in after signup
- **Password minimum:** Default minimum is 8 characters
- **Session persistence:** `rememberMe: false` prevents session persistence across browser closes
- **Framework integrations:** Use framework-specific plugins (e.g., Next.js) for automatic cookie handling on server actions

### https://www.better-auth.com/docs/plugins/api-key
# Better Auth - API Key Plugin Reference

## Core Components

**`apiKey()`** - Server-side plugin enabling creation, management, and verification of API keys with rate limiting and expiration controls.

**`apiKeyClient()`** - Client-side plugin providing methods to interact with API key endpoints.

**Key Methods:**
- `create()` - Generate new API key with optional expiration, rate limits, and metadata
- `verify()` - Validate API key and check permissions
- `get()` - Retrieve key details (excludes key value itself)
- `update()` - Modify key settings, permissions, refill amounts
- `delete()` - Remove specific API key
- `list()` - Fetch all user's API keys
- `deleteAllExpiredApiKeys()` - Clean up expired keys

## Key Usage Patterns

```ts
// Server setup
export const auth = betterAuth({
  plugins: [apiKey({ enableSessionForAPIKeys: true })]
});

// Create API key
const key = await auth.api.createApiKey({
  body: { name: "prod-key", expiresIn: 2592000, userId: "user-123" }
});

// Verify API key with permissions
const result = await auth.api.verifyApiKey({
  body: { key: apiKeyValue, permissions: { files: ["read"] } }
});
```

## Important Gotchas & Best Practices

- **Double Rate-Limit Increment**: Avoid calling both `verifyApiKey()` and `getSession()` separately; use `enableSessionForAPIKeys: true` instead
- **Key Security**: Hashing enabled by default; "never disable hashing" as plaintext storage risks database breaches
- **Returned Data**: Key creation returns the `key` value once; subsequent retrievals omit it for security
- **Header Configuration**: Default header is `x-api-key`; customize via `apiKeyHeaders` option or `apiKeyGetter` function
- **Rate Limit Behavior**: Uses sliding window; resets when time since last request exceeds `timeWindow`

### https://www.better-auth.com/docs/reference/options
# Better Auth - Skill Reference

## Core Components

- **betterAuth()** - Main configuration function for authentication setup
- **appName** - Application identifier for auth system
- **baseURL/basePath** - Server routing configuration (default: `/api/auth`)
- **secret** - Encryption/signing key (env: `BETTER_AUTH_SECRET` or `AUTH_SECRET`)
- **database** - Primary data store (PostgreSQL, MySQL, SQLite)
- **secondaryStorage** - Session and rate limit cache layer
- **socialProviders** - OAuth integrations (Google, GitHub, etc.)
- **plugins** - Extensibility system (emailOTP, etc.)

## Key Patterns

**1. Basic Setup**
```ts
import { betterAuth } from "better-auth";
export const auth = betterAuth({
  appName: "MyApp",
  baseURL: "https://example.com",
  secret: "your-secret-key",
  database: { dialect: "postgres" }
})
```

**2. Email & Password Auth**
```ts
emailAndPassword: {
  enabled: true,
  minPasswordLength: 8,
  requireEmailVerification: true,
  autoSignIn: true
}
```

**3. Dynamic Trusted Origins**
```ts
trustedOrigins: async (request) => ["https://dynamic-origin.com"]
// Or use wildcards: "https://*.example.com"
```

## Best Practices

- Always provide `secret` explicitly or via environment variables in production
- Use `trustedOrigins` to prevent CSRF attacks; "⚠️ security risk" if disabled
- Generate secrets with: `openssl rand -base64 32`
- Enable `useSecureCookies: true` for production deployments
- Leverage `databaseHooks` for before/after lifecycle events (user creation, updates)
- Include protocol prefix when using wildcard patterns in origins

### https://www.better-auth.com/docs/installation
# Better Auth - Skill Reference

## Core API/Components

- **`betterAuth()`** – Factory function to initialize authentication with database, methods, and providers
- **`createAuthClient()`** – Client-side library for interacting with auth server (framework-specific variants: react, vue, svelte, solid, vanilla)
- **`auth.handler`** – Request handler for mounting API routes; accepts standard Request/Response objects
- **Database Adapters** – Built-in support for SQLite, PostgreSQL, MySQL, Drizzle, Prisma, MongoDB
- **Authentication Methods** – emailAndPassword, socialProviders (GitHub, etc.), passkey, magic link, username plugins

## Key Patterns & Usage Examples

1. **Server Setup**: Create `auth.ts` exporting betterAuth instance with database and authentication config
2. **API Route Mounting**: Use framework-specific handler (e.g., `toNextJsHandler(auth)` for Next.js App Router)
3. **Client Integration**: Import `createAuthClient` from framework package, pass optional `baseURL`, export for use in components

## Important Gotchas & Best Practices

- **Secret Key**: Must be ≥32 characters, high entropy; use `openssl rand -base64 32` or built-in generator
- **Environment Variables**: Set `BETTER_AUTH_SECRET` and `BETTER_AUTH_URL` in `.env`
- **Database Required**: Most plugins require a database; stateless mode available but limited
- **CLI for Schema**: Use `npx @better-auth/cli generate` (ORM schema) or `migrate` (direct application)
- **Client/Server Separation**: Install package in both client and server if architecturally separated

### https://www.better-auth.com/docs/concepts/client
# Better Auth Client - Skill Reference

## Core API/Components

- **`createAuthClient()`** - Initializes auth client for your framework (React, Vue, Svelte, Solid, Vanilla)
- **`signIn.email()`** - Email/password authentication method
- **`signIn.social()`** - Social provider authentication (e.g., GitHub)
- **`signOut()`** - Terminates user session
- **`useSession()`** - Hook for reactive session data access
- **`updateUser()`** - Modifies user profile information

## Key Patterns

1. **Client Setup**: Import framework-specific client, pass `baseURL` if server differs from client domain
2. **Session Management**: Use `useSession()` hook returning `{ data, isPending, error, refetch }`
3. **Error Handling**: Check `error` property in responses; leverage `$ERROR_CODES` for translations

## Best Practices

- Pass complete URL with custom paths (e.g., `http://localhost:3000/custom-path/auth`)
- Use `disableSignal: true` when updates shouldn't trigger hook rerenders
- Provide `onError` callbacks or check returned error objects for robust error handling
- Extend functionality via plugins (e.g., `magicLinkClient()`) rather than modifying core
- Access error codes from `authClient.$ERROR_CODES` to build localized error messages

### https://www.better-auth.com/docs/introduction
# Better Auth - Skill Reference

## Core Features
- **2FA/MFA Support** — Two-factor authentication capabilities
- **Passkey Authentication** — Passwordless authentication via passkeys
- **Multi-tenancy** — Support for multiple isolated tenants
- **Multi-session Management** — Handle concurrent user sessions
- **SSO Integration** — Single sign-on enterprise features
- **Custom IDP Creation** — Build your own identity provider
- **Plugin Ecosystem** — Extensible architecture for custom functionality

## Key Patterns

1. **Framework-agnostic setup** — "Better Auth is a framework-agnostic, universal authentication and authorization framework for TypeScript"
2. **Out-of-box functionality** — Covers common auth scenarios without reinventing components
3. **AI integration** — Leverage LLMs.txt and MCP server for AI model integration

## Best Practices

- Use the MCP server for seamless AI tooling integration via Model Context Protocol
- Access LLMs.txt endpoint (`/llms.txt`) to help AI systems understand your auth implementation
- Leverage plugins to add advanced features rather than building from scratch
- Configure MCP manually or via CLI for your preferred AI editor (Cursor, Claude Code, Open Code)
- Extends beyond basic auth—covers enterprise SSO and custom identity provider scenarios

### https://www.better-auth.com/docs/authentication/github
# better-auth GitHub Provider Reference

## Core API/Components

- **`betterAuth()`** - Main auth instance factory that accepts `socialProviders` configuration
- **`signIn.social()`** - Client function for initiating social authentication with specified provider
- **`createAuthClient()`** - Factory to instantiate the authentication client

## Key Patterns

1. **Provider Configuration**
   ```ts
   betterAuth({
     socialProviders: {
       github: { clientId, clientSecret }
     }
   })
   ```

2. **Client-Side Sign-In**
   ```ts
   authClient.signIn.social({ provider: "github" })
   ```

3. **Redirect URL Setup** - Local: `http://localhost:3000/api/auth/callback/github`; production uses application URL

## Best Practices & Gotchas

- **Required Scope**: "Must include the `user:email` scope in your GitHub app" or face "email_not_found" errors
- **No Refresh Tokens**: GitHub OAuth access tokens persist indefinitely unless revoked or unused for 12 months
- **GitHub Apps Permission**: For app-type OAuth, enable "Email Addresses" read-only under Permissions & Events
- **Redirect Configuration**: Update redirect URL if changing base auth route path
- **Token Expiration**: Unlike Google/Discord, GitHub tokens don't expire on short intervals

### https://www.better-auth.com/docs/concepts/hooks
# Better Auth Hooks - Skill Reference

## Core API/Components

- **`betterAuth()`** - Main configuration function that accepts hooks configuration
- **`createAuthMiddleware()`** - Wrapper for defining hook logic with context access
- **`APIError`** - Error class for throwing HTTP errors with status codes
- **Before Hooks** - Execute prior to endpoint execution; modify requests or validate
- **After Hooks** - Execute after endpoint execution; modify responses
- **`ctx` object** - Middleware context providing path, body, headers, query, and auth context

## Key Patterns & Usage Examples

1. **Input Validation**: Check `ctx.path` and `ctx.body` to enforce business rules before processing
   ```ts
   if (!ctx.body?.email.endsWith("@example.com")) {
       throw new APIError("BAD_REQUEST", { message: "Invalid email" });
   }
   ```

2. **Response Modification**: Use after hooks with `ctx.context.newSession` for post-signup actions
   ```ts
   if (ctx.context.newSession) {
       sendNotification({ name: newSession.user.name });
   }
   ```

3. **Cookie & Context Management**: Access and modify cookies via `ctx.setCookies()`, `ctx.getCookies()`, and auth config through `ctx.context`

## Best Practices

- ✓ Use hooks for custom adjustments instead of building separate endpoints outside Better Auth
- ✓ Leverage `ctx.context.adapter` and internal adapter methods for database operations
- ✓ Access `ctx.context.password` for secure hashing/verification rather than custom crypto
- ✓ Consider building a plugin for reusable hooks across multiple endpoints
- ✓ Return modified context object from before hooks to persist changes through request lifecycle

### https://www.better-auth.com/docs/concepts/api\n-
Request failed with status code 404

### https://www.better-auth.com/docs/plugins/open-api\n-
Request failed with status code 404

### https://www.better-auth.com/docs/plugins/api-key\n-
Request failed with status code 404

### https://www.better-auth.com/docs/reference/options\n-
Request failed with status code 404
