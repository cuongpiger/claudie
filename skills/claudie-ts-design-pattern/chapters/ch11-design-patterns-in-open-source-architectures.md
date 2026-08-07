# Chapter 11: Exploring Design Patterns in Open Source Architectures

## Core Idea
Patterns in real codebases are rarely labelled. This chapter teaches a repeatable method
for *finding* them — documentation, folder structure, naming, imports, tests — then walks
Apollo Client and tRPC as worked examples.

## Frameworks Introduced

- **A five-step method for reviewing patterns in any open source project**:
  1. **Start with the documentation** — architecture overviews, **ADRs** (architectural
     decision records, often committed to version control), API references, CONTRIBUTING
     guides, READMEs, GitHub wikis and discussions.
  2. **Analyze the project structure** — directory organization reveals the pattern
     (MVC, feature-based, layer-based). Consistent naming is a direct signal:
     `CarFactory.ts` announces a Factory Method.
  3. **Look for the common implementations** — creational (Factory Method, Singleton,
     Builder), structural (Adapter, Decorator, Façade), behavioral (Observer, Strategy,
     Command). These are the easiest to spot.
  4. **Analyze dependencies and imports** — do classes accept *interfaces* as
     parameters? Is there a DI framework (Inversify.js)? Are related modules bundled as
     `utils`/`common`?
  5. **Study the test cases** — unit tests reveal expected component behavior,
     integration tests reveal intended composition, and **mock objects identify the key
     abstractions and interfaces** in the system.

- **Monorepo vs. multi-repo** — the structural trade-off:
  - **Monorepo**: easier code sharing, unified versioning, consistent tooling. Best with
    highly interdependent projects and frequent cross-project changes. Becomes unwieldy
    as the codebase grows; operations slow, especially with build errors.
  - **Multi-repo**: clearer boundaries, granular access control, per-project tooling.
    Costs complexity in dependency management and cross-project consistency.

- **Six project-structure guidelines** the chapter derives from Apollo Client:
  - **Scope and scale** — single package for simple projects; graduate to monorepo or
    multi-repo as complexity grows.
  - **Testing strategy** — unit tests alongside source files; a dedicated
    `integration-tests/` or `e2e-tests/` folder for complex scenarios.
  - **`scripts/`** — custom build, maintenance, and developer-productivity tools.
  - **`docs/` in the main repo** — keeps documentation versioned alongside code.
  - **Consistent file naming** — e.g. `.component.tsx` for React components, `.util.ts`
    for utilities. Significantly improves searchability as the project scales.
  - **`patches/`** — temporary dependency fixes, but contribute them upstream when
    possible.

## Key Concepts

- **Apollo Client** — a GraphQL client with built-in state management and normalized
  in-memory caching. Choose it for GraphQL backends, complex SPAs needing caching
  control, non-TypeScript projects, and its large ecosystem.
- **Apollo's four cache strategies** — `Cache-First` (check cache before the network),
  `Network-Only` (always fresh, higher latency), `Cache-and-Network` (return cached
  immediately, refresh in background), `No Cache` (disabled).
- **tRPC** — a TypeScript-first RPC framework for end-to-end typesafe APIs. Not a
  GraphQL replacement — a different approach that leans entirely on TypeScript's type
  system. Choose it for full-stack TypeScript, monorepos, and rapid prototyping with
  minimal boilerplate.
- **`ObservableQuery` / `QueryManager`** — Apollo's Observer machinery; `watchQuery`
  returns an `ObservableQuery` that subscribers receive cache updates through.
- **`ApolloLink`** — a composable network-layer element; each link can intercept,
  modify, or delay requests and responses independently.
- **`behaviorSubject`** — tRPC's Observable primitive for connection state
  (connecting/connected/error), letting clients update UI reactively.
- **`createRecursiveProxy`** — tRPC's Proxy implementation, capturing an arbitrary
  method path and arguments without predefining any methods.

## Mental Models

- **Read the folder names before the code.** Directory organization and file naming carry
  more architectural information per second of reading than any single source file.
- **Mocks mark the seams.** Wherever a project mocks something, that's an abstraction the
  authors considered a real boundary — and usually a pattern's interface.
- **Pick an entry-point file, not the whole repo.** The chapter deliberately reviews only
  `src/core/ApolloClient.ts` out of a large project. One well-chosen file surfaces most
  of the architecture.
- **tRPC vs. Apollo Client is a type-safety vs. ecosystem trade.** tRPC enforces type
  safety end to end; Apollo Client supports TypeScript but doesn't enforce it as
  diligently in its core API — and brings caching strategies and a larger community.
- **Naming quality is a project-health signal.** The chapter notes tRPC's source is "a
  bit more organized with better naming conventions" than Apollo's, and uses that as a
  reason it's easier to identify patterns in.

## Anti-patterns

- **Assuming patterns are documented**: they usually aren't. You have to recognize them
  from structure and naming.
