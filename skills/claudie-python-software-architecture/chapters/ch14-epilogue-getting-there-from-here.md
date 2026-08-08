# Epilogue: What Now? — Getting There from Here

## Core Idea
"The code we've shown in this book isn't battle-hardened production code: it's a set of **Lego blocks** that you can play with to make your first house, spaceship, and skyscraper." This chapter covers how to apply the patterns to an *existing* ball of mud, and the footguns the book deliberately hand-waved.

## Frameworks Introduced

- **Start with the problem, not the pattern.** "First things first: what problem are you trying to solve? Is the software too hard to change? Is the performance unacceptable? Have you got weird, inexplicable bugs?" A clear goal lets you prioritize *and* communicate the reasons to the team. "Businesses tend to have pragmatic approaches to technical debt and refactoring, so long as engineers can make a reasoned argument for fixing things."

- **Architecture tax** (Bob's term): attach refactoring to feature work. "Perhaps you're launching a new product or opening your service to new markets? … With a six-month project to deliver, it's easier to make the argument for three weeks of cleanup work."

- **Step 1 — Build a service layer by enumerating use cases.** If you have a UI, what actions does it perform? If you have a backend component, each cron job or Celery job is probably one use case. **Give each an imperative name**: *Apply Billing Charges*, *Clean Abandoned Accounts*, *Raise Purchase Order*.
  Each use case should:
  1. Start its own database transaction if needed
  2. Fetch any required data
  3. Check any preconditions (see the *Ensure* pattern, Appendix E)
  4. Update the domain model
  5. Persist any changes

  Each should **succeed or fail as an atomic unit**.

- **Step 2 — Identify aggregates and break the object graph.** Replace direct object references with **identifiers**. `Document.parent_folder: int` instead of `Document.parent: Folder`.
  - **Tell**: "Bidirectional links are often a sign that your aggregates aren't right." If a `Document` knows its `Folder` and the `Folder` has a collection of `Document`s, traversal is easy but you can't think properly about consistency boundaries.
  - For **reads**, replace complex loops and transforms with straight SQL — the first step toward CQRS.
  - For **writes**, change one aggregate at a time and use the message bus: `SELECT id FROM workspace WHERE account_id = ?` then `for workspace_id in workspaces: bus.handle(LockWorkspace(workspace_id))`.

- **Step 3 — Strangler Fig + Event Interception** to carve out microservices. Three steps:
  1. **Raise events** representing the changes happening in the system you want to replace.
  2. **Build a second system** that consumes those events and builds its own domain model.
  3. **Replace** the older system with the new.

- **Walking skeleton**: "When deploying an event-driven system, start with a 'walking skeleton.' Deploying a system that just logs its input forces us to tackle all the infrastructural questions and start working in **production**." MADE's first production deployment received a `batch_created` event and logged its JSON — "the 'Hello World' of event-driven architecture."

## Key Concepts

- **Homogeneity** — the defining characteristic of a big ball of mud: every part looks the same because responsibilities were never made clear.
- **Event interception** — the technique behind the Strangler Fig migration.
- **View builder / view fetcher** split — for read-heavy systems with genuinely complex read logic (permissions and authorization especially). The *fetcher* reads data from the DB returning tuples/dicts; the *builder* filters and maps them; the API handles HTTP and serialization. Makes the builder easy to unit test with mocked data.
- **Outbox pattern** — mentioned as the fix for cross-transaction reliability.
- **Idempotency** — calling a handler repeatedly with the same message must not make repeated changes to state. "This is a key technique for building reliability, because it enables us to safely retry events when they fail."

## Mental Models

- **"It's never too late to start weeding an overgrown garden."**
- **Duplication beats a call chain, during migration.** "It's fine if you have duplication in the use-case functions. We're not trying to write perfect code; we're just trying to extract some meaningful layers. It's better to duplicate some code in a few places than to have use-case functions calling one another in a long chain."
- **Copy and paste, then clean.** "Your code is in a bad state now, so copy and paste it to a new place and then make that new code clean and tidy. Once you've done that, you can replace uses of the old code with calls to your new code and finally delete the mess."
- **"Fancy CQRS with event handlers is really a way of running our complex view logic whenever we write so that we can avoid running it when we read."** That single sentence is the clearest statement of what CQRS buys.
- **You do not need microservices for any of this.** "These techniques predate microservices by a decade or so. Aggregates, domain events, and dependency inversion are ways to control complexity in large systems. It just so happens that when you've built a set of use cases and a model for a business process, moving it to its own service is relatively easy, but that's not a requirement."
- **These are not an ascetic discipline.** "The techniques we're presenting in this book are intended to make your life *easier*. They're not some kind of ascetic discipline with which to punish yourself."
- **Domain modeling first, as a TDD kata.** The authors treat domain problems as lunchtime workshops or a spike at the start of a project. "Once you can demonstrate the value of modeling, it's easier to make the argument for structuring the project to optimize for modeling."

## Reference Tables

**FAQ from the tech reviewers — the decision table:**

| Question | Answer |
|---|---|
| Do I need to do all this at once? | **No.** Build a service layer first, even over a messy Django ORM — it's how you start understanding operation boundaries. Then push logic into the model and edge concerns to the entrypoints. |
| Extracting use cases will break tangled code | **Just copy and paste.** Duplication in the short term is fine. Multistep process: copy → clean the copy → redirect callers → delete the mess. |
| Do I need CQRS? Can't I just use repositories? | **Of course you can.** Use *View Builder* objects that fetch via repositories and transform into dumb read models. When you hit a performance problem, rewriting one view builder to use raw SQL is easy. |
| Can one use case call another? | An interim step at best. "This gets *really* messy" — move to a message bus. Your system should have one bus and several subdomains, each centered on an aggregate or set of aggregates. |
| Is one use case touching multiple aggregates a smell? | **If updating two atomically: yes** — your consistency boundary is wrong; consider a new aggregate wrapping both. **Read-only access to the others: fine**, though a read model is cleaner. **Two updates not needing the same transaction: split into two handlers joined by a domain event.** |
| What about a read-only but logic-heavy system? | Split **view builder** from **view fetcher**; unit-test the builder with mocked dicts. Permissions and authorization especially add read-side complexity. |
| Do I need microservices? | **Egads, no!** |
| I'm using Django | See Appendix D. |

**Footguns — what the book deliberately skipped:**

| Footgun | What you need to know |
|---|---|
| **Reliable messaging is hard** | Redis pub/sub is **not reliable** and shouldn't be a general-purpose messaging tool — it was picked for familiarity. MADE runs **Event Store**; RabbitMQ and Amazon EventBridge also used. Read Tyler Treat: *"You Cannot Have Exactly-Once Delivery"*. |
| **Small transactions that fail independently** | Deallocate and reallocate happen in two separate UoWs. **You will need monitoring** to know when these fail and **tooling to replay events**. Easier with a transaction log as broker (Kafka, EventStore). Look at the **Outbox pattern**. |
| **Idempotency isn't discussed** | Handlers get retried. Make them idempotent so repeated calls with the same message don't repeat state changes. |
| **Event schemas change over time** | You need a way to document events and share schema with consumers. The authors like **JSON schema + markdown**. Greg Young wrote a whole book: *Versioning in an Event Sourced System*. |

**More required reading:**

| Book | Why |
|---|---|
| Michael C. Feathers, *Working Effectively with Legacy Code* | Getting legacy code under test and separating responsibilities |
| Leonardo Giordani, *Clean Architectures in Python* (2019) | One of the few previous books on application architecture in Python |
| Hohpe & Woolf, *Enterprise Integration Patterns* | Messaging patterns |
| Sam Newman, *Monolith to Microservices* and *Building Microservices* | Strangler Fig and integration patterns; async messaging considerations |
| Vaughn Vernon, papers on aggregate design | When one use case touches several aggregates |
| eventmodeling.org / eventstorming.org | Visual modeling of systems with events |

## Worked Example

**Case study 1 — Layering an overgrown system (the collaboration platform).**

An ASP.NET Web Forms app with NHibernate, outsourced then passed through several generations of developers. Users upload documents into workspaces; workspace members review, comment, modify. Most complexity lived in the **permissions model**: documents in folders with read/write/edit permissions like a Linux filesystem, workspaces belonging to accounts, accounts with quotas from a billing package.

The symptoms:
- Every read or write against a document loaded an **enormous** number of objects just to check permissions and quotas.
- **Creating a new workspace involved hundreds of database queries.**
- Logic was everywhere: web handlers, manager objects, fat service classes written to abstract the managers and helpers, and hairy command objects written to break apart the services.
- Model objects made database calls and copied files on disk. Test coverage was abysmal.
- Every object inherited from `SecureObject` and `Version`, and that hierarchy was mirrored directly in the schema — **every query joined 10 tables and checked a discriminator column** just to know what kind of object it had.
- The code invited `user.account.workspaces[0].documents.versions[1].owner.account.settings[0]` — easy with Django ORM or SQLAlchemy, but each property might trigger a database lookup.

The performance-killing pattern:
```python
# Lock a user's workspaces for nonpayment
def lock_account(user):
    for workspace in user.account.workspaces:
        workspace.archive()


def lock_documents_in_folder(folder):
    for doc in folder.documents:
        doc.archive()
    for child in folder.children:
        lock_documents_in_folder(child)
```

The fix, in order:
1. **Introduce a service layer** so all the code for creating a document or workspace was in one place. Pulled data-access code out of the domain model into command handlers; pulled orchestration out of managers and web handlers into handlers. *"The resulting command handlers were **long** and messy, but we'd made a start at introducing order to the chaos."*
2. **Identify aggregates**, replacing direct references with identifiers — `Document` gets `parent_folder: int`, with no way to reach the `Folder` object directly.
3. **Replace nested ORM loops with SQL.** The folder/document tree view became "a big, ugly stored procedure. The code looked horrible, but it was much faster and helped to break the links between `Folder` and `Document`."
4. **Use the bus for writes**: query for affected IDs, then raise one command per aggregate.

**Case study 2 — The User Model, or how business and engineering drift apart.**

In that same system: accounts parented workspaces; users were members of workspaces; workspaces were the unit for permissions and quotas. If a user joined a workspace without an account, they were associated with the account owning that workspace. **Messy and ad hoc, but it worked** — until a product owner asked:

> "When a user joins a company, we want to add them to some default workspaces for the company, like the HR workspace or the Company Announcements workspace."

The engineers had to explain that **there was no such thing as a company**, and no sense in which a user joined an account. A "company" might have *many* accounts owned by different users, and a new user might be invited to any of them.

> "Years of adding hacks and work-arounds to a broken model caught up with us, and we had to rewrite the entire user management function as a brand-new system."

**Case study 3 — Carving out a microservice (where the book's example app came from).**

MADE.com had **two monoliths**: frontend ecommerce and backend fulfillment, talking over XML-RPC. Periodically the backend woke up, queried the frontend for new orders, imported them, then sent RPC commands to update stock levels. "Over time this synchronization process became slower and slower until, one Christmas, **it took longer than 24 hours to import a single day's orders**."

The migration:
1. Identified the slowest part: **calculating and synchronizing available stock**.
2. Built a system that listens to external events and keeps a running total of available stock.
3. Exposed it via an API so the browser could ask how much stock is available and how long delivery takes.
4. Raised an event when a product ran out completely, so the ecommerce platform could take it off sale.
5. **Because load was unknown, used CQRS**: every stock change updated a Redis cached view model; the Flask API queried the view models rather than running the complex domain model.

**Result: "How much stock is available?" answered in 2–3 milliseconds, with the API frequently handling hundreds of requests a second for sustained periods.**

Order of work: TDD a toy domain model answering one question — *"If I want N units of HAZARDOUS_RUG, how long will they take to be delivered?"* — then the walking skeleton in production, then the infrastructure, then two months later, real customers.

**Case study 4 — David Seddon on taking small steps** (a tech reviewer, on Django monoliths):

> "I chose to tackle a problem area of the codebase that had always bothered me. I began by implementing it as a use case. But I found myself running into unexpected questions… Was it a problem if my use case interacted with two different aggregates? Could one use case call another? …
>
> **It took me a while to realize that I could start small. I didn't need to be a purist or to *get it right* the first time: I could experiment, finding what worked for me.**
>
> My advice is to focus on a specific problem and ask yourself how you can put the relevant ideas to use, perhaps in an initially limited and imperfect fashion. You may discover, as I did, that the first problem you pick might be a bit too difficult; if so, move on to something else. Don't try to boil the ocean, and don't be too afraid of making mistakes. …
>
> **Don't feel you need permission to rearchitect everything. Just look for somewhere small to start. And above all, do it to solve a specific problem.**"

## Key Takeaways

1. **Name the problem first** — hard to change, slow, or buggy — then pick the pattern that addresses it.
2. **Link the refactor to feature work.** Three weeks of cleanup is an easy sell inside a six-month project.
3. **The service layer is always the first step**, even on top of a messy Django ORM. Enumerate use cases, give each an imperative name, make each atomic.
4. **Duplicate freely while migrating.** Copy → clean → redirect → delete beats a chain of use cases calling each other.
5. **Break the object graph by replacing references with IDs.** Bidirectional links mean your aggregate boundaries are wrong.
6. **Reads become SQL; writes become one-aggregate-at-a-time plus events.**
7. **Deploy a walking skeleton early** — a service that only logs its input forces every infrastructure question into the open, in production.
8. **Adopt incrementally and imperfectly.** Start small, on a specific problem; move on if the first one is too hard.
9. **Know your footguns**: unreliable messaging, cross-transaction failure monitoring, idempotency, and event schema versioning are all real work the book skipped.

## Connects To
- **Introduction**: the Big Ball of Mud and its homogeneity — this chapter is the escape route.
- **Ch 3**: abstractions, used to keep messy migration-era handlers unit testable even when they do I/O.
- **Ch 4**: the service layer, recommended as step one for any legacy system.
- **Ch 7**: aggregates and consistency boundaries — the criterion for "is this use case touching too many aggregates?"
- **Ch 8 / Ch 10**: small independent transactions, and the monitoring/replay tooling they demand.
- **Ch 11 / Ch 12**: replacing nested ORM loops with SQL; CQRS as "run complex view logic on write so you don't run it on read."
- **Appendix D**: Django.
- **Appendix E**: the *Ensure* pattern for precondition checks in use cases.
