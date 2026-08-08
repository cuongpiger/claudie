# Chapter 1: Domain Modeling

## Core Idea
Build the business layer as a **Domain Model** — plain Python objects and functions named in the business's own jargon (the *ubiquitous language*), with zero dependencies on frameworks, databases, or I/O. Behavior first; storage comes later.

## Frameworks Introduced

- **Domain Model pattern**: the part of your code closest to the business, most likely to change, and where you deliver the most value. Make it easy to understand and modify.
  - When to use: whenever business rules are non-trivial — i.e., whenever the customer wouldn't just use a spreadsheet.
  - How: (1) talk to domain experts, take notes, ask for *concrete examples* for every rule; (2) agree a glossary; (3) write unit tests whose names are the business rules; (4) implement plain classes/functions using those exact nouns and verbs.
  - Why it works: a nontechnical coworker can read `test_allocating_to_a_batch_reduces_the_available_quantity` and confirm it's correct. That's the whole point.

- **Value Object pattern**: any domain object uniquely identified by the data it holds, with no long-lived identity. Usually immutable.
  - When to use: a business concept that has data but no identity — an order *line*, a name, a sum of money.
  - How: `@dataclass(frozen=True)`, or `NamedTuple`, or `namedtuple`. You get **value equality** and a safe `__hash__` for free.
  - Failure mode: making everything a value object. If the thing survives changes to its own attributes, it's an entity.

- **Entity**: a domain object with long-lived identity, whose attributes may vary over time while it stays the same thing.
  - When to use: a `Batch`, a `Person`, an `Order` — anything with a reference/ID that outlives its data.
  - How: implement `__eq__` comparing *only* the identity attribute; base `__hash__` on that same read-only attribute (or set `__hash__ = None` to make it unhashable).
  - Rule: never modify `__hash__` without also modifying `__eq__`.

- **Domain Service (function)**: a business operation with no natural home in an entity or value object.
  - When to use: "sometimes, it just isn't a thing" (Evans). A thing that allocates a line given a set of batches sounds like a *function*.
  - How: write a module-level function, not a `FooManager` class. Python is multiparadigm — let the verbs be functions.
  - Note: a **domain** service ≠ a **service-layer** service. A domain service is a business concept/process; a service-layer service is an application use case. The service layer often *calls* a domain service.

- **Domain Exception**: exceptions named in the ubiquitous language express domain concepts.
  - When to use: the domain expert has a word for the failure ("out of stock").
  - How: `class OutOfStock(Exception)`, raised from the domain service — not `ValueError`, not `RuntimeError`.

## Key Concepts

- **Ubiquitous language** — the business jargon, used verbatim as class, method, variable, and test names.
- **SKU** — stock-keeping unit; identifies a product ("skew").
- **Batch** — a shipment of stock with a reference, SKU, purchased quantity, and an ETA. An *entity*.
- **OrderLine** — a SKU + quantity within an order. A *value object*.
- **Allocation** — assigning an order line to a batch, reducing that batch's available quantity.
- **Value equality** — two objects are equal iff all their data matches.
- **Identity equality** — two objects are equal iff their identity attribute matches, regardless of other data.
- **Persistence ignorance** — the domain model knows nothing about how it's stored.

## Mental Models

- **Think of the domain model as the business owner's mental map**, rendered in code. Business people already navigate these maps — you can tell because they use jargon. Jargon arises naturally among people collaborating on complex systems (the alien-spaceship thought experiment: "press the red button near the flashing doohickey" becomes "start landing sequence" within months).
- **A model is a simplification that's useful for a purpose.** Your intuition about a thrown ball is a model; it fails near light speed. That doesn't make it wrong — it means some predictions fall outside its domain.
- **Use `Name` vs `Person` as the entity/value litmus test.** Change a letter in `Name("Harry", "Percival")` and you have a *different name*. Change a person's name and you still have the *same person*.
- **For every `FooManager`, `BarBuilder`, or `BazFactory`, there's a more expressive `manage_foo()`, `build_bar()`, or `get_baz()` waiting to happen.**
- **Magic methods let domain semantics ride on idiomatic Python.** Implementing `__gt__` on `Batch` (in-stock sorts before shipments; earlier ETA sorts first) means the domain service can just call `sorted(batches)`.

