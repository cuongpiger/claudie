# Chapter 5: Behavioral Design Patterns

## Core Idea

Behavioral patterns deal with **object interconnection and algorithms** — who talks to whom, in what order, and which code runs when. Creational patterns decide how objects come into being, structural patterns decide how they compose; behavioral patterns decide how they *interact at runtime*.

The recurring lever across all nine: pull a varying behavior out of the object that holds it, and make it a separate thing you can swap, queue, chain, record, or notify. In Python, that "separate thing" is usually a plain function, because functions are first-class — you rarely need the class hierarchies the Gang of Four drew.

## Frameworks Introduced

- **Chain of Responsibility pattern**: Handle a request by passing it through a chain of handlers; each decides to process it or delegate onward. Client only knows the head of the chain; each handler knows only its successor (a singly linked list). Decouples sender from receivers.
  - When to use: You don't know in advance which object should satisfy a request (purchase approval tiers: $100 → $200 → …); or more than one object may need to process it (event-based programming, one mouse click caught by several listeners). Not useful if a single known element handles everything.
  - How: Vespe Savikko's dynamic-dispatch implementation — `hasattr()` / `getattr()` build the handler name `f"handle_{event}"`; fallbacks are `self.parent.handle(event)` then `handle_default()`.
  - Real-world example: ATM banknote slot — one slot, multiple receptacles. Also web framework filters/middleware chains (auth, logging, compression).

- **Command pattern**: Encapsulate an operation (undo, redo, copy, paste) as an object holding all logic and data to perform it. Invoker is decoupled from the object that knows how to execute; commands can be deferred, queued, and grouped.
  - When to use: undo (the killer feature), GUI buttons and menu items, cut/copy/paste/redo, transactional behavior and logging (OS crash recovery, DB transactions, filesystem snapshots, installer rollback), macros.
  - How: Two parts per command class — `__init__()` captures the information needed, `execute()` runs it. Add `undo()` where reversal makes sense; catch `AttributeError` for commands that lack it. Store commands in a list, `reversed()` it to undo.
  - Real-world example: A restaurant waiter's written check placed in a queue for the cook. In software: PyQt's `QAction`, and Git Cola.

- **Observer pattern**: Publish-subscribe between one publisher (subject/observable) and many subscribers (observers). Subject notifies subscribers of state changes by calling one of their methods.
  - When to use: One or more objects must be informed of a change, and the set of observers varies dynamically at runtime — news feeds (RSS/Atom), social network updates, event-driven systems with listeners attached to events.
  - How: Subject keeps `self.observers` list plus `add_observer()` / `remove_observer()`; on change it loops and calls each observer's `update()`. Observers subclass a thin `Observer` interface.
  - Real-world example: An auction — bidders raise paddles, the auctioneer broadcasts the new price to all bidders. In software: Kivy's `Properties` module, RabbitMQ (AMQP).

- **State pattern**: A finite-state machine applied to a software engineering problem. Two components — **states** (current active status) and **transitions** (switch triggered by an event/condition, with actions before or after). Representable as a state diagram: states are nodes, transitions are edges.
  - When to use: Anything modelable as a state machine — OS process models, compiler lexical/syntactic analysis building an AST, event-driven systems, game entity states (guard → attack).
  - How: Classically a parent `State` class plus one concrete subclass per state. Pythonically, use the `state_machine` module: `@acts_as_state_machine`, `State(initial=True)`, `Event(from_states=..., to_state=...)`, and `@before` / `@after` decorators for transition actions. Illegal transitions raise `InvalidStateTransition`.
  - Real-world example: A snack vending machine (out of stock / insufficient money / exact change / change due). Also traffic lights, video game states.

- **Interpreter pattern**: Offer a simple internal DSL — a language of limited expressiveness targeting one domain — to domain experts and advanced users who aren't programmers. Internal DSLs are built on a host language (free grammar/compiler, but constrained by the host); external DSLs are standalone (you build the parser too).
  - When to use: Only for *simple* languages, and only internal DSLs. If you need an external DSL, reach for Yacc/Lex, Bison, or ANTLR instead. Performance is not the concern; human-readable syntax is.
  - How: Interpreter does not address parsing — it assumes parsed data already exists (an AST or other handy structure). The authors use `pyparsing`: define grammar in BNF first, then build bottom-up with `Word(alphanums)`, `Group(OneOrMore(word))`, `Suppress("->")`, `Optional(...)`; `parseString()` returns a nested-list `ParseResults` you unpack and pattern-match.
  - Real-world example: A musician interpreting musical notation. In software: `boost::spirit` (C++), PyT (Python XHTML/HTML generation).

