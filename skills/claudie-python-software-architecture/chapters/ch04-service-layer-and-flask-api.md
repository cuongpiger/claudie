# Chapter 4: Our First Use Case — Flask API and Service Layer

## Core Idea
Extract a **Service Layer** (a.k.a. orchestration layer or use-case layer) that sits between the web framework and the domain model. It owns *orchestration*; the domain owns *business logic*; Flask owns only *web stuff*. Combined with `FakeRepository`, it lets you test whole workflows as fast unit tests.

## Frameworks Introduced

- **Service Layer pattern**: one function per use case, capturing the orchestration that isn't web-specific and isn't domain logic.
  - When to use: **after you spot orchestration logic creeping into your controllers** — not before. Introducing it too early risks the Anemic Domain anti-pattern.
  - How — every service function follows the same four steps:
    1. Fetch some objects from the repository.
    2. Make checks/assertions about the request against the current state of the world.
    3. Call a domain service.
    4. If all is well, save/update any state you changed.
  - Why it works: those steps are the same whether the caller is a REST API, a CLI (Appendix C), or a test. Keeping them out of the controller means the use case has exactly one home.

- **Three-way separation of concerns**:
  | Concern | Lives in | Example |
  |---|---|---|
  | **Interfacing code** | Flask endpoint | parse JSON, HTTP status codes, per-request session |
  | **Orchestration logic** | Service layer | fetch batches, validate SKU, call domain, commit |
  | **Business logic** | Domain model | which batch to allocate to, `OutOfStock` |

- **Depend on abstractions, concretely**: `def allocate(line: OrderLine, repo: AbstractRepository, session) -> str`. The high-level module (service layer) depends on the port; the low-level detail (`SqlAlchemyRepository`) depends on the same port. Tests supply `FakeRepository`; production supplies `SqlAlchemyRepository`. *This is the concrete example promised in the Introduction for "details should depend on abstractions."*

