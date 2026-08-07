# Chapter 6: Architectural Design Patterns

## Core Idea

Architectural patterns are templates for whole-system problems, not object-level ones. They buy scalability, maintainability, and reusability by deciding where boundaries go: between UI and logic (MVC), between deployable units (Microservices), between your code and infrastructure (Serverless), and between current state and its history (Event Sourcing).

## Frameworks Introduced

- **MVC (Model-View-Controller)**: Application of loose coupling and separation of concerns. Splits an app into model (business logic, data, state, rules), view (visual representation only), and controller (glue — all model↔view communication passes through it). Drop the controller and you lose the ability to attach multiple views without touching the model.
  - When to use: Any app where UI and logic evolve separately; graphic designers and programmers work in parallel; you want to add views (terminal, GUI, PDF, pie chart) cheaply. Every popular web framework (Django, Rails, Symfony, Yii) and app framework (iPhone SDK, Android, QT) uses MVC or a variant (MVA, MVP, MVT).
  - How: Implement from scratch — smart model, thin controller, dumb view. Model owns validation/state/data access and does not depend on UI. Controller updates model on user action and view on model change, but never displays data, never touches app data directly, never holds business rules. View displays and accepts interaction, does minimal template-level processing, stores nothing.
  - Real-world example: A restaurant — waiters take orders and serve (view/controller), chefs cook (model). Django names them differently: controller = *view*, view = *template*, hence Model-View-Template (MVT). Web2py embraces plain MVC.

- **Microservices**: A monolith with one codebase can't keep up with pressure for fast time-to-market, reactivity, and independent scaling. Build the application as a set of loosely coupled, collaborating, independently deployable services communicating over well-defined APIs (order management service, customer management service, PaymentService, OrderService, AccountService).
  - When to use: at least one of — you must support different clients (desktop and mobile); you expose an API to third parties; you communicate with other applications via messaging; you serve requests by hitting a database and other systems and returning JSON/XML/HTML/PDF; the app has logical components matching distinct functional areas.
  - How: Containers are mandatory, not optional — one service may need a relational DB, another ElasticSearch, another MySQL, another Redis; Docker packs app server, dependencies, runtime libs, compiled code, and config per service. You can build services directly with Django, Flask, or FastAPI. The chapter's transport is **gRPC** (`grpcio`, `grpcio-tools`), a high-performance universal RPC framework using **Protocol Buffers (protobuf)** as its IDL — efficient and cross-language. Compile `.proto` with `protoc` via `grpc_tools`, subclass the generated `*Servicer`, serve with `grpc.server(ThreadPoolExecutor(max_workers=10))`. For LLM-backed microservices, use **Lanarky** (`lanarky[openai]==0.8.6`, `uvicorn==0.29.0`), a web framework built on FastAPI, with `Lanarky`, `OpenAIAPIRouter`, `ChatCompletionResource`, and `StreamingClient`.
  - Real-world example: Netflix (millions of simultaneous content streams), Uber (billing, notifications, ride tracking), Amazon (monolith → microservices to support growing scale).

- **Serverless**: Abstracts server management away; you ship code, the cloud provider handles scaling and execution driven by event triggers (HTTP requests, file uploads, database modifications). You pay only for compute time consumed.
  - When to use: (1) event-driven architectures where a function runs in response to an event — image cropping/resizing, dynamic PDF generation; (2) as the unit of a Microservices architecture, each microservice being a serverless function.
  - How: **AWS Lambda** — write a `lambda_handler(event, context)`. Test locally instead of deploying to AWS: **LocalStack** (`pip install localstack`, runs in Docker via `localstack start -d`), zip the handler, deploy and invoke with **awslocal** (`awscli-local`, plus `awscli`). `awslocal lambda create-function-url-config` produces an invocable URL you can hit with cURL.
  - Real-world example: automated data backups to cloud storage; image processing on upload; PDF receipt generation emailed to the customer after an e-commerce purchase.