- **Unmaintained auxiliary folders**: `docs/` and `scripts/` in the main repo go stale or
  unused if not actively maintained, and the extra directories make the project harder
  for newcomers to navigate.
- **Complex, fragile builds**: managing docs, tests, and scripts inside the build process
  makes it more complex and more fragile.
- **Monorepo by default**: it slows down as the codebase grows, particularly around build
  errors. Match the structure to project scale.
- **Permanent `patches/`**: dependency patches are meant to be temporary — upstream them.
- **Never revisiting structure**: regularly review and refactor project structure as it
  evolves; the right shape changes with team size and goals.

## Code Examples

Apollo Client setup and a typed query:

```typescript
import { ApolloClient, InMemoryCache, gql } from "@apollo/client/core"

const client = new ApolloClient({
  uri: "https://countries.trevorblades.com/",
  cache: new InMemoryCache(),          // normalized in-memory cache
})

type Country = { name: string; capital: string; currency: string }

client
  .query<Country>({
    query: gql`
      query { country(code: "IE") { name capital currency } }
    `,
  })
  .then((result) => {
    if (result.data && result.data.country) {   // type guard on the response shape
      console.log(result.data.country.name)
    } else {
      throw new Error("Unexpected API response structure")
    }
  })
  .catch((error) => console.error("Error fetching country data:", error))
```

Apollo's **Strategy** pattern — `fetchPolicy` selecting the fetch algorithm:

```typescript
if (
  this.disableNetworkFetches &&
  (options.fetchPolicy === "network-only" || options.fetchPolicy === "cache-and-network")
) {
  options = { ...options, fetchPolicy: "cache-first" }   // swap strategy at runtime
}
return this.queryManager.watchQuery<T, TVariables>(options)
```

Apollo's **Composite** pattern — `ApolloLink.from` folding many links into one:

```typescript
// src/link/core/ApolloLink.ts
public static from(links: (ApolloLink | RequestHandler)[]): ApolloLink {
  if (links.length === 0) return ApolloLink.empty()
  return links.map(toLink).reduce((x, y) => x.concat(y)) as ApolloLink
}

// usage — each link is independently replaceable
const link = ApolloLink.from([errorLink, authLink, httpLink])
const client = new ApolloClient({ link, cache: new InMemoryCache() })
```

Apollo's **Observer** pattern — `watchQuery` returning a subscribable:

```typescript
public watchQuery<T = any, TVariables extends OperationVariables = OperationVariables>(
  options: WatchQueryOptions<TVariables, T>,
): ObservableQuery<T, TVariables> { /* ... */ }
```

tRPC server + client, end-to-end typed:

```typescript
// server.ts
import { initTRPC } from "@trpc/server"
import { createHTTPServer } from "@trpc/server/adapters/standalone"

const t = initTRPC.create()

const appRouter = t.router({
  hello: t.procedure
    .input((val: unknown) => {
      if (typeof val === "string") return val
      throw new Error("Invalid input: expected string")
    })
    .query((req) => `Hello, ${req.input}!`),
})

createHTTPServer({ router: appRouter }).listen(3000)
export type AppRouter = typeof appRouter     // the ONLY thing the client imports
```

```typescript
// client.ts — Factory Method (createTRPCClient) + the server's type as a generic
import { createTRPCClient, httpBatchLink } from "@trpc/client"
import type { AppRouter } from "./server"

const trpc = createTRPCClient<AppRouter>({
  links: [httpBatchLink({ url: "http://localhost:3000" })],
})

const response = await trpc.hello.query("tRPC User")   // fully type-safe
```

tRPC's **Adapter** pattern — one adapter per host framework:

```typescript
import { createNextApiHandler } from "@trpc/server/adapters/next"
import { createContext } from "../../../server/trpc/context"
import { appRouter } from "../../../server/trpc/router/_app"

export default createNextApiHandler({ router: appRouter, createContext })
// Equivalent adapters exist for Express.js, Fastify, and node-http.
```

tRPC's **Observable** pattern — connection state as a `behaviorSubject`:

```typescript
const connectionState = behaviorSubject<TRPCConnectionState<TRPCClientError<any>>>({
  type: "state",
  state: "connecting",
  error: null,
})

const connectionSub = connectionState.subscribe({
  next(state) { observer.next({ result: state }) },
})
```

## Reference Tables

Patterns observed, by project:

| Project | Pattern | Where / how |
|---|---|---|
| Apollo Client | Observer | `ObservableQuery`, `QueryManager`; `watchQuery` returns a subscribable |
| Apollo Client | Strategy | `fetchPolicy`: cache-first / network-only / cache-and-network / no-cache |
| Apollo Client | Composite | `ApolloLink.from()`, `concat`, `split` chain links into one |
| Apollo Client | Factory | network link creation |
| Apollo Client | Memento | cache `extract()` / `restore()` — SSR state rehydration |
| tRPC | Observable | `server/src/observable`; `behaviorSubject` for connection state |
| tRPC | Adapter | `server/src/adapters` — Next.js, Express, Fastify, node-http |
| tRPC | Proxy | `createRecursiveProxy` for dynamic procedure resolution |
| tRPC | Factory Method | `createTRPCClient<AppRouter>` |

