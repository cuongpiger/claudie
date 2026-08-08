# Chapter 7: Aggregates and Consistency Boundaries

## Core Idea
An **aggregate** is a domain object that contains other domain objects and is the *only* way to modify them. Choosing your aggregates is choosing your **consistency boundaries** — which is simultaneously a conceptual decision (who enforces which invariants) and a performance decision (what you lock, and how much concurrency you get).

## Frameworks Introduced

- **Aggregate pattern** (Evans): *"An AGGREGATE is a cluster of associated objects that we treat as a unit for the purpose of data changes."*
  - When to use: when a model has collections and it's becoming hard to keep track of who can modify what; when you need concurrency without overselling.
  - How: nominate a **root entity** that encapsulates access to its members. The only way to modify objects inside is to load the whole aggregate and call methods on the root.
  - Sizing rule: **draw the boundary around a small number of objects — the smaller, the better, for performance** — that must be consistent with one another. And give the boundary a good name.
  - Corollary: `Cart` is a good aggregate; each basket is a single consistency boundary responsible for its own invariants. You never modify two baskets in one transaction, because there's no use case for it.

- **One Aggregate = One Repository**: once entities are aggregates, they are the *only* entities publicly accessible to the outside world. **The only repositories you're allowed are repositories that return aggregates.**
  - "The rule that repositories should only return aggregates is the main place where we enforce the convention that aggregates are the only way into our domain model. Be wary of breaking it!"
  - Concretely: `BatchRepository` → `ProductRepository`; `uow.batches` → `uow.products`.

- **Optimistic concurrency control with version numbers**:
  - When to use: you can't afford to lock a whole table, but you must prevent lost updates on a single aggregate.
  - How: put a `version_number` on the aggregate root and increment it on every state change. Two transactions that both read `version=3` and both try to write `version=4` — only one wins; the other gets *"could not serialize access due to concurrent update."*
  - **The number isn't important.** What matters is that the aggregate's database row is modified on every change to the aggregate. It could equally be a random UUID.
  - Requires an isolation level that will detect the conflict: `isolation_level="REPEATABLE READ"` on the session factory.
  - Failure handling: **retry the operation from the beginning.** Bob's failed order reloads the product at version 2 and allocates again; if stock ran out he gets `OutOfStock`.

- **Pessimistic alternative — `SELECT FOR UPDATE`**: picks rows to use as a lock; the second transaction waits instead of failing.
  - Changes the pattern from `read1, read2, write1, write2(fail)` to `read1, write1, read2, write2(succeed)`.
  - In SQLAlchemy: `.with_for_update()` on the query in the repository's `get()`.
  - With pessimistic locking you don't handle failures (the DB prevents them) but you do have to think about deadlocks.

## Key Concepts

- **Constraint** — a rule that restricts the possible states the model can get into ("no double bookings").
- **Invariant** — a condition that is always true when an operation finishes ("a room cannot have more than one booking for the same night"). *You may temporarily bend an invariant mid-operation — e.g. shuffling rooms for a VIP — as long as the final state is consistent, or you raise an error and refuse.*
- **Consistency boundary** — the set of objects an aggregate guarantees are mutually consistent.
- **Aggregate root** — the entity that encapsulates access to the aggregate's members.
- **Bounded context** — different models for the same word in different parts of the business. Attributes needed in one context are irrelevant in another; worse, the same name can mean entirely different things.
- **Optimistic concurrency control** — assume conflicts are unlikely; let both proceed and detect the clash.
- **Pessimistic concurrency control** — assume conflicts will happen; lock everything to prevent them.
- **Read-modify-write failure mode** — the anti-pattern optimistic locking exists to catch.
- **"CSV over SMTP" architecture** — business processes run by emailing spreadsheets around. Low initial complexity, doesn't scale, because it's hard to apply logic and maintain consistency.

## Mental Models

- **"Why not just run everything in a spreadsheet?"** — the framing question for the whole chapter. Business users *like* spreadsheets. The reason you write a domain model is to enforce constraints: who can view this field, who can update it, what happens when someone orders –350 chairs or 10,000,000 tables, can an employee have a negative salary.
- **Aggregates are the "public" classes of your model.** Just as `_leading_underscores` mark methods as private, aggregates mark which domain classes are public and which entities/value objects are internal.
- **Get the granularity right.** `Shipment` and `Warehouse` were both rejected as aggregates: you must be able to allocate `DEADLY-SPOON` and `FLIMSY-DESK` at the same time, even in the same warehouse. There is *no invariant covering two different SKUs*, so they must not share a consistency boundary.
- **Name it in the ubiquitous language, even after bikeshedding.** `GlobalSkuStock` → `SkuStock` → `Stock` → `ProductStock` → **`Product`** — "after all, that was the first concept we came across in our exploration of the domain language back in Chapter 1."
- **Your `Product` need not look like anyone else's.** No price, no description, no dimensions — the allocation service doesn't care. *"As a rule of thumb, your domain models should include only the data that they need for performing calculations."* That's the power of bounded contexts, and it maps directly onto microservices.
- **There isn't *one* correct aggregate.** "We should feel comfortable changing our minds if we find our boundaries are causing performance woes." Splitting by region or warehouse, or redesigning around shipment, are all legitimate later moves.

