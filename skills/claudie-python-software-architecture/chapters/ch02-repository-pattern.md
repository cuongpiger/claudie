# Chapter 2: Repository Pattern

## Core Idea
Put a **Repository** — a simplifying abstraction that pretends all your data is in memory — between the domain model and the database, and invert the ORM dependency so that **the ORM imports the model, never the reverse**.

## Frameworks Introduced

- **Repository pattern**: an abstraction over persistent storage that gives you "the illusion of a collection of in-memory objects."
  - When to use: when the domain is complex enough that you want to change business rules without thinking about migrations, and you want fast unit tests.
  - How: define `add(thing)` and `get(id)`. Stick *rigidly* to those two methods for data access in the domain and service layer — the self-imposed simplicity is what stops coupling.
  - Why it works: "If we had infinite memory in our laptops, we'd have no need for clumsy databases." The repository fakes that world.
  - Note on the missing methods: `delete` is usually a soft-delete (`batch.cancel()`); `update` is handled by the Unit of Work (Ch6). `list()` is added pragmatically.

- **Dependency-inverted ORM mapping (SQLAlchemy classical mapping)**: define the schema separately from the model and declare an explicit mapper between them.
  - When to use: whenever you want a persistence-ignorant domain model with SQLAlchemy.
  - How: build `Table` objects against a `MetaData`, then `mapper(model.OrderLine, order_lines)` inside a `start_mappers()` function. Call `start_mappers()` at startup — or never, in which case the model stays blissfully unaware of the database.
  - Payoff: you keep Alembic migrations and transparent querying by domain class, *and* purity.

- **Ports and Adapters, defined for Python**: the **port** is the interface between your application and what you're abstracting; the **adapter** is the implementation behind it.
  - In this chapter: `AbstractRepository` is the port; `SqlAlchemyRepository` and `FakeRepository` are the adapters.
  - Python caveat: there are no interfaces per se. If you use an ABC, that's the port. If not, the port is just "the duck type your adapters conform to" — the method names, argument names, and types.

- **The trade-off ritual**: every time the book introduces a pattern, it asks *"What do we get for this? And what does it cost us?"* — after Rich Hickey: "programmers know the benefits of everything and the trade-offs of nothing."

## Key Concepts

- **Persistence ignorance** — the domain model knows nothing about how data is loaded or persisted.
- **Onion architecture** — model on the "inside," dependencies flowing inward toward it. Same thing as hexagonal / ports-and-adapters / clean architecture; all boil down to the DIP.
- **Classical mapping** — SQLAlchemy's `mapper()`-based style, as opposed to `declarative_base()`.
- **Declarative syntax** — the typical SQLAlchemy tutorial style where model classes inherit from `Base` and are full of `Column` objects. Convenient, but the model now depends on the ORM.
- **Port** — the interface (ABC or duck type) your core application expects.
- **Adapter** — the concrete implementation behind the port.
- **FakeRepository** — an in-memory adapter backed by a `set`, used in tests.

## Mental Models

- **"If it's hard to fake, the abstraction is probably too complicated."** Building fakes for your abstractions is design feedback, not just test plumbing. `FakeRepository` is all one-liners — that's the signal the abstraction is right.
- **The Repository is not a new abstraction — it's *your* abstraction.** You're swapping SQLAlchemy's `session.query(Batch)` for `batches_repo.get()`. Same abstraction count; the difference is you control one of them.
- **Use the complexity graph to decide.** Cost-of-change rises steeply with domain complexity for ActiveRecord/ORM, and shallowly for a domain model with a Repository. The lines *cross*: for simple cases a decoupled model is more work. **If your app is just a CRUD wrapper around a database, you don't need a domain model or a repository.**
- **Think of ORM tests as scaffolding.** Write `test_orm.py` while you're getting the mapping right, then throw them away. Repository tests, by contrast, earn their keep long-term — especially when the object-relational map is non-trivial.
- **Practicality beats purity.** If your domain model strays far from OO, the ORM may fight you and you may have to bend the model. That's a trade-off, not a failure.

## Code Examples

**The inversion** — schema and mapper defined separately, ORM depending on model:

```python
# orm.py  — this module imports model; model imports nothing
from sqlalchemy import Column, Integer, String, Table, MetaData
from sqlalchemy.orm import mapper, relationship

import model

metadata = MetaData()

order_lines = Table(
    'order_lines', metadata,
    Column('id', Integer, primary_key=True, autoincrement=True),
    Column('sku', String(255)),
    Column('qty', Integer, nullable=False),
    Column('orderid', String(255)),
)

def start_mappers():
    lines_mapper = mapper(model.OrderLine, order_lines)
```
- **What it demonstrates**: call `start_mappers()` and you can load/save domain objects; never call it and the domain classes have no idea a database exists.

**The port and its two adapters:**

```python
# repository.py
class AbstractRepository(abc.ABC):
    @abc.abstractmethod
    def add(self, batch: model.Batch):
        raise NotImplementedError

    @abc.abstractmethod
    def get(self, reference) -> model.Batch:
        raise NotImplementedError


class SqlAlchemyRepository(AbstractRepository):
    def __init__(self, session):
        self.session = session

    def add(self, batch):
        self.session.add(batch)

    def get(self, reference):
        return self.session.query(model.Batch).filter_by(reference=reference).one()

    def list(self):
        return self.session.query(model.Batch).all()


class FakeRepository(AbstractRepository):
    def __init__(self, batches):
        self._batches = set(batches)

    def add(self, batch):
        self._batches.add(batch)

    def get(self, reference):
        return next(b for b in self._batches if b.reference == reference)

    def list(self):
        return list(self._batches)
```
- **What it demonstrates**: `@abc.abstractmethod` is what makes ABCs actually work in Python — it refuses instantiation of incomplete subclasses. And the fake is trivial: `fake_repo = FakeRepository([batch1, batch2, batch3])`.