- **The standard folder layout** — the project structure that makes the layers visible:
  ```
  .
  ├── config.py
  ├── domain/            # model.py; later exceptions.py, commands.py, events.py
  ├── service_layer/     # services.py; later unit_of_work.py, messagebus.py, handlers.py
  ├── adapters/          # orm.py, repository.py, later redis_client.py, email.py
  ├── entrypoints/       # flask_app.py, later redis_eventconsumer.py
  └── tests/
      ├── unit/          # test_batches.py, test_allocate.py, test_services.py
      ├── integration/   # test_orm.py, test_repository.py
      └── e2e/           # test_api.py
  ```
  - **adapters/** = secondary / driven / inward-facing adapters (things your app calls).
  - **entrypoints/** = primary / driving / outward-facing adapters (things that call your app).
  - **Ports** live in the same file as the adapters that implement them.

## Key Concepts

- **Application service (service layer)** — handles requests from the outside world and orchestrates an operation: get data → update the domain model → persist changes.
- **Domain service** — logic that belongs in the domain model but doesn't fit naturally in a stateful entity or value object (e.g. a `calculate_tax` function in a shopping cart).
- **Orchestration** — fetching from repositories, validating input against database state, handling errors, committing on the happy path.
- **Anemic Domain anti-pattern** — a domain model reduced to data bags because all the logic drifted into the service layer.
- **Ice-cream cone model** (Bob's term) — the inverted test pyramid: too many E2E tests, too few unit tests.
- **InvalidSku** — a *service-layer* exception, not a domain one. The domain doesn't know or care whether a SKU exists; that's a sanity check against database state.

## Mental Models

- **"Tests are an adapter for our domain too."** The service layer defines a clear API — a set of use cases — usable by any adapter without knowing anything about domain model classes: an HTTP API, a CLI, or the test suite.
- **Fat models, thin controllers is the cheap version.** You get much of the benefit of rich domain models by just pushing logic down out of controllers, *without* adding a layer in between. If your app is *purely* a web app, your view functions can be the single place that captures use cases.
- **Watch for the ice-cream cone.** Every time you're tempted to add another E2E test, ask whether it's really testing web stuff. `test_400_message_for_out_of_stock` isn't — it's testing orchestration, and it belongs at the service layer.
- **Split tests into two broad categories**: tests about *web stuff*, tested end to end; and tests about *orchestration stuff*, tested against the service layer in memory.
- **For read-only endpoints, do the simplest thing that can possibly work** — `repo.get()` right in the Flask handler. Reads and writes are genuinely different (Ch12).

## Code Examples

**The service function — this is the whole pattern:**

```python
# service_layer/services.py
class InvalidSku(Exception):
    pass


def is_valid_sku(sku, batches):
    return sku in {b.sku for b in batches}


def allocate(line: OrderLine, repo: AbstractRepository, session) -> str:
    batches = repo.list()                                   # 1. fetch
    if not is_valid_sku(line.sku, batches):                 # 2. check
        raise InvalidSku(f'Invalid sku {line.sku}')
    batchref = model.allocate(line, batches)                # 3. call domain service
    session.commit()                                        # 4. persist
    return batchref
```
- **What it demonstrates**: the four canonical steps, and the `AbstractRepository` type hint that makes the DIP explicit. Step 4 is still unsatisfying — the service layer is coupled to the DB session. Ch6 fixes it.

**Flask becomes thin — only web stuff:**

```python
# entrypoints/flask_app.py
@app.route("/allocate", methods=['POST'])
def allocate_endpoint():
    session = get_session()
    repo = repository.SqlAlchemyRepository(session)
    line = model.OrderLine(
        request.json['orderid'], request.json['sku'], request.json['qty'],
    )
    try:
        batchref = services.allocate(line, repo, session)
    except (model.OutOfStock, services.InvalidSku) as e:
        return jsonify({'message': str(e)}), 400

    return jsonify({'batchref': batchref}), 201
```
- **What it demonstrates**: per-request session management, parsing POST params, status codes, JSON. Nothing else.

**Fast service-layer unit tests, no database:**

```python
# tests/unit/test_services.py
class FakeSession:
    committed = False

    def commit(self):
        self.committed = True


def test_returns_allocation():
    line = model.OrderLine("o1", "COMPLICATED-LAMP", 10)
    batch = model.Batch("b1", "COMPLICATED-LAMP", 100, eta=None)
    repo = FakeRepository([batch])

    result = services.allocate(line, repo, FakeSession())

    assert result == "b1"


def test_error_for_invalid_sku():
    line = model.OrderLine("o1", "NONEXISTENTSKU", 10)
    batch = model.Batch("b1", "AREALSKU", 100, eta=None)
    repo = FakeRepository([batch])

    with pytest.raises(services.InvalidSku, match="Invalid sku NONEXISTENTSKU"):
        services.allocate(line, repo, FakeSession())


def test_commits():
    line = model.OrderLine('o1', 'OMINOUS-MIRROR', 10)
    batch = model.Batch('b1', 'OMINOUS-MIRROR', 100, eta=None)
    repo = FakeRepository([batch])
    session = FakeSession()

    services.allocate(line, repo, session)

    assert session.committed is True
```
- **What it demonstrates**: `FakeSession` is explicitly "only a temporary solution" — it disappears in Ch6 when the Unit of Work absorbs commit responsibility.

## Reference Tables

| Service layer: the trade-offs | |
|---|---|
| **Pros** | **Cons** |
| A single place to capture all use cases | If your app is *purely* a web app, controllers can already be that place |
| Domain logic sits behind an API, leaving you free to refactor | It's yet another layer of abstraction |
| Clean separation of "stuff that talks HTTP" from "stuff that talks allocation" | Too much logic here → **Anemic Domain** anti-pattern |
| With Repository + `FakeRepository`, you can test workflows above the domain layer without integration tests | "Fat models, thin controllers" gets you much of this for free |

| Test type | What it covers | How many |
|---|---|---|
| E2E (`tests/e2e/`) | Web stuff — real HTTP, real Postgres | **Two**: one happy path, one unhappy path |
| Service-layer unit (`tests/unit/test_services.py`) | Orchestration, in memory | The bulk |
| Domain unit (`tests/unit/test_batches.py`) | Business rules | The bulk |
| Integration (`tests/integration/`) | ORM mapping, repository ↔ DB | A handful |

## Worked Example

**Watching the E2E test count explode, then collapse.**

*Start:* one E2E test asserting the API returns the earliest batch.
```python
@pytest.mark.usefixtures('restart_api')
def test_api_returns_allocation(add_stock):
    sku, othersku = random_sku(), random_sku('other')
    earlybatch, laterbatch, otherbatch = random_batchref(1), random_batchref(2), random_batchref(3)
    add_stock([
        (laterbatch, sku, 100, '2011-01-02'),
        (earlybatch, sku, 100, '2011-01-01'),
        (otherbatch, othersku, 100, None),
    ])
    data = {'orderid': random_orderid(), 'sku': sku, 'qty': 3}
    r = requests.post(f'{config.get_api_url()}/allocate', json=data)
    assert r.status_code == 201
    assert r.json()['batchref'] == earlybatch
```
(`random_sku()` etc. use `uuid` so concurrent runs against a real DB don't collide.)

*Problem 1 — no commit.* The first implementation never persists. Proving it needs a **second** E2E test that allocates twice and checks the second order spills into batch 2.

*Problem 2 — error handling.* Out-of-stock and invalid-SKU each need a **third** and **fourth** E2E test, and Flask starts growing `is_valid_sku()` and a `try/except`:

```python
# flask_app.py — getting crufty
    if not is_valid_sku(line.sku, batches):
        return jsonify({'message': f'Invalid sku {line.sku}'}), 400
    try:
        batchref = model.allocate(line, batches)
    except model.OutOfStock as e:
        return jsonify({'message': str(e)}), 400
    session.commit()
```
> "Our Flask app is starting to look a bit unwieldy. And our number of E2E tests is starting to get out of control, and soon we'll end up with an inverted test pyramid."

*The move:* pull `is_valid_sku`, the domain call, and the commit into `services.allocate()`. Everything except genuinely-web concerns migrates down.

*End state — E2E tests back to exactly two:*
```python
def test_happy_path_returns_201_and_allocated_batch(add_stock): ...
def test_unhappy_path_returns_400_and_error_message(): ...
```
Two E2E tests, four service-layer unit tests, and the domain tests from Ch1. **Same coverage, seconds instead of minutes.**

## Anti-patterns

- **Adding a service layer before orchestration logic appears in controllers.** Premature; you'll get an anemic domain.
- **Pushing business logic into the service layer.** Which batch to allocate to belongs in `model.allocate()`, not `services.allocate()`.
- **Growing the E2E suite to cover orchestration and error handling.** That's the ice-cream cone.
- **Putting the SKU-existence check in the domain.** The domain doesn't know about the set of valid SKUs; that's a database-state sanity check, hence `services.InvalidSku`.

## Key Takeaways

1. **The service layer captures use cases**, one function per use case, following the same four steps every time.
2. **Type-hint the port, not the adapter** (`repo: AbstractRepository`) — that's what makes the DIP concrete and testable.
3. **Flask endpoints should be boring**: parse, delegate, translate exceptions into status codes.
4. **Distinguish application services from domain services.** Application service = a use case. Domain service = a business concept without a natural entity home. The application service often *calls* the domain service.
5. **Introduce the layer reactively**, when orchestration starts leaking into controllers — not on principle.
6. **Folder structure is documentation.** `domain/`, `service_layer/`, `adapters/`, `entrypoints/` tells a newcomer where everything belongs.
7. **Two E2E tests is a target, not an accident.** Everything else moves down the pyramid.

## Connects To
- **Ch 2**: `FakeRepository` and `AbstractRepository` are what make the service layer testable; this chapter answers "how do we instantiate these repositories?"
- **Ch 3**: this is the FCIS split at architectural scale — domain = functional core, service layer = the edge-to-edge entrypoint with injected dependencies.
- **Ch 5**: fixes the remaining coupling — the service layer's API is still expressed in `OrderLine` objects; primitives decouple it.
- **Ch 6**: Unit of Work removes the `session` parameter and `FakeSession`.
- **Ch 12**: reads vs writes, and why `repo.get()` in the handler is fine for queries.
- **Appendix C**: the same service layer driven by a CLI instead of Flask — no changes to service or domain layers.
- **Appendix B**: how the authors spin up Flask + Postgres in containers for the E2E tests.