- **Event Sourcing**: Stores state changes as a sequence of immutable events instead of overwriting state. Application state can be reconstructed at any point in time by replaying events, and you get an audit trail for free. Best where state and transition rules are complex.
  - When to use: financial transactions (every deposit/withdrawal/transfer as a distinct event → transparent, auditable, secure ledger); inventory management (item lifecycle, stock levels, usage patterns, recall tracing); customer behavior tracking (browsing, cart changes, purchases, returns feeding personalization and recommendations).
  - How: Three components — **Event** (type + data, immutable once applied), **Aggregate** (object or group representing one unit of business logic that records each change), **Event store** (the collection of all events). Manual version: a plain class holding `balance` and `events`, with `apply_event()`. Library version: the **eventsourcing** package — subclass `Aggregate`, decorate mutating methods with `@event("Name")`, subclass `Application` and call `self.save(aggregate)` (collects pending events into the application's event store), read back through `self.repository.get(id)` and `app.notification_log.select(...)`.
  - Real-world example: audit trails for compliance, collaborative document editing, undo/redo.

## Key Concepts

- Every view typically needs its own controller; that's what keeps the model reusable across views.
- gRPC-generated `payment_pb2.py` and `payment_pb2_grpc.py` are never hand-edited — regenerate them.
- gRPC vs REST: REST over HTTP wins when human readability or web integration matters; gRPC wins on performance and streaming requests/responses.
- Pass secrets (e.g. `OPENAI_API_KEY`) via a shell environment variable, not a literal in source.
- Version pins that matter: Lanarky 0.8.6 and LocalStack were not Python 3.12 compatible at the time of writing — use Python 3.11. Lambda runtime in the example is `python3.11`.
- Other architectural patterns worth knowing: **Event-Driven Architecture (EDA)** (production, detection, consumption of, and reaction to events in real time), **CQRS** (separate read and write models), **Clean Architecture** (business logic encapsulated and separated from the interfaces exposing it, decoupled via dependency inversion).

## Mental Models

- MVC self-test: if your GUI isn't skinnable at runtime, or adding a chart/PDF view isn't just "new controller + view, model untouched", your MVC is wrong.
- Smart model, thin controller, dumb view — three rules, memorize them instead of the diagram.
- Microservices multiply operational surface: going from one app to many services makes the number of things to manage grow exponentially, which is why containers arrive with the pattern.
- Event Sourcing inverts the default: state is a fold over events, not a mutable cell. Adding a new event type or changing how one is handled touches little else.

## Anti-patterns

- Skipping the controller in MVC — model and view couple directly and multiple views become impossible to do cleanly.
- Model with UI dependencies, controller that displays data or holds business rules, view that stores data or reaches into the application data — each breaks the pattern's payoff.
- Microservices without containers — dependency divergence (MySQL here, Redis there, ElasticSearch elsewhere) makes a shared runtime untenable.
- Reaching for gRPC when human readability or plain web integration is what you actually need; REST is the better fit there.
- Adding complexity on top of a serverless function: "there's already enough to get right with the Serverless architecture itself and AWS Lambda's deployment details."
- Hand-rolling event storage/querying/processing for a complex system when a library already provides it.

## Code Examples

```python
class QuoteTerminalController:
    def __init__(self):
        self.model = QuoteModel()
        self.view = QuoteTerminalView()

    def run(self):
        valid_input = False
        while not valid_input:
            try:
                n = self.view.select_quote()
                n = int(n)
                valid_input = True
            except ValueError as err:
                self.view.error(f"Incorrect index '{n}'")
        quote = self.model.get_quote(n)
        self.view.show(quote)
```
- **What it demonstrates**: thin controller — validates input, asks the model, hands the result to the view; displays nothing itself.

```protobuf
syntax = "proto3";

package payment;

// The payment service definition.
service PaymentService {
  // Processes a payment
  rpc ProcessPayment (PaymentRequest) returns (PaymentResponse) {}
}

// The request message containing payment details.
message PaymentRequest {
  string order_id = 1;
  double amount = 2;
  string currency = 3;
  string user_id = 4;
}

// The response message containing the result of the payment process.
message PaymentResponse {
  string payment_id = 1;
  string status = 2;  // e.g., "SUCCESS", "FAILED"
}
```
- **What it demonstrates**: the protobuf IDL contract that defines a microservice boundary before any Python exists.

```bash
# general form
python -m grpc_tools.protoc -I<PROTO_DIR> --python_out=<OUTPUT_DIR> --grpc_python_out=<OUTPUT_DIR> <PROTO_FILES>

# in ch06/microservices/grpc
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. payment.proto
```
- **What it demonstrates**: generating `payment_pb2.py` and `payment_pb2_grpc.py` (do not edit by hand).

```python
from concurrent.futures import ThreadPoolExecutor

import grpc
import payment_pb2
import payment_pb2_grpc


class PaymentServiceImpl(payment_pb2_grpc.PaymentServiceServicer):
    def ProcessPayment(self, request, context):
        return payment_pb2.PaymentResponse(payment_id="12345", status="SUCCESS")


def main():
    print("Payment Processing Service ready!")
    server = grpc.server(ThreadPoolExecutor(max_workers=10))
    payment_pb2_grpc.add_PaymentServiceServicer_to_server(PaymentServiceImpl(), server)
    server.add_insecure_port("[::]:50051")
    server.start()
    server.wait_for_termination()
```
- **What it demonstrates**: the service half of a gRPC microservice — subclass the generated servicer, register it on a thread-pool server, bind a port.

```python
import os

import uvicorn
from lanarky import Lanarky
from lanarky.adapters.openai.resources import ChatCompletionResource
from lanarky.adapters.openai.routing import OpenAIAPIRouter

app = Lanarky()
router = OpenAIAPIRouter()


@router.post("/chat")
def chat(stream: bool = True) -> ChatCompletionResource:
    system = "Here is your assistant"
    return ChatCompletionResource(stream=stream, system=system)


if __name__ == "__main__":
    app.include_router(router)
    uvicorn.run(app)
```
- **What it demonstrates**: an LLM microservice in ~15 lines — Lanarky supplies the streaming chat resource, FastAPI conventions supply the routing.

```python
import json


def lambda_handler(event, context):
    number = event["number"]
    squared = number * number
    return f"The square of {number} is {squared}."
```
```bash
localstack start -d
zip lambda.zip lambda_function_square.py
awslocal lambda create-function \
  --function-name lambda_function_square \
  --runtime python3.11 \
  --zip-file fileb://lambda.zip \
  --handler lambda_function_square.lambda_handler \
  --role arn:aws:iam::000000000000:role/lambda-role
awslocal lambda invoke --function-name lambda_function_square \
  --payload file://payload.json output.txt
awslocal lambda create-function-url-config \
  --function-name lambda_function_square \
  --auth-type NONE
```
- **What it demonstrates**: full local serverless loop — handler signature `(event, context)`, LocalStack in Docker, deploy/invoke/expose-URL without an AWS account.

## Reference Tables

| Pattern | Intent | When to use | Tooling / library used |
| --- | --- | --- | --- |
| MVC | Split app into model / view / controller so representation and logic vary independently | Multiple or changing UIs; parallel designer + developer work; skinnable GUI | Pure Python from scratch; Django (MVT), Web2py, Rails, Symfony, Yii |
| Microservices | Application as loosely coupled, independently deployable services with well-defined APIs | Many client types, third-party API, messaging, distinct functional areas | gRPC (`grpcio`, `grpcio-tools`), protobuf/`protoc`, Docker; Django/Flask/FastAPI; Lanarky 0.8.6 + uvicorn 0.29.0 for LLM services |
| Serverless | Run code on event triggers; provider owns scaling and servers | Event-driven work (image processing, PDF generation, backups); microservice-per-function | AWS Lambda, LocalStack, `awscli-local` (`awslocal`), `awscli`, Docker, cURL |
| Event Sourcing | Persist state changes as an immutable ordered event log; rebuild state by replay | Financial ledgers, inventory lifecycle, customer behavior, audit trails, undo/redo | Manual aggregate + event list; `eventsourcing` (`Aggregate`, `@event`, `Application`) |

## Worked Example

**Event Sourcing, end to end.** Start manual to see the machinery, then swap in the library.

Manual — the bank account (`ch06/event_sourcing/bankaccount.py`). `Account` is the aggregate; its `events` list *is* the event store; an event is a dict of type + amount. `apply_event()` is the only place state mutates, and it always records:

```python
class Account:
    def __init__(self):
        self.balance = 0
        self.events = []

    def apply_event(self, event):
        if event["type"] == "deposited":
            self.balance += event["amount"]
        elif event["type"] == "withdrawn":
            self.balance -= event["amount"]
        self.events.append(event)

    def deposit(self, amount):
        event = {"type": "deposited", "amount": amount}
        self.apply_event(event)

    def withdraw(self, amount):
        event = {"type": "withdrawn", "amount": amount}
        self.apply_event(event)
```

`deposit(100)`, `deposit(50)`, `withdraw(30)`, `deposit(30)` prints the four events then `Balance: 150`. Reasoning: balance is derivable — the log is the source of truth, the field is a cached fold. New operation types cost one `elif`, nothing else moves.

Library — inventory (`ch06/event_sourcing/inventory.py`). The `eventsourcing` package removes the hand-written store. `@event("Name")` turns a method call into a recorded, named event; `Application.save()` collects pending events off the aggregate into the store; `self.repository.get(item_id)` rehydrates an aggregate by replaying its events:

```python
from eventsourcing.domain import Aggregate, event
from eventsourcing.application import Application


class InventoryItem(Aggregate):
    @event("ItemCreated")
    def __init__(self, name, quantity=0):
        self.name = name
        self.quantity = quantity

    @event("QuantityIncreased")
    def increase_quantity(self, amount):
        self.quantity += amount

    @event("QuantityDecreased")
    def decrease_quantity(self, amount):
        self.quantity -= amount


class InventoryApp(Application):
    def create_item(self, name, quantity):
        item = InventoryItem(name, quantity)
        self.save(item)
        return item.id

    def increase_item_quantity(self, item_id, amount):
        item = self.repository.get(item_id)
        item.increase_quantity(amount)
        self.save(item)

    def decrease_item_quantity(self, item_id, amount):
        item = self.repository.get(item_id)
        item.decrease_quantity(amount)
        self.save(item)
```

Reading `app.notification_log.select(start=1, limit=5)` yields the persisted event states — timestamped JSON with `originator_topic`, `name`, `quantity`, then `amount` for each change. Same three components as the manual version; the library supplies storage, querying, and processing.

## Key Takeaways

- MVC's value is the controller: it's what lets you add a view without touching the model. Smart model, thin controller, dumb view.
- Microservices trade code-level simplicity for operational complexity — accept containers as part of the deal.
- Define the microservice contract first (`.proto`), generate the stubs, then write logic; the boundary is the artifact that matters.
- Serverless is for event-triggered work; keep the handler trivial and test locally with LocalStack rather than deploying to learn.
- Event Sourcing makes state a replayable derivation — audit trail, time travel, and undo/redo fall out of the design.
- CQRS, EDA, and Clean Architecture are the adjacent patterns to reach for next.

## Connects To

- **Chapter 5 (Behavioral)**: Observer underpins EDA; MVC's model→controller notification is Observer at architectural scale.
- **Chapter 4 (Structural)**: Facade and Adapter are how a microservice presents a stable API over messy internals; MVA is literally Adapter in the MVC slot.
- **Chapter 3 (Creational)**: aggregates in Event Sourcing are rebuilt by a factory-like replay rather than direct construction.
- **Chapter 7 (Concurrency & async)**: `ThreadPoolExecutor` behind the gRPC server and uvicorn's async loop behind Lanarky both come from there.
- **Clean Architecture / dependency inversion**: the generalization of MVC's "model does not depend on the UI" rule.