**Note what's absent from `SqlAlchemyRepository`: `.commit()`.** Committing is deliberately the caller's responsibility. Ch6 explains why.

## Reference Tables

| Repository pattern + persistence ignorance | |
|---|---|
| **Pros** | **Cons** |
| Simple interface between storage and domain model | An ORM already buys you *some* decoupling |
| Easy to fake for unit tests; easy to swap storage entirely (Appendix C) | Maintaining ORM mappings by hand is extra work and extra code |
| Writing the model before persistence keeps focus on the business problem — no FKs or migrations until later | Any extra layer of indirection increases maintenance cost |
| Database schema is simple because you control the object→table mapping | Adds a "WTF factor" for Python programmers who've never seen it |

Which abstraction mechanism for the port?

| Mechanism | Use when |
|---|---|
| `abc.ABC` + `@abc.abstractmethod` | Teaching/documenting the interface; you run `pylint`/`mypy` to actually reap the benefit |
| Plain duck typing | Production reality — "a repository is any object that has `add(thing)` and `get(id)`" |
| PEP 544 `Protocol` | You want typing without inheritance; the "prefer composition over inheritance" option |

## Worked Example

**The endpoint, evolving.** The chapter's spine is one function getting progressively less coupled.

*Step 0 — pseudocode. What we know we'll need:*
```python
@flask.route.gubbins
def allocate_endpoint():
    line = OrderLine(request.params, ...)      # extract order line from request
    batches = ...                              # load all batches from the DB
    allocate(line, batches)                    # call our domain service
    return 201                                 # save the allocation back somehow
```

*Step 1 — the "normal" ORM way. Model inherits from `Base`, so the model depends on the ORM:*
```python
class OrderLine(Base):
    id = Column(Integer, primary_key=True)
    sku = Column(String(250))
    qty = Integer(String(250))
    order_id = Column(Integer, ForeignKey('order.id'))
    order = relationship(Order)
```
> "Can we really say this model is ignorant of the database? How can it be separate from storage concerns when our model properties are directly coupled to database columns?"

Django's ORM is the same story, more restrictively — model classes inherit from `models.Model`. Django has no classical-mapper equivalent; see Appendix D for how to invert it anyway.

*Step 2 — SQLAlchemy used directly in the endpoint. Model is pure now, but the endpoint knows about sessions:*
```python
def allocate_endpoint():
    session = start_session()
    line = OrderLine(request.json['orderid'], request.json['sku'], request.json['qty'])
    batches = session.query(Batch).all()
    allocate(line, batches)
    session.commit()
    return 201
```

*Step 3 — the repository. The endpoint no longer knows what a query is:*
```python
def allocate_endpoint():
    batches = SqlAlchemyRepository.list()
    lines = [OrderLine(l['orderid'], l['sku'], l['qty']) for l in request.params]
    allocate(lines, batches)
    session.commit()
    return 201
```
Still imperfect — instantiating the repository and the lingering `session.commit()` are exactly what Ch4 and Ch6 fix.

**The integration test that keeps its value:**
```python
def test_repository_can_retrieve_a_batch_with_allocations(session):
    orderline_id = insert_order_line(session)
    batch1_id = insert_batch(session, "batch1")
    insert_batch(session, "batch2")        # spurious batch, to prove we get the right one
    insert_allocation(session, orderline_id, batch1_id)

    repo = repository.SqlAlchemyRepository(session)
    retrieved = repo.get("batch1")

    expected = model.Batch("batch1", "GENERIC-SOFA", 100, eta=None)
    assert retrieved == expected           # Batch.__eq__ only compares reference
    assert retrieved.sku == expected.sku
    assert retrieved._purchased_quantity == expected._purchased_quantity
    assert retrieved._allocations == {model.OrderLine("order1", "GENERIC-SOFA", 12)}
```
Note the comment: because `Batch` is an *entity*, `==` only proves the reference matched. You must assert the other attributes explicitly. **This is the practical cost of identity equality from Ch1.**

## Anti-patterns

- **Declarative ORM base classes in the domain model.** `class OrderLine(Base)` couples your business rules to your persistence library.
- **Putting `.commit()` inside the repository.** Keep it with the caller (and eventually in the Unit of Work).
- **Reaching for a Repository in a CRUD app.** If it's a thin wrapper over a DB, you're paying the cost with no return.
- **Keeping ABCs you don't enforce.** The authors admit deleting ABCs from production code — "Python makes it too easy to ignore them, and they end up unmaintained and, at worst, misleading."
- **Keeping the throwaway ORM tests forever.** Once the Repository exists, they're redundant.

## Connects To
- **Ch 1**: the persistence-ignorant `Batch`/`OrderLine` model this chapter has to store, and the `__eq__` behavior that complicates repository tests.
- **Ch 4**: Service Layer — answers "how do we instantiate these repositories, and what does the Flask app actually look like?"
- **Ch 6**: Unit of Work — takes over `.commit()` and the `update` responsibility deliberately left out of the repository.
- **Ch 3**: the digression on *how* to choose abstractions like this one.
- **Appendix C**: swapping the whole infrastructure, made possible by this abstraction.
- **Appendix D**: applying dependency inversion and Repository to Django, which has no classical mapper.
- **DDD (Evans)**: Repository is a DDD building block; Java/C# colleagues will recognize it immediately.