- **Strategy pattern**: Multiple algorithms for the same problem, switchable at runtime **transparently** — the client is unaware of the change. No single algorithm wins on every input; choose by input size, time complexity, space complexity, stability, and code complexity.
  - When to use: Whenever different implementations of the same algorithm must be applied dynamically — the result is identical, the performance profile is not. Sorting algorithm selection; different formatting representations (platform line-breaking, dynamic data representation).
  - How: In languages without first-class functions, one class per strategy. In Python, a strategy is just a function passed as an argument. Keep a `dict` of name → function and call the chosen one.
  - Real-world example: Getting to the airport — bus/train (cheap, early), own car (parking cost), taxi (fast, expensive). In software: `sorted()` and `list.sort()` accepting `key`.

- **Memento pattern**: Snapshot an object's internal state so it can be restored later. Three components — **Memento** (holds the stored state), **Originator** (gets and sets Memento values), **Caretaker** (stores and retrieves previously created Mementos). Shares many similarities with Command.
  - When to use: Undo/redo capability; OK/Cancel dialogs where Cancel restores the on-load state.
  - How: Pythonically, no separate class per role is needed. `pickle.dumps(self.__dict__)` produces the memento; `pickle.loads(memento)` then `self.__dict__.clear()` + `update()` restores it. **Warning: `pickle` is not secure for generic use** — never unpickle data from an untrusted source; it can execute arbitrary code.
  - Real-world example: Successive editions of a language dictionary, consulted to recover how words were used earlier. In software: Zope's ZODB with through-the-web undo.

- **Iterator pattern**: Traverse a container and access its elements one at a time, decoupling algorithms from containers. So useful that Python made it a **language feature** rather than a pattern you assemble.
  - When to use: Easy navigation through a collection; fetch the next object at any point; stop cleanly when traversal is done.
  - How: The iterator protocol — implement `__iter__()` and `__next__()`; raise `StopIteration()` when exhausted. An object is *iterable* if `iter()` (i.e. `__iter__()`) returns an iterator from it. Built-in containers (list, tuple, set, string) are already iterable; `for` loops and comprehensions consume the protocol for you.
  - Real-world example: A football team you traverse player by player (`FootballTeam` + `FootballTeamIterator`).

- **Template pattern**: Eliminate code redundancy in algorithms with structural similarities. Keep the **invariant** part in a template method/function, move the **variant** parts into action/hook methods passed in. Redefine parts of an algorithm without changing its structure.
  - When to use: You notice repeatable code across structurally similar algorithms. Pagination (invariant: max lines/pages; variant: header/footer rendering). Every application framework — you inherit and implement custom behavior while a template method handles drawing, the event loop, resizing.
  - How: A template function taking the varying step as a callable argument (`generate_banner(msg, style)`), with each style a plain function.
  - Real-world example: The daily routine of workers at the same company — same shape, different specifics. In software: `cmd.Cmd.cmdloop()`.

- **Other behavioral patterns**: The **Mediator pattern** (objects communicate through a central hub instead of directly, promoting loose coupling) and the **Visitor pattern** (separate algorithms from the objects they operate on; add operations without modifying element classes). Skip both in Python — `asyncio`-style event-driven programming replaces Mediator, and first-class functions, decorators, and context managers replace Visitor.

## Key Concepts

- **Decoupling is the payoff, not the mechanics.** Chain of Responsibility replaces a many-to-many client↔handler relationship with one edge: client → head of chain. Observer replaces hard-wired notification with a runtime-mutable subscriber list.
- **Dynamic dispatch beats `if/elif` ladders.** `hasattr()`/`getattr()` on a computed method name (Chain), a dict of functions (Strategy), a state machine's transition table (State) — all delete conditional logic that is long and error-prone to maintain.
- **Deferred execution.** Command's whole point is that `__init__()` and `execute()` are separate moments in time. That gap is what makes queues, macros, logs, and undo possible.
- **Invariant vs. variant.** Template's vocabulary: name the part that never changes, parameterize the part that does.
- **Internal vs. external DSL.** Internal = hosted in Python, free grammar/compile, constrained expressiveness. External = your own grammar, your own parser. Interpreter applies only to internal.
- **State machines fail gracefully.** Illegal transitions raise, and the app catches — it doesn't crash.

## Mental Models

**Strategy vs. State** — they look identical (both delegate behavior to an interchangeable object). The distinguishing question: *who chooses, and does the choice have memory?*
- Strategy: the **client or context picks** an interchangeable algorithm. All strategies produce the **same result** with different performance/complexity. Strategies are unaware of each other; there are no legal or illegal orderings. `allUniqueSort` and `allUniqueSet` both answer "are all characters unique?" — pick either, any time.
- State: the **object's current state picks**, and states know which states they may become. Different states produce **different results** for the same call. The set of transitions is a constrained graph — `created → terminated` is illegal, `running → blocked` is legal. State has memory; Strategy does not.
- Rule of thumb: if swapping the delegate at random is harmless, it's a Strategy. If swapping it at random corrupts the object, it's State.

