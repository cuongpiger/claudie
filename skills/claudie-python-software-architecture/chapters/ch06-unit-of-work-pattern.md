# Chapter 6: Unit of Work Pattern

## Core Idea
If Repository is the abstraction over *persistent storage*, **Unit of Work (UoW, "you-wow") is the abstraction over atomic operations**. Implemented as a Python context manager, it fully decouples the service layer from the data layer and makes the system **safe by default**: nothing changes unless you explicitly commit.

## Frameworks Introduced

- **Unit of Work pattern**: a single entrypoint to persistent storage that tracks what objects were loaded and their latest state.
  - When to use: whenever a use case touches more than one object, or whenever you want "this block of code succeeds or fails as a unit."
  - How: `AbstractUnitOfWork` exposes `.batches` (a repository), `commit()`, `rollback()`, and `__enter__`/`__exit__`. Each service-layer use case runs inside one `with uow:` block.
  - Three things it buys you:
    1. A **stable snapshot** of the database, so objects don't change halfway through an operation.
    2. A way to **persist all changes at once**, so a failure can't leave inconsistent state.
    3. A **simple API to persistence** and a handy place to get a repository.

- **Explicit commit, implicit rollback** — the authors' deliberate choice:
  - `__exit__` always calls `rollback()`. (A rollback after a `commit()` has no effect.)
  - `commit()` must be called by hand inside the `with` block.
  - Why: "This makes the software safe by default. The default behavior is to **not change anything**. In turn, that makes our code easier to reason about because there's only one code path that leads to changes in the system: total success and an explicit commit. Any other code path, any exception, any early exit from the UoW's scope leads to a safe state."
  - The alternative (commit on clean exit, roll back on exception) saves one line and is explicitly rejected.

- **"Don't mock what you don't own"** — the rule of thumb that justifies wrapping `Session`:
  - `Session` is a complex object exposing lots of persistence functionality. Coupling to it means coupling to *all* of SQLAlchemy's complexity, and it's easy to sprinkle arbitrary queries across the codebase.
  - Building your own thin abstraction gives you the same test-speed benefit as mocking the session **but forces you to think carefully about your design.**

## Key Concepts

- **Atomic operation** — a group of changes that must all succeed or all fail.
- **Context manager** — `__enter__`/`__exit__`; the idiomatic Python way of defining scope. Setup and teardown phases.
- **Session factory** — a callable producing DB sessions; injected so tests can swap Postgres for SQLite.
- **Flush** — SQLAlchemy persisting all tracked changes together.
- **Collaborators** — objects that work together to achieve a goal. UoW and Repository are collaborators; in responsibility-driven design, clusters of collaborating objects are called **object neighborhoods** ("which is, in our professional opinion, totally adorable").

## Mental Models

- **The context manager makes atomicity *visible*.** You can see, by indentation, exactly which block of code happens together. That's the Pythonic payoff.
- **Think of the UoW as part of the service layer**, not the data layer. Flask now does only two things: initialize a unit of work, and invoke a service.
- **Rolling back by default is "harsh but simple."** It rolls back to the last commit — either the user made one, or you blow their changes away.
- **You are narrowing an interface, not adding a feature.** SQLAlchemy's `Session` *already is* a Unit of Work. You're wrapping it to reduce it to its essential core: started, committed, or thrown away — plus the developer-usability win of hanging repositories off it.
- **Faking your own code beats faking someone else's.** `FakeUnitOfWork` replaces `FakeSession`, and that's "a substantial improvement because we're now faking out code that we wrote rather than third-party code."
- **`FakeUnitOfWork` and `FakeRepository` are tightly coupled — and that's fine.** They're collaborators, exactly like the real classes.

## Code Examples

**The port:**

```python
# src/allocation/service_layer/unit_of_work.py
class AbstractUnitOfWork(abc.ABC):
    batches: repository.AbstractRepository

    def __exit__(self, *args):
        self.rollback()          # always — rollback after commit is a no-op

    @abc.abstractmethod
    def commit(self):
        raise NotImplementedError

    @abc.abstractmethod
    def rollback(self):
        raise NotImplementedError
```

