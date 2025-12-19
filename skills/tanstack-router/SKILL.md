---
name: tanstack-router
description: Use when building React applications with routing, creating type-safe navigation, handling URL search parameters, implementing nested layouts, or setting up file-based routing. Triggers include route creation, Link components, useNavigate, path params, search params, code splitting, and router configuration.
---

# TanStack Router

Type-safe routing library for React with first-class TypeScript support, file-based routing, built-in data loading, and JSON-first search parameters.

## Quick Reference

| Task | Code |
|------|------|
| Create router | `createRouter({ routeTree, defaultPreload: 'intent' })` |
| Navigate | `<Link to="/posts/$postId" params={{ postId: '123' }}>` |
| Get params | `const { postId } = Route.useParams()` |
| Get search params | `const { page } = Route.useSearch()` |
| Imperative navigate | `navigate({ to: '/posts', search: { page: 1 } })` |
| Outlet for children | `<Outlet />` |

## Installation

```sh
npm install @tanstack/react-router
# Devtools (optional)
npm install @tanstack/react-router-devtools
```

**CLI scaffolding (fastest):**
```sh
npx create-tsrouter-app@latest my-app --template file-router
```

## Router Setup

### Creating the Router

```tsx
import { createRouter, RouterProvider } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen' // file-based

const router = createRouter({
  routeTree,
  defaultPreload: 'intent',
  scrollRestoration: true,
})

// CRITICAL: Register router for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

// Render
ReactDOM.createRoot(rootElement).render(
  <RouterProvider router={router} />
)
```

### Root Route with Layout

```tsx
import { createRootRoute, Outlet, Link } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => (
    <div>
      <nav>
        <Link to="/" className="[&.active]:font-bold">Home</Link>
        <Link to="/about">About</Link>
      </nav>
      <Outlet />
    </div>
  ),
  notFoundComponent: () => <div>404 Not Found</div>,
})
```

## File-Based Routing

### File Structure

```
src/routes/
├── __root.tsx          # Root layout
├── index.tsx           # / route
├── about.tsx           # /about route
├── posts.tsx           # /posts layout
├── posts.index.tsx     # /posts (index)
└── posts.$postId.tsx   # /posts/:postId
```

### Route File Pattern

```tsx
// src/routes/posts.$postId.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    return fetchPost(params.postId)
  },
  component: PostComponent,
})

function PostComponent() {
  const post = Route.useLoaderData()
  const { postId } = Route.useParams()
  return <div>{post.title}</div>
}
```

### Configuration (vite.config.ts)

```typescript
import { tanstackRouter } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouter({
      autoCodeSplitting: true, // Automatic code splitting
    }),
    react(),
  ],
})
```

## Navigation

### Link Component

```tsx
// Basic
<Link to="/about">About</Link>

// With path params
<Link to="/posts/$postId" params={{ postId: '123' }}>View Post</Link>

// With search params
<Link to="/posts" search={{ page: 2, filter: 'recent' }}>Page 2</Link>

// Update search params (functional)
<Link search={(prev) => ({ ...prev, page: prev.page + 1 })}>Next</Link>

// Active styling
<Link to="/posts" className="[&.active]:font-bold">Posts</Link>
```

### Imperative Navigation

```tsx
import { useNavigate } from '@tanstack/react-router'

function Component() {
  const navigate = useNavigate()
  
  const handleClick = () => {
    navigate({ 
      to: '/posts/$postId', 
      params: { postId: '123' },
      search: { tab: 'comments' },
      replace: true, // Replace history entry
    })
  }
}
```

### Navigate Component

```tsx
import { Navigate } from '@tanstack/react-router'

// Redirect on render
<Navigate to="/login" />
```

## Path Parameters

### Basic Params

```tsx
// Route: /posts/$postId
export const Route = createFileRoute('/posts/$postId')({
  component: () => {
    const { postId } = Route.useParams()
    return <div>Post: {postId}</div>
  },
})
```

### Prefixed/Suffixed Params

```tsx
// post-{$postId} matches /posts/post-123
export const Route = createFileRoute('/posts/post-{$postId}')({
  component: () => {
    const { postId } = Route.useParams() // "123"
  },
})
```

### Optional Parameters