**Observer vs. callback** — a callback is one function you hand to one call site, wired at the point of the call and gone after. Observer is a *registry*: many subscribers, registered and unregistered at runtime by identity (`add_observer` / `remove_observer`), and the publisher notifies whoever happens to be in the list at notify time. Use a callback for "when this finishes, do that." Use Observer when the audience is plural, unknown at design time, and changes while the program runs.

**Command vs. plain function** — a plain function executes at the moment you call it and leaves no trace. A command is a *reified* call: arguments captured at construction, execution deferred, and — critically — a reverse operation (`undo()`) attached to the same object. If you never need to store, queue, log, group, or reverse the call, use the function. The moment you need a list of them, use the Command pattern.

## Anti-patterns

- Reaching for **Chain of Responsibility when a single known handler suffices** — you pay for indirection and buy nothing. The value is decoupling under uncertainty.
- Treating **undo as the only Command use case** — commands also cover macros, logging, transactions, GUI actions.
- **Hand-rolled `if…else` state transition checks** — long, error-prone, and duplicated at every call site. A state machine module removes them entirely.
- Building an **external DSL with the Interpreter pattern** — wrong tool. Interpreter is for simple internal DSLs only.
- **Letting the end user pick the strategy.** The point of Strategy is transparency — the code should select the faster algorithm from the input; a menu prompt is a demo scaffold, not the pattern.
- **One class per strategy in Python.** That's a Java transcription. Functions are objects; use them.
- Using **`pickle` on untrusted input** for Memento — it is not secure for generic usage.
- Writing **Mediator and Visitor in Python** by rote — the language's built-ins cover both goals more directly.

## Code Examples

```python
def allUniqueSort(s):
    if len(s) > LIMIT:
        print(WARNING)
        time.sleep(SLOW)
    srtStr = sorted(s)
    for c1, c2 in pairs(srtStr):
        if c1 == c2:
            return False
    return True


def allUniqueSet(s):
    if len(s) < LIMIT:
        print(WARNING)
        time.sleep(SLOW)
    return True if len(set(s)) == len(s) else False


strategies = {"1": allUniqueSet, "2": allUniqueSort}
strategy = strategies[strategy_picked]
result = allUnique(word, strategy)
```
- **What it demonstrates**: Strategy in Python — two interchangeable algorithms with identical results but different scaling, selected from a dict of first-class functions. No classes, no interface.

```python
class WeatherStation:
    def __init__(self):
        self.observers = []

    def add_observer(self, observer):
        self.observers.append(observer)

    def remove_observer(self, observer):
        self.observers.remove(observer)

    def set_weather_data(self, temperature, humidity, pressure):
        for observer in self.observers:
            observer.update(temperature, humidity, pressure)
```
- **What it demonstrates**: Observer — the subject holds only a list, never a concrete observer type; subscribers join and leave at runtime.

```python
class Widget:
    def __init__(self, parent=None):
        self.parent = parent

    def handle(self, event):
        handler = f"handle_{event}"
        if hasattr(self, handler):
            method = getattr(self, handler)
            method(event)
        elif self.parent is not None:
            self.parent.handle(event)
        elif hasattr(self, "handle_default"):
            self.handle_default(event)
```
- **What it demonstrates**: Chain of Responsibility via dynamic dispatch — handler name computed from the event, two fallback rungs (parent, then default), zero `if event == ...` branching.

```python
class RenameFile:
    def __init__(self, src, dest):
        self.src = src
        self.dest = dest

    def execute(self):
        logging.info(f"[renaming '{self.src}' to '{self.dest}']")
        os.rename(self.src, self.dest)

    def undo(self):
        logging.info(f"[renaming '{self.dest}' back to '{self.src}']")
        os.rename(self.dest, self.src)
```
- **What it demonstrates**: Command — init captures state, `execute()` defers the effect, `undo()` reverses it; a list of these gives multilevel undo via `reversed(commands)`.

## Reference Tables