**The real adapter — the only place a `Session` is allowed to exist:**

```python
DEFAULT_SESSION_FACTORY = sessionmaker(bind=create_engine(config.get_postgres_uri()))


class SqlAlchemyUnitOfWork(AbstractUnitOfWork):
    def __init__(self, session_factory=DEFAULT_SESSION_FACTORY):
        self.session_factory = session_factory

    def __enter__(self):
        self.session = self.session_factory()  # type: Session
        self.batches = repository.SqlAlchemyRepository(self.session)
        return super().__enter__()

    def __exit__(self, *args):
        super().__exit__(*args)
        self.session.close()

    def commit(self):
        self.session.commit()

    def rollback(self):
        self.session.rollback()
```
- **What it demonstrates**: the default factory connects to Postgres, but it's overridable so integration tests can use SQLite. `__enter__` starts the session *and* builds the repository around it.

**The fake — replaces `FakeSession` entirely:**

```python
class FakeUnitOfWork(unit_of_work.AbstractUnitOfWork):
    def __init__(self):
        self.batches = FakeRepository([])
        self.committed = False

    def commit(self):
        self.committed = True

    def rollback(self):
        pass
```

**The service layer, final form for Part I:**

```python
def add_batch(
    ref: str, sku: str, qty: int, eta: Optional[date],
    uow: unit_of_work.AbstractUnitOfWork,
):
    with uow:
        uow.batches.add(model.Batch(ref, sku, qty, eta))
        uow.commit()


def allocate(
    orderid: str, sku: str, qty: int,
    uow: unit_of_work.AbstractUnitOfWork,
) -> str:
    line = OrderLine(orderid, sku, qty)
    with uow:
        batches = uow.batches.list()
        if not is_valid_sku(line.sku, batches):
            raise InvalidSku(f'Invalid sku {line.sku}')
        batchref = model.allocate(line, batches)
        uow.commit()
    return batchref
```
- **What it demonstrates**: **one dependency**, on an abstract UoW. No session, no repository parameter. Compare with Ch4's `allocate(line, repo, session)`.

**And the tests get simpler too:**

```python
def test_add_batch():
    uow = FakeUnitOfWork()
    services.add_batch("b1", "CRUNCHY-ARMCHAIR", 100, None, uow)
    assert uow.batches.get("b1") is not None
    assert uow.committed
```

## Reference Tables

| Unit of Work pattern: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| A nice abstraction over atomic operations; the context manager makes grouped blocks visually obvious | Your ORM probably already has good atomicity abstractions — SQLAlchemy even has context managers |
| Explicit control over transaction start/finish; **safe by default**, never partially committed | You have to think carefully about rollbacks, multithreading, and nested transactions |
| A nice place to put all your repositories so client code can reach them | Sticking to what Django or Flask-SQLAlchemy gives you may keep life simpler |
| Atomicity isn't only about transactions — it helps with events and the message bus later (Part II) | |

| Commit style | Behavior | Verdict |
|---|---|---|
| **Explicit commit** (chosen) | `__exit__` always rolls back; you call `commit()` | Safe by default; one code path to change |
| Implicit commit | `__exit__` commits if no exception, else rolls back | Saves a line; rejected as less safe |

## Worked Example

**Two use cases that show why atomicity matters.**

*Example 1 — Reallocate.* Deallocate, then reallocate:
```python
def reallocate(line: OrderLine, uow: AbstractUnitOfWork) -> str:
    with uow:
        batch = uow.batches.get(sku=line.sku)
        if batch is None:
            raise InvalidSku(f'Invalid sku {line.sku}')
        batch.deallocate(line)
        allocate(line)
        uow.commit()
```
> If `deallocate()` fails, we don't want to call `allocate()`, obviously. If `allocate()` fails, we probably don't want to actually commit the `deallocate()` either.