## Code Examples

**The aggregate, with the domain service absorbed into it:**

```python
# src/allocation/domain/model.py
class Product:
    def __init__(self, sku: str, batches: List[Batch], version_number: int = 0):
        self.sku = sku                      # the aggregate's identifier
        self.batches = batches              # the objects inside the boundary
        self.version_number = version_number

    def allocate(self, line: OrderLine) -> str:
        try:
            batch = next(b for b in sorted(self.batches) if b.can_allocate(line))
            batch.allocate(line)
            self.version_number += 1        # marks the whole state change complete
            return batch.reference
        except StopIteration:
            raise OutOfStock(f'Out of stock for sku {line.sku}')
```
- **What it demonstrates**: Ch1's standalone `allocate()` domain service is now a method on the aggregate root. `Batch` is no longer reachable from outside.

**The repository and UoW follow the aggregate:**

```python
class AbstractUnitOfWork(abc.ABC):
    products: repository.AbstractProductRepository


class AbstractProductRepository(abc.ABC):
    @abc.abstractmethod
    def add(self, product): ...

    @abc.abstractmethod
    def get(self, sku) -> model.Product: ...
```

**The service layer, now going through the aggregate:**

```python
def add_batch(ref, sku, qty, eta, uow: unit_of_work.AbstractUnitOfWork):
    with uow:
        product = uow.products.get(sku=sku)
        if product is None:
            product = model.Product(sku, batches=[])
            uow.products.add(product)
        product.batches.append(model.Batch(ref, sku, qty, eta))
        uow.commit()


def allocate(orderid, sku, qty, uow: unit_of_work.AbstractUnitOfWork) -> str:
    line = OrderLine(orderid, sku, qty)
    with uow:
        product = uow.products.get(sku=line.sku)
        if product is None:
            raise InvalidSku(f'Invalid sku {line.sku}')
        batchref = product.allocate(line)
        uow.commit()
    return batchref
```

**Pessimistic option, if you prefer it:**

```python
# src/allocation/adapters/repository.py
def get(self, sku):
    return self.session.query(model.Product) \
                       .filter_by(sku=sku) \
                       .with_for_update() \
                       .first()
```

## Reference Tables

| Aggregates: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| Lets you decide which domain classes are public and which aren't (the next level up from `_underscore`) | Yet another concept for new developers — entities vs value objects was already a mental load |
| Modeling around explicit consistency boundaries avoids ORM performance problems | Sticking rigidly to "modify only one aggregate at a time" is a big mental shift |
| Sole charge of state changes makes the system easier to reason about and invariants easier to control | Dealing with eventual consistency *between* aggregates can be complex |

| | Optimistic (version numbers) | Pessimistic (`SELECT FOR UPDATE`) |
|---|---|---|
| Assumption | Conflicts are unlikely | Conflicts will happen |
| Behavior on clash | Second transaction **fails**; you retry | Second transaction **waits** |
| You must handle | Retry logic | Deadlocks |
| Concurrency pattern | `read1, read2, write1, write2(fail)` | `read1, write1, read2, write2(succeed)` |
| Cost | Retries under contention | Blocking, reduced throughput |
| Alternative | `SERIALIZABLE` isolation — same effect, often severe performance cost | |

| Where to put `version_number`? | Verdict |
|---|---|
| **1. In the domain** — `Product.__init__` takes it, `Product.allocate()` increments it | **Chosen.** Cleanest trade-off, even though it isn't strictly a domain concern |
| 2. In the service layer — repository attaches it, service increments before commit | Mixes state-mutation responsibility across two layers. Messy |
| 3. In the UoW/repository "by magic" — increment on commit for any known products | Not ideal: no way to do it without assuming *all* products changed |

## Worked Example

**Why `Product` and not `Warehouse` — the reasoning chain, then the concurrency test that proves it works.**

Two business rules are the input:
1. *"An order line can be allocated to only one batch at a time."* → invariant: an order line is allocated to zero or one batch, never more.
2. *"We can't allocate to a batch if the available quantity is less than the quantity of the order line."* → invariant: available quantity ≥ 0, i.e. never oversell the same physical cushion to two customers.

Single-threaded, both are trivial. Under concurrency you need locks — but at tens of thousands of orders per hour you can't hold a lock over the whole `batches` table without deadlocks or performance collapse.

So: what's the smallest set of objects that must be consistent with each other?
- **`Shipment`?** Batches arriving together — but two SKUs in one shipment must be allocatable concurrently. Wrong granularity.
- **`Warehouse`?** Same problem.
- **All batches sharing a SKU?** Yes — allocation only ever looks at batches whose SKU matches the order line. `GlobalSkuStock` → renamed **`Product`**.

