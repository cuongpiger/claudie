# Chapter 8: Performance Patterns

## Core Idea

Performance patterns attack bottlenecks with proven, reusable strategies: cut execution time, cut memory, scale. All three patterns here are variations on one move — **don't do expensive work twice, and don't do it before you must**. Cache-Aside caches across process boundaries (database → Redis). Memoization caches inside the process (function results → RAM). Lazy Loading defers the work entirely until first access.

## Frameworks Introduced

- **Cache-Aside**: Data is read far more often than it's updated, and refetching it from the data store every time wastes latency and database capacity. Some systems cache automatically; when yours doesn't, you implement the strategy in application code yourself.
  - When to use: reduce database load (fewer queries for frequently accessed data); improve responsiveness (cached reads are faster). Works for data that doesn't change often, and for stores with no consistency requirement across a *set* of entries (multiple keys) — e.g. document stores where keys are never updated, entries are occasionally deleted, and there's no hard requirement to keep serving them until the cache refreshes.
  - How: two cases. **Case 1 (fetch)** — return item from cache if present; on miss, read from the database, put it in the cache, return it. **Case 2 (update)** — write the item to the database and *remove* the corresponding cache entry (invalidate, don't rewrite). Implemented with `redis.StrictRedis(host="localhost", port=6379, decode_responses=True)`, `cache.get(key)`, `cache.set(key, value, ex=60)`, and `sqlite3` for the store.
  - Why it works / failure mode: reads collapse onto an in-memory key-value store. Staleness is bounded by the TTL (`ex=60`) plus explicit invalidation on write. It breaks when entries must stay consistent with each other — cache-aside gives you per-key freshness, not set-level consistency.
  - Real-world example: Memcached (in-memory key-value store for small chunks from DB calls, API calls, or HTML fragments); Redis (the authors' go-to for caching and in-memory app storage); Amazon ElastiCache (managed distributed in-memory data store in the cloud).

- **Memoization**: Expensive function calls repeated with identical inputs recompute the same answer. Cache the result keyed on the arguments; the second call is free.
  - When to use: (1) **speeding up recursive algorithms** — collapses high time complexity, classic case being Fibonacci; (2) **reducing computational overhead** — conserves CPU in resource-constrained environments or high-volume data processing; (3) **improving perceived application performance** — apps feel more responsive.
  - How: `from functools import lru_cache`, then `@lru_cache(maxsize=None)` on the function. Results are stored in an in-memory cache; repeated calls with the same arguments fetch from the cache instead of executing the body.
  - Why it works / failure mode: `maxsize=None` means unbounded — the cache grows for every distinct argument tuple, so memory grows with input cardinality. Bound it (`maxsize=128`) when the argument space is large. Arguments must be hashable, and the function must be pure — memoizing something with side effects or time-varying results returns stale answers forever.
  - Real-world example: Fibonacci numbers (storing previously computed sequence values drastically speeds up higher `n`); text search in search engines / document analysis tools, where caching prior search results makes identical queries instant.

- **Lazy Loading**: Defer initialization or loading of a resource until the moment it's actually needed. Buys efficient resource use, lower initial load time, better UX.
  - When to use: (1) **reducing initial load time** — especially web, where shorter load time improves engagement and retention; (2) **conserving system resources** — uniform experience across high-end desktops down to entry-level phones; (3) **enhancing user experience** — minimize waiting, feel responsive.
  - How: two implementations. **Lazy attribute loading** — store `self._data = None` in `__init__`, expose a `@property data` that checks `if self._data is None:` and calls `self.load_data()` on first access only. **Via caching** — decorate the entry point with `@lru_cache(maxsize=128)` so the expensive initialization runs once on demand.
  - Why it works / failure mode: first access pays full cost (latency spike moved, not removed); subsequent accesses are free. The sentinel is `None`, so a legitimately-`None` result reloads every time. No invalidation path — once loaded, the value is frozen for the object's lifetime.
  - Real-world example: online art gallery loading only images currently in view, more as you scroll; Netflix/YouTube streaming video in chunks (minimal initial buffering, adapts to network conditions); Excel / Google Sheets loading only the sheet or cell range relevant to the current view.

## Key Concepts

- **Cache-aside is application-owned caching.** The app, not the store, decides what lands in the cache and when it's evicted.
- **Invalidate on write, don't update on write.** Case 2 deletes the key rather than rewriting it — the next read repopulates from the source of truth.
- **TTL is your staleness budget.** `ex=60` bounds how wrong the cache can be even if invalidation is missed.
- **Cache key namespacing.** `CACHE_KEY_PREFIX = "quote"` → keys are `quote.23`, avoiding collisions across entity types in one Redis instance.
- **`lru_cache` is inherently a memoization tool**, but it can be adapted for lazy loading — the difference is context, not mechanism: memoization optimizes repeated computation; lazy loading manages *resource initialization*.
- **Populate paths differ.** The demo separates `update_all` (write DB + warm the cache) from `update_db_only` (write DB, leave cache cold) so you can observe both hit and miss behavior.

## Mental Models

**Three caches, three scopes.** Cache-Aside = cross-process, survives restarts, network hop, TTL-bounded. Memoization = in-process, dies with the process, nanosecond lookup, memory-bounded. Lazy Loading = per-object (or per-callable), scoped to one instance's lifetime.

**Caching helps when** the read/write ratio is high, the computation or fetch is genuinely expensive, and the same inputs recur. **Caching hides a design problem when** you're caching to paper over an N+1 query, an unindexed column, or an algorithm with the wrong complexity. Fibonacci with `lru_cache` runs fast, but the honest fix is the iterative formulation — memoization rescues a *recursive shape you chose to keep*. Reach for the cache after the algorithm is right, not instead of fixing it.

**Cache-aside vs. write-through.** Cache-aside writes to the database and *deletes* the cache entry — the cache is lazily repopulated on the next read, so it only ever holds data someone asked for. (A write-through strategy would instead push the new value into the cache at write time.) Cache-aside trades one extra miss for a cache that never fills with data nobody reads.

**Lazy loading moves cost, it doesn't erase it.** You're trading a slow startup for a slow first access. That's a win only when many users never trigger the access at all.

## Anti-patterns

- **Caching mutable or set-consistent data with cache-aside.** The pattern is explicitly scoped to data that doesn't change often and stores with no cross-key consistency requirement.
- **Unbounded `lru_cache(maxsize=None)` over a wide argument space.** Fine for Fibonacci up to 30; a memory leak for user-supplied inputs. Use `maxsize=128` (as in the lazy-loading factorial example) when arguments aren't a small fixed set.
- **Memoizing impure functions.** Anything reading the clock, the filesystem, or a database returns a permanently stale answer once cached.
- **Skipping the update path.** The demo implements Case 1 (fetch) only; shipping cache-aside without Case 2's invalidation guarantees stale reads for the full TTL after every write.
- **Using global variables for caching** (see Ch. 11's Python-specific anti-patterns): a module-level `dict` you manage by hand has no eviction, no size bound, no TTL, and no thread-safety story. `functools.lru_cache` or a real cache server gives you all four.
- **Building a cache before measuring.** Every example here times the uncached path first for comparison — that ordering is the point.

## Code Examples

```python
def get_quote(quote_id: str) -> str:
    out = []
    quote = cache.get(f"{CACHE_KEY_PREFIX}.{quote_id}")
    if quote is None:
        # Get from the database
        query_fmt = "SELECT text FROM quotes WHERE id = {}"
        try:
            with sqlite3.connect(DB_PATH) as db:
                cursor = db.cursor()
                res = cursor.execute(query_fmt.format(quote_id)).fetchone()
                if not res:
                    return "There was no quote stored matching that id!"
                quote = res[0]
                out.append(f"Got '{quote}' FROM DB")
        except Exception as e:
            print(e)
            quote = ""
        # Add to the cache
        if quote:
            key = f"{CACHE_KEY_PREFIX}.{quote_id}"
            cache.set(key, quote, ex=60)
            out.append(f"Added TO CACHE, with key '{key}'")
    else:
        out.append(f"Got '{quote}' FROM CACHE")
    if out:
        return " - ".join(out)
    else:
        return ""
```
- **What it demonstrates**: Cache-Aside Case 1 end to end — cache miss falls through to SQLite, result written back to Redis with a 60s TTL under a namespaced key.

```python
def fibonacci_func1(n):
    if n < 2:
        return n
    return fibonacci_func1(n - 1) + fibonacci_func1(n - 2)


@lru_cache(maxsize=None)
def fibonacci_func2(n):
    if n < 2:
        return n
    return fibonacci_func2(n - 1) + fibonacci_func2(n - 2)
```
- **What it demonstrates**: Memoization as a one-line diff — identical bodies, `@lru_cache(maxsize=None)` is the entire optimization.

```python
class LazyLoadedData:
    def __init__(self):
        self._data = None

    @property
    def data(self):
        if self._data is None:
            self._data = self.load_data()
        return self._data

    def load_data(self):
        print("Loading expensive data...")
        return sum(i * i for i in range(100000))
```
- **What it demonstrates**: Lazy attribute loading — `@property` plus a `None` sentinel makes the expensive call happen on first access only, with no change to the caller's `obj.data` syntax.

```python
def recursive_factorial(n):
    """Calculate factorial (expensive for large n)"""
    if n == 1:
        return 1
    else:
        return n * recursive_factorial(n - 1)


@lru_cache(maxsize=128)
def cached_factorial(n):
    return recursive_factorial(n)
```
- **What it demonstrates**: Lazy Loading via caching — a bounded `lru_cache` wrapper turns an expensive initialization into a run-once-on-demand operation.

## Reference Tables

| Pattern | Intent | When to use | Python mechanism |
|---|---|---|---|
| Cache-Aside | Keep frequently read data in a cache to cut data-store round trips | Read-heavy, rarely-updated data; no cross-key consistency requirement | `redis.StrictRedis`, `cache.get` / `cache.set(key, val, ex=60)`, `sqlite3` |
| Memoization | Cache function results keyed on arguments | Pure, expensive, repeatedly-called-with-same-args functions; recursive algorithms | `functools.lru_cache(maxsize=None)` |
| Lazy Loading (attribute) | Defer initialization to first access | Expensive attribute that may never be read | `@property` + `self._data = None` sentinel |
| Lazy Loading (caching) | Run an expensive initialization once, on demand | Expensive resource setup that shouldn't slow startup | `@lru_cache(maxsize=128)` wrapper |

| Question | Answer | Pattern |
|---|---|---|
| Must the cache survive process restart / be shared across processes? | Yes | Cache-Aside (Redis / Memcached / ElastiCache) |
| Same function, same args, many times, one process? | Yes | Memoization (`lru_cache`) |
| Might the value never be needed at all? | Yes | Lazy Loading |
| Data changes often, or entries must stay consistent as a set? | Yes | Don't cache-aside |
| Argument space large or user-controlled? | Yes | Bound `maxsize`, never `None` |

**Setup**: `python -m pip install faker`, `python -m pip install redis`, `docker run --name myredis -p 6379:6379 redis`.

## Worked Example

**Cache-Aside over a quotes database.** Two scripts: `populate_db.py` (setup + seeding) and `cache_aside.py` (the read path).

Shared setup — Redis client and SQLite path, with a key prefix so quote keys can't collide with anything else in the same Redis instance:

```python
import sqlite3
from pathlib import Path
import redis

CACHE_KEY_PREFIX = "quote"
DB_PATH = Path(__file__).parent / Path("quotes.sqlite3")
cache = redis.StrictRedis(host="localhost", port=6379, decode_responses=True)
```

Seeding writes to SQLite and, in `update_all` mode, warms the cache with the same TTL the read path uses:

```python
        for q in added:
            print(f"Added to DB: {q}")
            print("  - Also adding to the cache")
            cache.set(str(q[0]), q[1], ex=60)
```

The `update_db_only` mode deliberately skips the cache write — that's how you produce a guaranteed miss to observe.

**Reasoning through the read path** (`get_quote`, shown in full above):

1. Build the key `quote.{id}` and try `cache.get`. Hit → return immediately, no database connection opened.
2. Miss (`quote is None`) → open SQLite, `SELECT text FROM quotes WHERE id = ...`, `fetchone()`.
3. No row → return the "no quote stored" message *without* caching. Negative results aren't cached here, so a hot miss keeps hitting the database — acceptable for this workload, a thundering-herd risk in a real one.
4. Row found → `cache.set(key, quote, ex=60)`, so the next 60 seconds of reads for that id are served from Redis.

Observed behavior on `python ch08/cache_aside/cache_aside.py`:

```
Enter the ID of the quote: 23
Got 'Dark team exactly really wind.' FROM DB - Added TO CACHE, with key 'quote.23'
Enter the ID of the quote: 12
There was no quote stored matching that id!
```

Ids present only in the database report `FROM DB` on the first read and populate the cache; the second read of the same id reports `FROM CACHE`.

**What's missing on purpose**: Case 2. Add an `update_quote()` that writes the new text to SQLite and then *deletes* `quote.{id}` from Redis — invalidate, don't rewrite. Without it, every update is invisible to readers for up to the full 60-second TTL.

## Key Takeaways

- Cache-Aside: read → miss → load → populate; write → store → **delete** the cache key.
- `functools.lru_cache` is the whole of memoization in Python. Bound `maxsize` unless the argument space is provably small.
- Memoization and lazy-loading-via-caching use the identical mechanism; the difference is intent — repeated computation vs. one-time resource initialization.
- `@property` + a `None` sentinel gives lazy attributes with zero change to caller syntax.
- Measure both paths. Every example times the uncached version first; a cache you can't show a delta for is complexity you didn't need.
- Caching bounded by TTL trades correctness for latency. Pick the TTL deliberately.

## Connects To

- **Ch. 7 (Concurrency & Async)**: complementary axes — concurrency overlaps work in time, caching removes work entirely. Shared caches across async workers need the same invalidation discipline.
- **Ch. 9 (Distributed Systems)**: cache-aside is the on-ramp; distributed patterns inherit its consistency problems at larger scale.
- **Ch. 11 (Python anti-patterns)**: "using global variables for caching" — the hand-rolled dict that `lru_cache` and Redis both replace.
- **Ch. 3 (Structural patterns)**: Proxy — a virtual proxy is lazy loading expressed as an object-level indirection rather than a property.
- **Ch. 2 (Creational patterns)**: lazy initialization overlaps with Singleton's deferred-instantiation concerns.