*Example 2 — Change batch quantity.* "Our shipping company gives us a call to say that one of the container doors opened, and half our sofas have fallen into the Indian Ocean. Oops!"
```python
def change_batch_quantity(batchref: str, new_qty: int, uow: AbstractUnitOfWork):
    with uow:
        batch = uow.batches.get(reference=batchref)
        batch.change_purchased_quantity(new_qty)
        while batch.available_quantity < 0:
            line = batch.deallocate_one()
        uow.commit()
```
> Here we may need to deallocate any number of lines. If we get a failure at any stage, we probably want to commit none of the changes.

**The tests that prove safe-by-default:**
```python
def test_rolls_back_uncommitted_work_by_default(session_factory):
    uow = unit_of_work.SqlAlchemyUnitOfWork(session_factory)
    with uow:
        insert_batch(uow.session, 'batch1', 'MEDIUM-PLINTH', 100, None)
        # note: no uow.commit()

    new_session = session_factory()
    rows = list(new_session.execute('SELECT * FROM "batches"'))
    assert rows == []


def test_rolls_back_on_error(session_factory):
    class MyException(Exception):
        pass

    uow = unit_of_work.SqlAlchemyUnitOfWork(session_factory)
    with pytest.raises(MyException):
        with uow:
            insert_batch(uow.session, 'batch1', 'LARGE-FORK', 100, None)
            raise MyException()

    new_session = session_factory()
    rows = list(new_session.execute('SELECT * FROM "batches"'))
    assert rows == []
```

**Housekeeping:** there are now three integration test files pointing at the database — `test_orm.py`, `test_repository.py`, `test_uow.py`. The verdict: *"always feel free to throw away tests if you think they're not going to add value longer term."* `test_orm.py` was a tool for learning SQLAlchemy and its coverage overlaps `test_repository.py`; drop it. There's a defensible argument for keeping everything at the highest possible level of abstraction.

## Anti-patterns

- **Passing a raw `Session` around your codebase.** It leads to data-access code sprinkled everywhere, because `Session` makes arbitrary queries too easy.
- **Mocking SQLAlchemy directly.** Fast tests, no design improvement — the thing "don't mock what you don't own" exists to prevent.
- **Implicit commit on happy path.** Convenient, but now more than one code path can change the system.
- **Keeping ORM learning tests forever** once the repository/UoW tests cover the same ground.

## Key Takeaways

1. **UoW is an abstraction around data integrity.** It enforces domain-model consistency and improves performance via a single flush at the end of an operation.
2. **Each service-layer use case runs in exactly one unit of work** that succeeds or fails as a block.
3. **Context managers are the right Python idiom** for this — scope, setup, teardown, and visual grouping in one construct.
4. **Prefer explicit commit and default rollback.** Safe by default beats one line saved.
5. **Narrow the ORM's interface deliberately.** SQLAlchemy already implements UoW; you wrap it to keep coupling loose and to hang repositories off it.
6. **Don't mock what you don't own** — it forces you to build simple abstractions over messy subsystems.
7. **This is the DIP again**: the service layer depends on a thin abstraction, and the concrete implementation is attached at the outside edge of the system — exactly what SQLAlchemy's own docs recommend ("keep the life cycle of the session … separate and external").

## Connects To
- **Ch 2**: Repository — UoW is where `.commit()` finally lands, having been deliberately kept out of the repository.
- **Ch 4**: the service layer, which now has a single dependency instead of three.
- **Ch 5**: `FakeSession` disappears; the "build better abstractions, then move tests to run against them" lesson applied again.
- **Ch 7**: switching some tests to a real Postgres for transaction-level behavior — made easy by the injectable session factory.
- **Ch 9 / Ch 13**: `uow.collect_new_events()` and dependency injection extend this same object.
- **Martin Fowler, *PoEAA***: the original Unit of Work pattern.
- **SQLAlchemy "Session Basics"**: the ORM's own recommendation to keep session/transaction lifecycle external.