**The concurrency test, using threads and a deliberate `sleep` to force the interleaving:**

```python
def try_to_allocate(orderid, sku, exceptions):
    line = model.OrderLine(orderid, sku, 10)
    try:
        with unit_of_work.SqlAlchemyUnitOfWork() as uow:
            product = uow.products.get(sku=sku)
            product.allocate(line)
            time.sleep(0.2)                     # force read1, read2, write1, write2
            uow.commit()
    except Exception as e:
        print(traceback.format_exc())
        exceptions.append(e)


def test_concurrent_updates_to_version_are_not_allowed(postgres_session_factory):
    sku, batch = random_sku(), random_batchref()
    session = postgres_session_factory()
    insert_batch(session, batch, sku, 100, eta=None, product_version=1)
    session.commit()

    order1, order2 = random_orderid(1), random_orderid(2)
    exceptions = []  # type: List[Exception]
    thread1 = threading.Thread(target=lambda: try_to_allocate(order1, sku, exceptions))
    thread2 = threading.Thread(target=lambda: try_to_allocate(order2, sku, exceptions))
    thread1.start(); thread2.start()
    thread1.join();  thread2.join()

    [[version]] = session.execute(
        "SELECT version_number FROM products WHERE sku=:sku", dict(sku=sku))
    assert version == 2                          # incremented exactly once

    [exception] = exceptions
    assert 'could not serialize access due to concurrent update' in str(exception)

    orders = list(session.execute(
        "SELECT orderid FROM allocations"
        " JOIN batches ON allocations.batch_id = batches.id"
        " JOIN order_lines ON allocations.orderline_id = order_lines.id"
        " WHERE order_lines.sku=:sku", dict(sku=sku)))
    assert len(orders) == 1                      # only one allocation got through
```

Made to pass by setting the isolation level on the session factory:
```python
DEFAULT_SESSION_FACTORY = sessionmaker(bind=create_engine(
    config.get_postgres_uri(),
    isolation_level="REPEATABLE READ",
))
```
Note this test runs against **real Postgres**, not SQLite — transaction isolation is exactly the "obscure database behavior" Ch6 said to test against the real engine.

**On performance — why loading all a product's batches is fine:** (1) the model is deliberately shaped for *one query to read, one update to write*, which beats systems issuing lots of ad hoc queries; (2) the data is a few strings and ints per row — hundreds of batches load in milliseconds; (3) expect ~20 active batches per product, since used-up batches drop out. If you did have thousands, lazy-loading would page them transparently, and you only need to find one batch with capacity.

## Anti-patterns

- **Repositories that return non-aggregate entities.** That's the hole through which the aggregate rule leaks.
- **Modifying more than one aggregate in a transaction.** The rule is rigid on purpose.
- **Locking the whole table** to protect a per-SKU invariant.
- **Choosing an aggregate that's too coarse** (`Warehouse`, `Shipment`) — you serialize operations that had no invariant in common.
- **Copy-pasting this chapter's concurrency code into production.** The authors say so explicitly: some of it is Postgres-specific, requirements vary a lot, and this is only one approach.
- **Building one model for the whole business.** Bounded contexts exist because `customer` means different things to sales, support, and logistics.

## Key Takeaways

1. **Aggregates are your entrypoints into the domain model.** Restricting how things can change is what makes the system reasonable about.
2. **An aggregate owns a consistency boundary**: it checks that the objects in its remit are consistent with each other and with the rules, and rejects changes that would break them.
3. **Aggregates and concurrency go together.** Choosing the right aggregate is a performance decision as much as a conceptual one.
4. **One aggregate = one repository.** Enforce it.
5. **Smaller aggregates are better** — but only if all their contents genuinely share invariants.
6. **Version numbers make an implicit concept explicit** and give you optimistic locking without `SERIALIZABLE`'s cost.
7. **Handle optimistic-lock failures by retrying the whole operation.** Most operations retry cleanly.
8. **Domain models should include only the data they need for their calculations** — bounded contexts, not one universal model.

## Connects To
- **Ch 1**: `Batch`, `OrderLine`, and the standalone `allocate()` domain service that becomes `Product.allocate()`.
- **Ch 2**: Repository — now constrained to return only aggregates.
- **Ch 6**: Unit of Work — `uow.products`, and the injectable session factory that makes the real-Postgres concurrency test possible.
- **Ch 8–11**: events and the message bus, which are how you handle **eventual consistency between aggregates** — the "con" listed above.
- **Ch 11**: "Recovering from Errors Synchronously" and "Footguns" — more on retries.
- **Evans, *Domain-Driven Design***: the Aggregate and Bounded Context patterns.
- **Vaughn Vernon, "Effective Aggregate Design"** (three online papers): the recommended deep dive.