## Code Examples

The finished `Batch` entity — note the calculated property and the `set` of allocations:

```python
class Batch:
    def __init__(self, ref: str, sku: str, qty: int, eta: Optional[date]):
        self.reference = ref
        self.sku = sku
        self.eta = eta
        self._purchased_quantity = qty
        self._allocations = set()  # type: Set[OrderLine]

    def allocate(self, line: OrderLine):
        if self.can_allocate(line):
            self._allocations.add(line)

    def deallocate(self, line: OrderLine):
        if line in self._allocations:
            self._allocations.remove(line)

    @property
    def allocated_quantity(self) -> int:
        return sum(line.qty for line in self._allocations)

    @property
    def available_quantity(self) -> int:
        return self._purchased_quantity - self.allocated_quantity

    def can_allocate(self, line: OrderLine) -> bool:
        return self.sku == line.sku and self.available_quantity >= line.qty

    def __eq__(self, other):
        if not isinstance(other, Batch):
            return False
        return other.reference == self.reference

    def __hash__(self):
        return hash(self.reference)

    def __gt__(self, other):
        if self.eta is None:
            return False
        if other.eta is None:
            return True
        return self.eta > other.eta
```
- **What it demonstrates**: entity identity equality on `.reference`; `available_quantity` derived rather than stored; using a `set` makes allocation idempotent for free; `__gt__` encodes the "prefer in-stock, then earliest ETA" business rule.

The value object and the domain service:

```python
@dataclass(frozen=True)
class OrderLine:
    orderid: str
    sku: str
    qty: int


class OutOfStock(Exception):
    pass


def allocate(line: OrderLine, batches: List[Batch]) -> str:
    try:
        batch = next(b for b in sorted(batches) if b.can_allocate(line))
        batch.allocate(line)
        return batch.reference
    except StopIteration:
        raise OutOfStock(f'Out of stock for sku {line.sku}')
```
- **What it demonstrates**: `frozen=True` gives value equality + hashability; the domain service is a plain function; `StopIteration` from `next()` is translated into a domain-language exception.

## Reference Tables

| | Value Object | Entity |
|---|---|---|
| Identified by | Its data | A long-lived reference/ID |
| Mutable? | No — make it immutable | Yes — attributes vary over time |
| Equality | Value equality (all attributes) | Identity equality (`.reference`) |
| Python idiom | `@dataclass(frozen=True)`, `NamedTuple`, `namedtuple`, `attrs` | Plain class + explicit `__eq__` / `__hash__` |
| `__hash__` from | All value attributes (free with `frozen=True`) | The identity attribute only — or `None` |
| Example | `OrderLine`, `Name`, `Money` | `Batch`, `Person`, `Order` |

## Worked Example

**From business conversation to model, the whole loop.** The authors' notes from the domain-expert conversation:

> A product is identified by a **SKU**. Customers place **orders**, identified by an **order reference**, comprising multiple **order lines**, each with a SKU and a quantity (e.g. 10 units of RED-CHAIR). The purchasing department orders small **batches** of stock; a batch has a unique ID (**reference**), a SKU, and a quantity. We **allocate** order lines to batches; when we do, available quantity drops. We can't allocate to a batch with insufficient available quantity, and we prefer to allocate to in-stock (warehouse) batches over shipments with an **ETA**; among shipments, we prefer the earliest ETA.

Each rule becomes a test whose *name is the rule*, and the tests drive the model out:

