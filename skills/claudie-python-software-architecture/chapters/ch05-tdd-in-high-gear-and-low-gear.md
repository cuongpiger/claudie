# Chapter 5: TDD in High Gear and Low Gear

## Core Idea
Tests trade **coupling against design feedback**. Domain tests give maximum feedback but glue the design in place; service-layer tests give lower coupling and higher coverage. Shift gears deliberately: low gear (domain tests) to overcome inertia on new or gnarly work, high gear (service-layer tests) for everything else.

## Frameworks Introduced

- **The test spectrum** — every test sits somewhere on one axis:
  ```
  | Low feedback                                        High feedback |
  | Low barrier to change                      High barrier to change |
  | High system coverage                             Focused coverage |
  |  <---------                                          ----------> |
  |  API Tests            Service-Layer Tests            Domain Tests |
  ```
  - When to use: whenever deciding *where* to put a new test.
  - How to read it: API tests survive a total rewrite (as long as URLs and formats hold) but tell you nothing about object design. Domain tests guide the design and read as living documentation — but you must delete or replace them when you improve that design.

- **High gear / low gear** (the bicycle metaphor):
  - **Low gear = domain-model tests.** Use when *starting a new project* or *hitting a particularly gnarly problem*. You need feedback and executable documentation of intent to overcome inertia.
  - **High gear = service-layer tests.** Use most of the time — adding a feature, fixing a bug, writing `add_stock` or `cancel_order`. Lower coupling, higher coverage, faster.
  - Shift back down whenever you hit a steep hill.

- **Fully decoupling service tests from the domain** — a three-step ladder, each rung optional:
  1. **Express the service layer in primitives.** `allocate(orderid: str, sku: str, qty: int, ...)` instead of `allocate(line: OrderLine, ...)`.
  2. **Push remaining domain construction into fixtures/factories.** e.g. `FakeRepository.for_batch(ref, sku, qty, eta)` — at least all domain dependencies live in one place.
  3. **Add the missing service.** Write `add_batch()` so tests set up state through the official use cases, with zero domain imports.

- **Rules of Thumb for Different Types of Test**:
  1. **Aim for one end-to-end test per feature** — demonstrate the feature works and the moving parts are glued together.
  2. **Write the bulk of your tests against the service layer** — edge-to-edge, fakes for I/O, one code path each. This is where you exhaustively cover edge cases and business-logic ins and outs.
  3. **Maintain a small core of domain-model tests** — highest feedback, most brittle. *Don't be afraid to delete these when the functionality is later covered at the service layer.*
  4. **Error handling counts as a feature** — structure the app so all errors bubbling to the entrypoint are handled the same way. Then you test only the happy path per feature, plus **one** E2E test for all unhappy paths (and many unhappy-path unit tests).

## Key Concepts

- **Design feedback** — what a test tells you about whether your objects are well-shaped. Only available when working closely with the target code.
- **Coupling (of tests)** — how many tests must change when you refactor the implementation.
- **Living documentation** — domain tests written in the ubiquitous language let a new team member learn how core concepts interrelate.
- **"Listen to the code"** — the XP exhortation. If a test is hard to write, that's a trigger to refactor and reconsider the design.
- **Primitives-based service API** — service functions taking `str`/`int`/`date` rather than domain objects.
- **Combinatorial explosion** — the valid concern about high-level testing: complex use cases may need many service-layer tests. That's when you drop down to lower-level unit tests of collaborating domain objects.

## Mental Models

- **"Every line of code that we put in a test is like a blob of glue, holding the system in a particular shape. The more low-level tests we have, the harder it will be to change things."** This is the single most quotable line of the chapter and the reason to prefer high gear.
- **Tests enforce that a property doesn't change while you work.** The flip side: if you want to change the *design*, any test relying directly on that code will also fail. That's not a bug in the tests — it's the price of the feedback they gave you.
- **Restricting yourself to service-layer tests means no tests touch "private" methods or attributes on model objects**, which leaves you free to refactor them.
- **"If you find yourself needing to do domain-layer stuff directly in your service-layer tests, it may be an indication that your service layer is incomplete."** The missing `add_batch` service was discovered exactly this way.
- **Don't write a service just to help your tests** — but do notice when the test pain is pointing at a service you'd need eventually anyway. `add_batch` qualified; the authors say so explicitly.
- **Harry's light-bulb moment:** "Having worked in places where the E2E test build would take hours ('wait 'til tomorrow,' essentially), I can't tell you what a difference it makes to be able to run all your tests in minutes or seconds."