| Pattern | Intent | When to use | Python mechanism |
|---|---|---|---|
| Chain of Responsibility | Pass a request along handlers until one handles it | Handler unknown in advance; several may need to react | `hasattr()`/`getattr()` dynamic dispatch; `parent` link; `handle_default()` |
| Command | Encapsulate an operation as an object | Undo/redo, macros, queues, transactions, GUI actions | Class with `__init__()` + `execute()` (+ `undo()`); list of commands, `reversed()` |
| Observer | Notify many subscribers of a subject's state change | Audience varies at runtime; feeds, events, sockets | Subject list + `add_observer`/`remove_observer`; observers implement `update()` |
| State | Behavior changes with an object's state, via legal transitions | Anything modelable as a finite-state machine | `state_machine` module: `@acts_as_state_machine`, `State`, `Event`, `@before`/`@after` |
| Interpreter | Give domain experts a simple internal DSL | Simple language, readability over performance | `pyparsing` grammar (`Word`, `Group`, `OneOrMore`, `Suppress`) + pattern matching |
| Strategy | Swap interchangeable algorithms transparently | Same result, different performance profile per input | Functions as first-class objects; dict of name → function |
| Memento | Snapshot and restore an object's internal state | Undo/redo, OK/Cancel dialogs | `pickle.dumps(self.__dict__)` / `pickle.loads()` + `__dict__.update()` |
| Iterator | Traverse a container element by element | Custom collections needing `for`/`next()` support | Iterator protocol: `__iter__()` + `__next__()`, `raise StopIteration()` |
| Template | Fix an algorithm's structure, vary its steps | Structurally similar algorithms with duplicated skeleton | Template function taking a callable for the variant step |

## Worked Example

**The State pattern — an OS process state machine.**

Model a process's lifecycle: `created`, `waiting`, `running`, `terminated`, `blocked`, `swapped_out_waiting`, `swapped_out_blocked`. The reasoning is that a process has exactly one active state at any moment, and only some transitions are legal — `running → blocked` yes, `blocked → terminated` no. Encoding that with `if/elif` across every call site is where bugs live; encoding it as a transition table means illegal moves are impossible by construction.

Declare states, with the entry point marked:

```python
@acts_as_state_machine
class Process:
    created = State(initial=True)
    waiting = State()
    running = State()
    terminated = State()
    blocked = State()
    swapped_out_waiting = State()
    swapped_out_blocked = State()
```

Declare transitions as `Event` instances. `from_states` accepts a single state or a tuple — that tuple *is* the legality rule:

```python
    wait = Event(
        from_states=(created, running, blocked, swapped_out_waiting),
        to_state=waiting,
    )
    run = Event(from_states=waiting, to_state=running)
    terminate = Event(from_states=running, to_state=terminated)
    block = Event(
        from_states=(running, swapped_out_blocked), to_state=blocked
    )
```

Attach side effects with `@before` / `@after` — in real systems, update objects, send a notification; here, print:

```python
    @after("run")
    def run_info(self):
        print(f"{self.name} is running")

    @before("terminate")
    def terminate_info(self):
        print(f"{self.name} terminated")
```

Drive transitions through one helper so illegal moves degrade instead of crashing:

```python
def transition(proc, event, event_name):
    try:
        event()
    except InvalidStateTransition:
        msg = (
            f"Transition of {proc.name} from {proc.current_state} "
            f"to {event_name} failed"
        )
        print(msg)
```

Running it, `created → terminated` and `blocked → terminated` both print a failure line and leave the process in its prior state; every legal transition fires its `@after` action. Note what is absent: not one `if state == ...` check. The transition table is the specification and the implementation at once.

## Key Takeaways

- Behavioral patterns are about **runtime interaction**: who is notified, which algorithm runs, what order things execute in, and what can be undone.
- **Python's first-class functions collapse most of these.** Strategy is a function argument. Template is a function argument. Command is a function argument plus a stored inverse. Reach for classes only when you need to carry state or a reverse operation alongside the call.
- **Iterator isn't a pattern here, it's the language.** Implement `__iter__()`/`__next__()` only for custom containers; everything else already works.
- **Chain of Responsibility and Observer both buy decoupling** — one for "who handles this?", the other for "who needs to know?".
- **Strategy and State are structurally twins and semantically opposites.** Strategy: caller picks, results identical, no memory. State: object picks, results differ, transitions constrained.
- **Use a state machine library** rather than hand-rolling transition conditionals — it eliminates the error-prone branching entirely.
- **Memento via `pickle` is the pragmatic Python route**, but `pickle` is unsafe on untrusted data — restrict it to state you produced yourself.
- **Skip Mediator and Visitor in Python.** `asyncio`/event-driven code and decorators/context managers already give you their benefits.

## Connects To

- **Chapter 1, Foundational Design Principles**: the Loose coupling section is the justification for Chain of Responsibility and Observer; separation of concerns underpins Observer directly.
- **Chapter 4, Structural Design Patterns**: structural patterns compose objects; behavioral patterns govern how those compositions talk at runtime.
- **Chapter 6, Architectural Design Patterns**: next up — the same decoupling instinct applied at system scale.
- **Within this chapter**: Memento shares many similarities with Command (both reify an operation or a moment so it can be reversed); Strategy's `sorted()` example is reused as the ideal-generic-function baseline that motivates Template; State builds on the Observer discussion of notifying on state change.