```python
def make_batch_and_line(sku, batch_qty, line_qty):
    return (
        Batch("batch-001", sku, batch_qty, eta=date.today()),
        OrderLine("order-123", sku, line_qty),
    )

def test_allocating_to_a_batch_reduces_the_available_quantity():
    batch = Batch("batch-001", "SMALL-TABLE", qty=20, eta=date.today())
    line = OrderLine('order-ref', "SMALL-TABLE", 2)
    batch.allocate(line)
    assert batch.available_quantity == 18

def test_cannot_allocate_if_skus_do_not_match():
    batch = Batch("batch-001", "UNCOMFORTABLE-CHAIR", 100, eta=None)
    different_sku_line = OrderLine("order-123", "EXPENSIVE-TOASTER", 10)
    assert batch.can_allocate(different_sku_line) is False

def test_allocation_is_idempotent():
    batch, line = make_batch_and_line("ANGULAR-DESK", 20, 2)
    batch.allocate(line)
    batch.allocate(line)
    assert batch.available_quantity == 18

def test_prefers_current_stock_batches_to_shipments():
    in_stock_batch = Batch("in-stock-batch", "RETRO-CLOCK", 100, eta=None)
    shipment_batch = Batch("shipment-batch", "RETRO-CLOCK", 100, eta=tomorrow)
    line = OrderLine("oref", "RETRO-CLOCK", 10)
    allocate(line, [in_stock_batch, shipment_batch])
    assert in_stock_batch.available_quantity == 90
    assert shipment_batch.available_quantity == 100

def test_raises_out_of_stock_exception_if_cannot_allocate():
    batch = Batch('batch1', 'SMALL-FORK', 10, eta=today)
    allocate(OrderLine('order1', 'SMALL-FORK', 10), [batch])
    with pytest.raises(OutOfStock, match='SMALL-FORK'):
        allocate(OrderLine('order2', 'SMALL-FORK', 1), [batch])
```

**The design pressure that forced the refactor:** the first `Batch` just decremented an integer `available_quantity`. That was fine until `test_can_only_deallocate_allocated_lines` — deallocating a line that was never allocated must be a no-op. An integer can't know that. Only then did the model gain `_allocations: Set[OrderLine]` and turn `available_quantity` into a derived property. **Let the tests drive the model's shape; don't design it up front.**

## Key Takeaways

1. **Name everything in the ubiquitous language** — classes, methods, variables, tests, *and exceptions*. If a domain expert can't read your test names, the model is wrong.
2. **Distinguish entities from value objects deliberately.** Value objects: immutable, value equality. Entities: identity equality on a stable reference. Getting this wrong corrupts equality and hashing throughout the app.
3. **Not everything has to be an object.** Python is multiparadigm — let the verbs be module-level functions. Domain services are functions.
4. **Derive, don't store.** `available_quantity` as a property over `_allocations` beats an integer you have to keep in sync.
5. **Let tests drive the model's shape.** The `deallocate` test is what forced `_allocations` into existence.
6. **Use magic methods to make the domain idiomatic** — `__gt__` so `sorted(batches)` encodes the allocation preference rule.
7. **Apply your best OO design principles here** — SOLID, "has-a vs is-a", prefer composition over inheritance. This is the layer that earns it.
8. **The domain model is deliberately persistence-ignorant.** "We have a domain service we can use for our first use case. But first we'll need a database…"

## Anti-patterns

- **Designing the database schema first.** Behavior should come first and drive storage requirements.
- **`FooManager` / `BarBuilder` / `BazFactory`** where a function would do.
- **Silently failing domain methods.** The authors flag that `allocate()` and `deallocate()` failing silently is "a little disconcerting" — a real model would raise.
- **Generic exceptions for domain failures.** `OutOfStock`, not `ValueError`.
- **`typing.NewType` over-application** — wrapping every primitive (`Quantity = NewType("Quantity", int)`) is shown, then disavowed: *"It is appalling. Please, please don't do this. —Harry"*

## Connects To
- **Ch 2**: the Repository pattern, which lets us persist this model without it knowing about the database.
- **Ch 7**: aggregates and consistency boundaries — `Product` becomes the aggregate over `Batch`, and the `allocate` domain service moves onto it.
- **Ch 4**: the service layer, and why a domain service differs from a service-layer service.
- **Appendix E**: validation — including the "should `Batch` check that the SKU matches?" question deliberately deferred here.
- **DDD (Evans, *Domain-Driven Design*)**: Entity, Value Object, Domain Service, and ubiquitous language all come from the blue book. This is explicitly *not* a DDD book — read Evans, or Vernon's red book.
