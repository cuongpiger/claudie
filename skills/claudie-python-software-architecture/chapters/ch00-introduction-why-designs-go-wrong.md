# Introduction: Why Do Our Designs Go Wrong?

## Core Idea
Software tends toward chaos — the **Big Ball of Mud** — because dependencies grow uncontrolled and business logic smears across layers. The whole book is one long worked example of applying the **Dependency Inversion Principle** to turn the classic three-layer architecture inside out.

## Frameworks Introduced

- **Encapsulation → Abstraction**: Identify a task your code needs done, give it to a well-defined object or function, and name it. That named thing *is* the abstraction.
  - When to use: any time a block of code does something you can name in domain terms.
  - How: (1) name the task ("do a search"), (2) hide the mechanics behind that name, (3) depend on the name, not the mechanics. `urllib` → `requests` → `duckduckgo.query()` is three rungs up the same ladder.
  - Why it works: raising the abstraction level makes code more expressive, more testable, and easier to maintain — the caller stops knowing about `urlencode` and starts knowing about *searching*.

- **Layered Architecture**: Divide code into discrete roles and add rules about which roles may call which.
  - When to use: as the baseline structure for business software.
  - How: Presentation Layer → Business Logic → Database Layer, dependencies pointing downward only.
  - Failure mode: the middle layer ends up depending on the bottom one, so the domain can't change without a migration and can't be tested without a DB.

- **The Dependency Inversion Principle (DIP)** — the `D` in SOLID and the book's organizing principle:
  1. *High-level modules should not depend on low-level modules. Both should depend on abstractions.*
  2. *Abstractions should not depend on details. Instead, details should depend on abstractions.*
  - When to use: continuously, every chapter.
  - How: put an abstraction (Repository, UoW, message bus, ports) between the domain and the infrastructure, then point the infrastructure at the abstraction.
  - Why it works: high-level modules must change *fast* (business demands it); low-level modules are *slow* to change (migrations, deploys). Decoupling lets each move at its own speed.

## Key Concepts

- **Big Ball of Mud** — the anti-pattern where everything is coupled to everything; characterized by *sameness of function* (API handlers that do domain logic, send email, and log).
- **Encapsulation** — two related ideas: simplifying behavior and hiding data. The book means the first.
- **Abstraction** — the object or function you hand a named task to; in Python, often just "the public API of the thing you're using."
- **High-level modules** — the code your organization actually cares about (patients, trials, trades, allocations).
- **Low-level modules** — the code it doesn't (filesystems, sockets, SMTP, AMQP).
- **Depends on** — not necessarily `import` or call; more generally, one module *knows about* or *needs* another.
- **Three-layered architecture** — Presentation / Business Logic / Database.
- **Responsibility-driven design** — the OO tradition (Wirfs-Brock & McKean) of thinking in *roles and responsibilities* rather than data or algorithms. CRC cards drive at the same thing.

## Mental Models

- **Order is complexity; chaos is sameness.** A well-tended garden is *ordered* because it has boundaries and distinctions. Software rots toward chaos when every module starts looking like every other module. Architecture is the deliberate effort that stops the collapse — "a big ball of mud is the natural state of software in the same way that wilderness is the natural state of your garden."
- **Think of an abstraction as a name for a task.** If you can't name what a block of code does in domain language, you don't yet have the abstraction.
- **Use ABCs sparingly in Python.** Java/C# reach for an interface; Python can rely on duck typing. The abstraction can just be a function name plus arguments. Ch3 gives the heuristics for choosing them.
- **"All problems in computer science can be solved by adding another level of indirection."** — David Wheeler. The DIP is that layer of indirection, applied deliberately between business and infrastructure.
- **Behavior should come first and drive our storage requirements.** Most developers design the database schema first and treat the object model as an afterthought. That's where it starts to go wrong — customers don't care about the data model, they care about what the system *does*.

## Code Examples

Three rungs of the same abstraction ladder — same behavior, rising expressiveness:

```python
# Rung 1: urllib — the caller knows about urlencode, decode, json.loads
import json
from urllib.request import urlopen
from urllib.parse import urlencode

params = dict(q='Sausages', format='json')
handle = urlopen('http://api.duckduckgo.com' + '?' + urlencode(params))
raw_text = handle.read().decode('utf8')
parsed = json.loads(raw_text)

# Rung 2: requests — the caller knows about HTTP, not encoding
import requests

params = dict(q='Sausages', format='json')
parsed = requests.get('http://api.duckduckgo.com/', params=params).json()

# Rung 3: a named domain task — the caller knows about *searching*
import duckduckgo

for r in duckduckgo.query('Sausages').results:
    print(r.url + ' - ' + r.text)
```
- **What it demonstrates**: encapsulation is naming a task. Each rung hides one more layer of detail behind a domain-meaningful name.

## Reference Tables

| | High-level modules | Low-level modules |
|---|---|---|
| Contents | Domain concepts: patients, trades, allocations | Filesystems, sockets, SMTP, HTTP, AMQP |
| Business cares? | Yes — this is why the company pays you | No — cron job or Kubernetes, they don't mind |
| Rate of change | Fast (business demands) | Slow (migrations, deploys) |
| Should depend on | Abstractions | Abstractions |

Classic three-layer stack, before inversion:

```
+---------------------------+
|    Presentation Layer     |
+---------------------------+
              |
              V
+---------------------------+
|      Business Logic       |
+---------------------------+
              |
              V
+---------------------------+
|      Database Layer       |
+---------------------------+
```

## Worked Example

**Part I's promise, stated up front.** The authors name the four patterns that will invert the stack, and the order they arrive in:

1. **Repository** — an abstraction over the idea of persistent storage (Ch2).
2. **Service Layer** — clearly defines where our use cases begin and end (Ch4).
3. **Unit of Work** — provides atomic operations (Ch6).
4. **Aggregate** — enforces the integrity of our data (Ch7).

Interleaved is Ch3, a standalone detour on *coupling and abstractions* that shows **how and why** you pick an abstraction in the first place — because the four patterns above are each a particular answer to that general question.

The payoff is demonstrated, not asserted: **Appendix C** swaps out the entire infrastructure (Flask API, SQLAlchemy ORM, and Postgres) for a completely different I/O model — a CLI reading CSVs — without touching the domain model. That swap is only possible because the DIP was applied at every step.

## Key Takeaways

1. **The big ball of mud is the default.** Preventing it takes continuous energy and direction, not a one-time design.
2. **Chaos in software looks like sameness of function** — everything doing a bit of everything. Order looks like clear, differentiated responsibilities.
3. **Encapsulate by naming a task and giving it to a well-defined object or function.** That's the whole trick; the rest is where you draw the lines.
4. **Apply the DIP relentlessly:** business code shouldn't depend on technical details; both should depend on abstractions.
5. **Model behavior first, storage second.** Starting with a database schema is the most common way designs go wrong.
6. **Python doesn't need ABCs to have abstractions.** Duck typing counts; the abstraction can be "the public API of the thing you're using."

## Connects To
- **Ch 1**: builds the business layer with the Domain Model pattern — the "middle layer" this introduction says is most often smeared across the app.
- **Ch 3**: the general heuristics for *choosing* an abstraction, of which Repository/UoW/Service Layer are specific instances.
- **Ch 4**: promised as the concrete example of "details should depend on abstractions."
- **Appendix C**: the proof — swapping Flask + SQLAlchemy + Postgres for a CLI + CSVs.
- **SOLID / Clean Architecture / Hexagonal (Ports & Adapters)**: the DIP here is the same principle Cockburn and Martin build their architectures around.
