# Chapter 12: Command-Query Responsibility Segregation (CQRS)

## Core Idea
**Domain models are for writing.** All the machinery — aggregates, UoW, service layer, events — exists to enforce rules when *changing* state, and buys you nothing for reads. Reads have a different access pattern, different consistency requirements, and different scaling properties, so separate them — up to and including a denormalized read store kept fresh by event handlers.

## Frameworks Introduced

- **Command-Query Separation (CQS)**: *"functions should either modify state or answer questions, but never both."* "We should always be able to ask, 'Are the lights on?' without flicking the light switch."
  - Familiar instance: **Post/Redirect/Get**. POST to `/batches`, redirect to `/batches/123`. Fixes double-submission on refresh (buying two sofas when you needed one) and broken bookmarks (GET on a POST endpoint). Both problems come from *returning data in response to a write*.
  - API equivalent: return `201 Created` or `202 Accepted` with a `Location` header. "What's important here isn't the status code we use but the logical separation of work into a write phase and a query phase."

- **CQRS**: push CQS to the architecture level — a separate read model, potentially a separate store.
  - When to use: when your domain model is rich, and read requirements are conceptually different from write requirements.
  - **When NOT to use**: "If you're building a simple CRUD app, reads and writes are going to be closely related, so you don't need a domain model or CQRS." Same justification as the Domain Model pattern itself.

- **Read model maintained by event handlers**: add a second handler to `Allocated` that INSERTs into a denormalized `allocations_view` table; add one to `Deallocated` that DELETEs. *"Event handlers are a great way to manage updates to a read model, if you decide you need one. They also make it easy to change the implementation of that read model at a later date."*

- **Rebuilding a read model from scratch** — "'What happens when it breaks?' should be the first question we ask as engineers." Because updates go through the service layer, write a tool that:
  1. Queries the current state of the **write side** to work out what's currently allocated.
  2. Calls the `add_allocation_to_read_model` handler for each allocated item.

  The same technique creates **entirely new read models from historical data**.

- **Test at the seam, not the implementation.** Integration tests set up via `messagebus.handle(commands.…)` and assert on `views.allocations(...)`. *The exact same tests pass* against raw SQL, the ORM, the repository, a denormalized table, **and** Redis.

## Key Concepts

- **Read side / write side** — the two halves of the system.
- **`views.py`** — a real views module: read-only projections of your data. Not Django's kind.
- **Denormalized view model** — `allocations_view(orderid, sku, batchref)`. "No foreign keys, just strings, YOLO."
- **SELECT N+1** — the classic ORM performance trap: one query for IDs, then one per object. (SQLAlchemy is quite good at avoiding it; use explicit eager loading for joined objects.)
- **Read replicas** — horizontally scalable because reads don't lock.
- **Eventual consistency on reads** — the deliberate trade of consistency for performance and scale.

## Mental Models

- **"As soon as we render the product page, the data is already stale."** This is the key insight for accepting inconsistent reads. Bob and Harry both load the page; Harry makes coffee; Bob buys the last dresser. Harry's order fails at allocation — and it would have failed identically in a perfectly consistent system. **As soon as you have a web server and two customers, you have the potential for stale data.**
- **And even perfect consistency doesn't save you.** Suppose you magically build a totally consistent web app. Harry buys his dresser first. Then the warehouse staff drop it off the forklift and it smashes into a zillion pieces. Your only options are the *same two options*: refund Harry or buy more stock and delay delivery. **"No matter what we do, we're always going to find that our software systems are inconsistent with reality, and so we'll always need business processes to cope with these edge cases."**
- **Look at the traffic asymmetry.** At MADE.com: ~100 orders per *hour*, but ~100 product views per *second*. Same domain — batches, arrival dates, available quantity — wildly different access pattern. Customers won't notice a query a few seconds out of date; an inconsistent allocate service ruins their orders.
- **A domain model is not a data model.** It captures workflow, rules around state changes, messages exchanged, reactions to external events and user input. *"Most of this stuff is totally irrelevant for read-only operations."* Your domain classes have many methods for modifying state, and you need none of them to read.
- **The read/write divergence grows with complexity.** "As the complexity of your domain model grows, you will find yourself making more and more choices about how to structure that model, which make it more and more awkward to use for read operations."
- **Reads scale because they don't lock.** Writes need row locks to avoid race conditions; reads have no such limit, so read-only stores can be horizontally scaled out. **"Because read replicas can be inconsistent, there's no limit to how many we can have. If you're struggling to scale a system with a complex data store, ask whether you could build a simpler read model."**
- **The fastest query is always `SELECT * FROM mytable WHERE key = :value`.** Even with well-tuned indexes, a relational database burns a lot of CPU on joins.
- **Split reads from writes even if you stop short of CQRS.** "Splitting out your read-only views from your state-modifying command and event handlers is probably a good idea, even if you don't want to go to full-blown CQRS."

## Code Examples