## Code Examples

**The same behavior, tested in low gear and high gear:**

```python
# LOW GEAR — domain-layer test. Max feedback, max coupling.
def test_prefers_current_stock_batches_to_shipments():
    in_stock_batch = Batch("in-stock-batch", "RETRO-CLOCK", 100, eta=None)
    shipment_batch = Batch("shipment-batch", "RETRO-CLOCK", 100, eta=tomorrow)
    line = OrderLine("oref", "RETRO-CLOCK", 10)

    allocate(line, [in_stock_batch, shipment_batch])

    assert in_stock_batch.available_quantity == 90
    assert shipment_batch.available_quantity == 100


# HIGH GEAR — service-layer test. Same assertion, one layer up.
def test_prefers_warehouse_batches_to_shipments():
    in_stock_batch = Batch("in-stock-batch", "RETRO-CLOCK", 100, eta=None)
    shipment_batch = Batch("shipment-batch", "RETRO-CLOCK", 100, eta=tomorrow)
    repo = FakeRepository([in_stock_batch, shipment_batch])
    session = FakeSession()
    line = OrderLine('oref', "RETRO-CLOCK", 10)

    services.allocate(line, repo, session)

    assert in_stock_batch.available_quantity == 90
    assert shipment_batch.available_quantity == 100
```

**The service layer, re-expressed in primitives, plus the missing service:**

```python
# service_layer/services.py
def add_batch(
    ref: str, sku: str, qty: int, eta: Optional[date],
    repo: AbstractRepository, session,
):
    repo.add(model.Batch(ref, sku, qty, eta))
    session.commit()


def allocate(
    orderid: str, sku: str, qty: int, repo: AbstractRepository, session
) -> str:
    ...
```
- **What it demonstrates**: `add_batch` is two lines, and it's the key that unlocks fully decoupled tests.

**The destination — service tests with zero domain imports:**

```python
def test_allocate_returns_allocation():
    repo, session = FakeRepository([]), FakeSession()
    services.add_batch("batch1", "COMPLICATED-LAMP", 100, None, repo, session)

    result = services.allocate("o1", "COMPLICATED-LAMP", 10, repo, session)

    assert result == "batch1"


def test_allocate_errors_for_invalid_sku():
    repo, session = FakeRepository([]), FakeSession()
    services.add_batch("b1", "AREALSKU", 100, None, repo, session)

    with pytest.raises(services.InvalidSku, match="Invalid sku NONEXISTENTSKU"):
        services.allocate("o1", "NONEXISTENTSKU", 10, repo, FakeSession())
```
- **What it demonstrates**: no `model.Batch`, no `model.OrderLine`. "Our service-layer tests depend on only the service layer itself, leaving us completely free to refactor the model as we see fit."

## Reference Tables

| | Domain tests | Service-layer tests | API / E2E tests |
|---|---|---|---|
| Feedback on design | **Highest** | Medium | None |
| Coupling to implementation | **Highest** | Medium | Lowest |
| Coverage per test | Focused | Broad | Whole system |
| Speed | Fastest | Fast | Slow |
| Survives a domain refactor? | No | Yes | Yes |
| How many? | A small core | **The bulk** | One per feature + one unhappy path |
| Use when | New project; gnarly problem | Everything else | Proving the parts are glued together |

**The pyramid achieved in this chapter:**

```
$ grep -c test_ test_*.py
tests/unit/test_allocate.py:4
tests/unit/test_batches.py:8
tests/unit/test_services.py:3     →  15 unit tests
tests/integration/test_orm.py:6
tests/integration/test_repository.py:2  →   8 integration tests
tests/e2e/test_api.py:2           →   2 end-to-end tests
```

## Worked Example

**Removing the last dependency, and the payoff cascading up to E2E.**

*Rung 1 — primitives.* Change the signature:
```python
# before
def allocate(line: OrderLine, repo: AbstractRepository, session) -> str:
# after
def allocate(orderid: str, sku: str, qty: int, repo: AbstractRepository, session) -> str:
```
Tests improve, but still `model.Batch(...)` in the setup — so a `Batch` refactor still breaks them.