Project structures compared:

| | Apollo Client | tRPC |
|---|---|---|
| Layout | single package, centralized | monorepo, `packages/` |
| Key dirs | `src/{cache,core,link,react,utilities}`, `config`, `docs`, `integration-tests`, `patches`, `scripts`, `eslint-local-rules` | `packages/{client,next,react-query,server,tests}`, `www`, `examples`, `scripts` |
| Type safety | supports TypeScript | enforces it end to end |
| Separation | more centralized | clear per-package concerns |

Apollo cache strategies:

| Strategy | Behavior | Trade-off |
|---|---|---|
| Cache-First | check cache, fetch only if absent | may serve stale data |
| Network-Only | always fetch | freshest, higher latency |
| Cache-and-Network | return cache now, refresh in background | fast *and* fresh; two renders |
| No Cache | caching disabled | always fresh, no reuse |

Choosing between the two:

| Choose | When |
|---|---|
| tRPC | full-stack TypeScript, monorepo, rapid prototyping, minimal boilerplate |
| Apollo Client | GraphQL backend, non-TypeScript project, complex SPA caching needs, want a large ecosystem and rich docs |

## Worked Example

**tRPC's `createRecursiveProxy`** — the Proxy pattern doing something that genuinely
looks impossible:

```typescript
// server/src/unstable-core-do-not-import/createProxy.ts
return createRecursiveProxy<ReturnType<RouterCaller<any, any>>>(
  async ({ path, args }) => {
    const fullPath = path.join(".")
    // resolve the procedure at fullPath and execute it
  }
)
```

What it buys you, demonstrated:

```typescript
const basic = createRecursiveProxy((opts) => opts)   // just echo what was captured

basic.foo.bar.query()
// { path: ['foo', 'bar', 'query'], args: [] }

basic.foo.bar.query({ id: 1 })
// { path: ['foo', 'bar', 'query'], args: [{ id: 1 }] }

basic.foo.bar.mutate()
// { path: ['foo', 'bar', 'mutate'], args: [] }
```

**Why this matters.** None of `foo`, `bar`, `query`, or `mutate` are defined anywhere.
The proxy intercepts every property access, accumulates the path, and only resolves when
finally *called* — capturing both the path and the arguments. That's how
`trpc.hello.query('tRPC User')` on the client can look like a plain method call while
actually being an HTTP request to a procedure the client never imported.

The Proxy pattern's role here matches its Ch 4 definition exactly: **control access to an
object**, with the surrogate adding input validation, error handling, and context
management around each call — without the router's core logic knowing a proxy exists.
Combined with `createTRPCClient<AppRouter>` (Factory Method) and the `AppRouter` type
import, this is what produces the framework's headline property: a client with full
autocomplete and type checking against a server it shares no runtime code with.

## Key Takeaways

1. Read documentation, ADRs, folder structure, and naming *before* source code — they
   carry the architecture most cheaply.
2. Mock objects in a test suite mark the system's real abstraction boundaries.
3. Pick one entry-point file (`src/core/ApolloClient.ts`) rather than trying to read a
   whole repository.
4. Consistent file naming (`.component.tsx`, `.util.ts`) pays off measurably as a project
   scales — it's a searchability decision, not a style one.
5. Keep `docs/` in the main repo so documentation versions with the code, and treat
   `patches/` as temporary.
6. Choose monorepo vs. multi-repo by interdependence and change frequency, and revisit
   the choice as the project grows.
7. Real projects combine patterns freely: Apollo layers Observer + Strategy + Composite +
   Memento in one client; tRPC layers Proxy + Adapter + Observable + Factory Method.
8. Next steps the author recommends: study the Redux ecosystem for state-management
   strategies complementing Proxy and Observer, and advanced pattern use in reactive
   architectures.

## Connects To

- **Ch 3**: Factory Method — `createTRPCClient`, Apollo's link creation.
- **Ch 4**: Adapter (tRPC framework adapters), Composite (`ApolloLink.from`), Proxy
  (`createRecursiveProxy`).
- **Ch 5**: Observer and Strategy — Apollo's `ObservableQuery` and `fetchPolicy`.
- **Ch 6**: Memento — Apollo's cache `extract()`/`restore()` for SSR rehydration.
- **Ch 8**: Observables — tRPC's `behaviorSubject` and Apollo's subscription model.
- **Ch 9**: monorepo/structure decisions and combining patterns effectively.
- **Ch 10**: how both projects avoid the anti-patterns — generics over `any`,
  composition over inheritance, `async`/`await` over error tuples.