**First, fix the CQS violation.** The `allocate` endpoint used to return the batch ID — the reason `messagebus.handle()` had to return results at all (Ch9's "temporary ugly hack"). Now it returns `202` and there's a separate read endpoint:

```python
# src/allocation/entrypoints/flask_app.py
from allocation import views

@app.route("/allocations/<orderid>", methods=['GET'])
def allocations_view_endpoint(orderid):
    uow = unit_of_work.SqlAlchemyUnitOfWork()
    result = views.allocations(orderid, uow)
    if not result:
        return 'not found', 404
    return jsonify(result), 200
```

**Option A — hand-rolled SQL. "Excuse me? Raw SQL?"**

```python
# src/allocation/views.py
def allocations(orderid: str, uow: unit_of_work.SqlAlchemyUnitOfWork):
    with uow:
        results = list(uow.session.execute(
            'SELECT ol.sku, b.reference'
            ' FROM allocations AS a'
            ' JOIN batches AS b ON a.batch_id = b.id'
            ' JOIN order_lines AS ol ON a.orderline_id = ol.id'
            ' WHERE ol.orderid = :orderid',
            dict(orderid=orderid)
        ))
    return [{'sku': sku, 'batchref': batchref} for sku, batchref in results]
```

**Option B — reuse the repository. Clunkier than it looks:**

```python
def allocations(orderid: str, uow: unit_of_work.AbstractUnitOfWork):
    with uow:
        products = uow.products.for_order(orderid=orderid)   # new repo method needed
        batches = [b for p in products for b in p.batches]   # loop in Python
        return [
            {'sku': b.sku, 'batchref': b.reference}
            for b in batches
            if orderid in b.orderids                          # filter again in Python
        ]


class Batch:
    @property
    def orderids(self):                                       # "arguably unnecessary property"
        return {l.orderid for l in self._allocations}
```
- **What it demonstrates**: you had to add helper methods to *both* the repository and the domain model, and you're doing looping and filtering in Python "which is work that would be done much more efficiently by the database."

**Option C — the ORM:**

```python
def allocations(orderid: str, uow: unit_of_work.AbstractUnitOfWork):
    with uow:
        batches = uow.session.query(model.Batch).join(
            model.OrderLine, model.Batch._allocations
        ).filter(
            model.OrderLine.orderid == orderid
        )
        return [{'sku': b.sku, 'batchref': b.batchref} for b in batches]
```
> "Is that *actually* any easier to write or understand than the raw SQL version? It may not look too bad up there, but we can tell you it took several attempts, and plenty of digging through the SQLAlchemy docs. **SQL is just SQL.**"

**Option D — full CQRS with a denormalized table:**

```python
# src/allocation/adapters/orm.py
allocations_view = Table(
    'allocations_view', metadata,
    Column('orderid', String(255)),
    Column('sku', String(255)),
    Column('batchref', String(255)),
)

# src/allocation/views.py
def allocations(orderid: str, uow: unit_of_work.SqlAlchemyUnitOfWork):
    with uow:
        results = list(uow.session.execute(
            'SELECT sku, batchref FROM allocations_view WHERE orderid = :orderid',
            dict(orderid=orderid)
        ))
        ...

# src/allocation/service_layer/messagebus.py
EVENT_HANDLERS = {
    events.Allocated: [
        handlers.publish_allocated_event,
        handlers.add_allocation_to_read_model,      # ← new
    ],
    events.Deallocated: [
        handlers.remove_allocation_from_read_model,
        handlers.reallocate,
    ],
}

# src/allocation/service_layer/handlers.py
def add_allocation_to_read_model(event: events.Allocated, uow):
    with uow:
        uow.session.execute(
            'INSERT INTO allocations_view (orderid, sku, batchref)'
            ' VALUES (:orderid, :sku, :batchref)',
            dict(orderid=event.orderid, sku=event.sku, batchref=event.batchref)
        )
        uow.commit()
```

## Reference Tables

| | Read side | Write side |
|---|---|---|
| Behavior | Simple read | Complex business logic |
| Cacheability | Highly cacheable | Uncacheable |
| Consistency | **Can be stale** | Must be transactionally consistent |

| View model option | Pros | Cons |
|---|---|---|
| **Just use repositories** | Simple, consistent approach | Expect performance issues with complex query patterns |
| **Custom queries with your ORM** | Reuses DB config and model definitions | Adds another query language with its own quirks and syntax |
| **Hand-rolled SQL** | Fine control over performance, standard query syntax | Schema changes must be made to your queries **and** your ORM definitions; highly normalized schemas may still be slow |
| **Separate read stores with events** | Read-only copies scale out easily; views constructed on write so queries are as simple as possible | Complex technique. "Harry will be forever suspicious of your tastes and motives" |

## Worked Example

**Swapping the entire read store to Redis — and not touching a single test.**

The integration test, written against the message bus (setup) and the view (assertion):

```python
def test_allocations_view(sqlite_session_factory):
    uow = unit_of_work.SqlAlchemyUnitOfWork(sqlite_session_factory)
    messagebus.handle(commands.CreateBatch('sku1batch', 'sku1', 50, None), uow)
    messagebus.handle(commands.CreateBatch('sku2batch', 'sku2', 50, today), uow)
    messagebus.handle(commands.Allocate('order1', 'sku1', 20), uow)
    messagebus.handle(commands.Allocate('order1', 'sku2', 20), uow)
    # add a spurious batch and order to make sure we're getting the right ones
    messagebus.handle(commands.CreateBatch('sku1batch-later', 'sku1', 50, today), uow)
    messagebus.handle(commands.Allocate('otherorder', 'sku1', 30), uow)
    messagebus.handle(commands.Allocate('otherorder', 'sku2', 10), uow)

    assert views.allocations('order1', uow) == [
        {'sku': 'sku1', 'batchref': 'sku1batch'},
        {'sku': 'sku2', 'batchref': 'sku2batch'},
    ]
```
> "We do the setup for the integration test by using the public entrypoint to our application, the message bus. That keeps our tests decoupled from any implementation/infrastructure details about how things get stored."

Now switch the read model to Redis. **Three tiny edits:**

```python
# src/allocation/service_layer/handlers.py
def add_allocation_to_read_model(event: events.Allocated, _):
    redis_eventpublisher.update_readmodel(event.orderid, event.sku, event.batchref)

def remove_allocation_from_read_model(event: events.Deallocated, _):
    redis_eventpublisher.update_readmodel(event.orderid, event.sku, None)


# src/allocation/adapters/redis_eventpublisher.py   (one-liners)
def update_readmodel(orderid, sku, batchref):
    r.hset(orderid, sku, batchref)

def get_readmodel(orderid):
    return r.hgetall(orderid)


# src/allocation/views.py
def allocations(orderid):
    batches = redis_eventpublisher.get_readmodel(orderid)
    return [
        {'batchref': b.decode(), 'sku': s.decode()}
        for s, b in batches.items()
    ]
```

**"And the *exact same* integration tests that we had before still pass, because they are written at a level of abstraction that's decoupled from the implementation."**

**The two-transaction flow:**
```
User -> Flask: POST to allocate endpoint
Flask -> MessageBus : Allocate Command

group UoW/transaction 1
    MessageBus -> Domain : allocate()
    MessageBus -> DB: commit write model
end

group UoW/transaction 2
    Domain -> MessageBus : raise Allocated event(s)
    MessageBus -> DB : update view model
end

Flask -> User: 202 OK

User -> Flask: GET allocations endpoint
Flask -> View: get allocations
View -> DB: SELECT on view model
```

## Anti-patterns

- **Returning data in response to a write operation** — the CQS violation that causes double-submits, broken bookmarks, and the `messagebus.handle()` results hack.
- **Forcing read operations through the write model's abstractions** when the concepts genuinely differ. You end up adding helper methods to the repository *and* the domain model, and doing DB work in Python.
- **Reaching for CQRS in a CRUD app.** Same rule as the domain model itself.
- **Maintaining read models with database views/triggers** — a common solution, but "that limits you to your database."

## Key Takeaways

1. **Reads and writes are different; treat them differently.** At minimum, put read-only views in `views.py` and keep them out of your handlers.
2. **Stale reads are unavoidable, so trade consistency for read performance deliberately.** You'll always re-check state at allocation time anyway.
3. **A domain model is not a data model.** Nothing in it helps you read.
4. **Judge each option by your own read/write conceptual distance.** "Often, your read operations will be acting on the same conceptual objects as your write model, so using the ORM, adding some read methods to your repositories, and using domain model classes for your read operations is *just fine*."
5. **Raw SQL is a legitimate answer.** In the book's example the allocation service thinks in `Batch`es for one SKU while users care about a whole multi-SKU order — so the ORM is awkward and the authors are "quite tempted to go with the raw-SQL view."
6. **Event handlers are the flexible way to maintain a read model** — and the reason swapping Postgres for Redis costs three edits.
7. **Always have a rebuild path.** Query the write side, replay through the handler.
8. **Be honest about the scale you need.** MADE.com's real allocation service does use full CQRS with Redis and a Varnish cache — but the authors say "for the kind of allocation service we're building, it seems unlikely that you'd need to."

## Connects To
- **Ch 9**: the `return result` "temporary ugly hack" on the message bus, finally removed here.
- **Ch 11**: the `Allocated` event, which now has a second handler; `redis_eventpublisher`, reused as a read store.
- **Ch 10**: commands vs events — event failure independence is why a stale read model is survivable.
- **Ch 2**: the Repository pattern, examined here as a read mechanism and found wanting.
- **Ch 6 / Ch 7**: UoW and aggregates, all of which exist purely for the write side.
- **Epilogue**: managing complex queries.
- **Event sourcing**: adjacent territory, "very much a topic for another book."