*Rung 2 — fixture factory.* Corral the domain dependency into one place:
```python
class FakeRepository(set):
    @staticmethod
    def for_batch(ref, sku, qty, eta=None):
        return FakeRepository([model.Batch(ref, sku, qty, eta)])

def test_returns_allocation():
    repo = FakeRepository.for_batch("batch1", "COMPLICATED-LAMP", 100, eta=None)
    result = services.allocate("o1", "COMPLICATED-LAMP", 10, repo, FakeSession())
    assert result == "batch1"
```

*Rung 3 — add the missing service.* Now setup goes through the official use case, and the domain import vanishes entirely:
```python
def test_add_batch():
    repo, session = FakeRepository([]), FakeSession()
    services.add_batch("b1", "CRUNCHY-ARMCHAIR", 100, None, repo, session)
    assert repo.get("b1") is not None
    assert session.committed
```

*The cascade to E2E.* Adding `add_batch` as an endpoint kills the `add_stock` fixture and its hardcoded SQL:
```python
@app.route("/add_batch", methods=['POST'])
def add_batch():
    session = get_session()
    repo = repository.SqlAlchemyRepository(session)
    eta = request.json['eta']
    if eta is not None:
        eta = datetime.fromisoformat(eta).date()
    services.add_batch(
        request.json['ref'], request.json['sku'], request.json['qty'], eta,
        repo, session,
    )
    return 'OK', 201
```
```python
def post_to_add_batch(ref, sku, qty, eta):
    r = requests.post(f'{config.get_api_url()}/add_batch',
                      json={'ref': ref, 'sku': sku, 'qty': qty, 'eta': eta})
    assert r.status_code == 201


def test_happy_path_returns_201_and_allocated_batch():
    sku, othersku = random_sku(), random_sku('other')
    earlybatch, laterbatch, otherbatch = random_batchref(1), random_batchref(2), random_batchref(3)
    post_to_add_batch(laterbatch, sku, 100, '2011-01-02')
    post_to_add_batch(earlybatch, sku, 100, '2011-01-01')
    post_to_add_batch(otherbatch, othersku, 100, None)
    ...
```
**The E2E tests now have no dependency other than the API itself** — no SQL, no direct database access. (The authors note `POST /add_batch` isn't very RESTful and shrug: Flask is a thin adapter, so making it `POST /batches` would be trivial.)

## Anti-patterns

- **Writing too many tests against the domain model.** Teams do this, then find a refactor requires updating tens or hundreds of unit tests.
- **Hacking test state via repositories or raw SQL** instead of through service-layer use cases.
- **Treating domain tests as permanent.** They're sketches — "we often 'sketch' new behaviors by writing tests at this level to see how the code might look." Delete them when the design moves on.
- **Testing every unhappy path end to end.** Handle errors uniformly at the entrypoint, then one E2E unhappy-path test covers the lot.

## Key Takeaways

1. **Coupling vs. design feedback is the central trade-off.** There is no universally correct test level — only a correct level for what you're doing right now.
2. **Default to high gear** (service-layer tests). Drop to low gear (domain tests) for new projects and hard problems.
3. **Express services in primitives.** It's what makes full decoupling possible.
4. **Test pain that points at a missing service is real signal** — but write the service because you need it, not because your tests hurt.
5. **Delete domain tests once the service layer covers the behavior.** Brittle high-feedback tests have served their purpose.
6. **One E2E test per feature; one E2E test for all unhappy paths.**
7. **A healthy pyramid is achievable**: 15 unit / 8 integration / 2 E2E in this chapter's codebase.

## Connects To
- **Ch 1**: the domain tests written in low gear, which this chapter argues you may now delete.
- **Ch 3**: "edge-to-edge testing" and the fakes-over-mocks argument — service-layer tests are edge-to-edge tests.
- **Ch 4**: the service layer this chapter tests against, and the `FakeSession` it still uses.
- **Ch 6**: Unit of Work, which removes `FakeSession` and the `session` parameter from every signature above.
- **Ch 8** and *"Optionally: Unit Testing Event Handlers in Isolation with a Fake Message Bus"*: the answer to combinatorial explosion at high levels.
- **XP / "listen to the code"**: the underlying practice this chapter operationalizes.