```tsx
// {-$category} matches /posts and /posts/tech
export const Route = createFileRoute('/posts/{-$category}')({
  component: () => {
    const { category } = Route.useParams() // string | undefined
  },
})
```

## Search Parameters

TanStack Router treats search params as JSON-first structured data.

### Validation with Zod

```tsx
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const searchSchema = z.object({
  page: z.number().default(1),
  filter: z.string().default(''),
  sort: z.enum(['newest', 'oldest', 'price']).default('newest'),
})

export const Route = createFileRoute('/shop/products')({
  validateSearch: zodValidator(searchSchema),
  component: ProductList,
})

function ProductList() {
  const { page, filter, sort } = Route.useSearch()
  // All typed and validated!
}
```

### Reading Search Params

```tsx
// In route component
const search = Route.useSearch()

// Outside route (less type-safe)
import { useSearch } from '@tanstack/react-router'
const search = useSearch({ strict: false })
```

### Writing Search Params

```tsx
// Via Link
<Link search={{ page: 2 }}>Page 2</Link>
<Link search={(prev) => ({ ...prev, page: prev.page + 1 })}>Next</Link>

// Via navigate
navigate({ search: (prev) => ({ ...prev, filter: 'active' }) })
```

## Data Loading

### Route Loader

```tsx
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const post = await fetchPost(params.postId)
    return post
  },
  component: PostComponent,
})

function PostComponent() {
  const post = Route.useLoaderData()
  return <h1>{post.title}</h1>
}
```

### Loader with Search Params

```tsx
export const Route = createFileRoute('/posts')({
  loaderDeps: ({ search }) => ({ page: search.page }),
  loader: async ({ deps }) => {
    return fetchPosts({ page: deps.page })
  },
})
```

## Code Splitting

### Automatic (Recommended)

Enable in vite.config.ts:
```typescript
tanstackRouter({
  autoCodeSplitting: true,
})
```

### Manual with .lazy.tsx

```tsx
// src/routes/posts.tsx (critical path)
export const Route = createFileRoute('/posts')({
  loader: fetchPosts,
})

// src/routes/posts.lazy.tsx (lazy-loaded)
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute('/posts')({
  component: Posts,
})
```

## Devtools

```tsx
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools'

export const Route = createRootRoute({
  component: () => (
    <>
      <Outlet />
      <TanStackRouterDevtools />
    </>
  ),
})
```

## Common Mistakes

### ❌ Missing Type Registration

```tsx
// WRONG: No type safety
const router = createRouter({ routeTree })

// CORRECT: Always register
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
```

### ❌ Exporting Route Properties (Breaks Code Splitting)

```tsx
// WRONG: Exports prevent code splitting
export const Route = createFileRoute('/posts')({
  component: Posts,
})
export { Posts } // DON'T DO THIS

// CORRECT: Only export Route
export const Route = createFileRoute('/posts')({
  component: Posts,
})
```

### ❌ Using String Search Params

```tsx
// WRONG: Manual parsing
const url = new URL(window.location.href)
const page = parseInt(url.searchParams.get('page') || '1')

// CORRECT: Use validated search params
const { page } = Route.useSearch()
```

### ❌ Forgetting Outlet in Parent Routes

```tsx
// WRONG: Children won't render
export const Route = createFileRoute('/posts')({
  component: () => <div>Posts Header</div>,
})

// CORRECT: Include Outlet
export const Route = createFileRoute('/posts')({
  component: () => (
    <div>
      <h1>Posts Header</h1>
      <Outlet />
    </div>
  ),
})
```

### ❌ Not Using loaderDeps for Search-Dependent Loaders

```tsx
// WRONG: Loader won't re-run when search changes
loader: async ({ search }) => fetchPosts(search.page)

// CORRECT: Declare dependencies
loaderDeps: ({ search }) => ({ page: search.page }),
loader: async ({ deps }) => fetchPosts(deps.page)
```

## File Naming Conventions

| Pattern | URL | Description |
|---------|-----|-------------|
| `index.tsx` | `/` | Index route |
| `about.tsx` | `/about` | Static route |
| `posts.$postId.tsx` | `/posts/:postId` | Dynamic param |
| `posts.route.tsx` | `/posts` | Layout route |
| `posts.lazy.tsx` | N/A | Lazy component |
| `-components/` | N/A | Ignored (co-location) |