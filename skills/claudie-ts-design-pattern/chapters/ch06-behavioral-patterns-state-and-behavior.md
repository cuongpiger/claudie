# Chapter 6: Behavioral Design Patterns for Managing State and Behavior

## Core Idea
These five patterns decouple an object's *internal state* from its *behavior* — giving
you control structures for how objects traverse, snapshot, transition, specialize, and
get operated on over time.

## Frameworks Introduced

- **Iterator** — traverse a collection without exposing its internal structure.
  - Three key concepts: abstraction of traversal (algorithm separated from structure),
    uniform interface across collection types, encapsulation of collection details.
  - When to use: complex structures (trees, graphs, custom collections); multiple
    traversal orders (in-order/pre-order/post-order); decoupling clients from internals;
    **parallel iteration** (several positions in one collection at once); **lazy
    evaluation** (elements computed only when requested); one uniform traversal API.
  - Five roles: `Iterator` (`hasNext()`, `next()`), `Aggregate` (`createIterator()`),
    `ConcreteIterator` (holds position + collection ref), `ConcreteAggregate`,
    and `Client` (works only against the two interfaces).

- **Memento** — snapshot and restore an object's state without breaking encapsulation.
  - Three roles: **Originator** (owns the state, creates and consumes mementos),
    **Memento** (the immutable snapshot), **Caretaker** (holds the history, never
    inspects or modifies a memento's contents).
  - When to use: creating restorable snapshots that include private properties;
    keeping state management behind an abstraction hidden from clients; multi-level
    undo/redo; checkpoints in long-running processes or simulations.
  - Why it works: neither Originator nor Caretaker has direct access to the other's
    internals, so state can be externalized without leaking it.

- **State** — an object changes behavior when its internal state changes.
  - Three roles: **Context** (holds the current state, exposes methods, calls
    `changeState()`), **State** (interface of state-specific behavior), **Concrete
    States**.
  - When to use: behavior varies significantly by state and you want to avoid large
    conditionals; transitions are frequent or complex; states share near-identical
    behavior with small variations (dedup); state changes at runtime; adding a new state
    should not require touching the Context.
  - Key move: **externalize** state-dependent behavior into state objects; the Context
    delegates rather than branching.

- **Template Method** — an abstract base class defines an algorithm's skeleton; subclasses
  fill in specific steps.
  - Five components: abstract base class, the **Template Method** (the skeleton),
    **concrete operations** (implemented in the base), **abstract operations**
    (subclasses must implement), **hook operations** (optional, with defaults).
  - When to use: algorithmic variations over a common structure (PDF/Word/HTML sharing
    a processing flow); reducing duplication across near-identical implementations;
    building a framework where users customize specific steps.

- **Visitor** — add new operations to an existing object hierarchy without modifying it.
  - How: elements implement `accept(visitor)` and pass `this` to the matching
    `visit*` method. The visitor gains access to each visited type's public API and
    accumulates a result.
  - When to use: traversing a composite hierarchy to collect state without type-checking
    each node; applying new operations to a group of objects that share an interface but
    expose type-specific methods on their subclasses.
  - Mechanism: **double dispatch** — the executed method is selected by *both* the
    visitor type and the element type.

## Key Concepts

- **`hasNext()` / `next()`** — the two-method Iterator contract.
- **`[Symbol.asyncIterator]()`** — makes a class usable in `for await...of`, the
  idiomatic modern Iterator in TypeScript.
- **Lazy loading in an iterator** — `next()` fetches more elements on demand rather than
  materializing the whole collection upfront.
- **Double dispatch** — resolving a call on two runtime types at once; the core trick
  that makes Visitor work in a single-dispatch language.
- **Hook operation** — an optional Template Method step with a default implementation
  (React's `componentDidMount`, Angular's `ngOnInit`).
- **State transition guard** — validation inside `changeState()` that rejects illegal
  transitions.

## Mental Models

- **State vs. Strategy (Ch 5)**: Strategy is chosen by the *caller* from a family of
  algorithms; State is driven by the object's *own* internal condition, and the states
  typically know which state comes next.
- **Visitor vs. Composite (Ch 4)**: Composite is *structural* — treat one object and a
  collection uniformly. Visitor is *behavioral* — separate the algorithm from the
  structure so new operations don't touch the nodes. They pair naturally: Visitor
  traverses what Composite builds.
- **Think of a Memento as a sealed envelope.** The Caretaker files and retrieves it but
  is never allowed to open it; only the Originator can read what's inside.
- **Template Method inverts control.** You don't call the framework; the framework calls
  your overridden steps. That's why it's the backbone of React/Angular lifecycles.
- **Prefer fewer required Template steps.** Every step you expose becomes a contract you
  can't easily deprecate once clients depend on it.

## Anti-patterns

- **Iterator over a simple array**: the extra classes and interfaces buy nothing when a
  plain `for...of` works. Same for read-only collections — just return the array.
- **State pattern for a handful of trivial states**: an enum or `if/else` is clearer.
  Creating a state class per minor variation is over-engineering.
- **States with minimal behavioral difference**: lots of boilerplate, little payoff. If
  you can't articulate what each state *does differently*, you don't have states.
- **Missing state transitions**: incomplete coverage of legal transitions leads to
  unexpected behavior or a growing set of error states.
- **Unbounded Memento history**: storing many full snapshots of large objects blows up
  memory. Mitigations: cap the history, compress state, or (as VS Code does) store
  *edit operations* rather than full snapshots.
- **Frequent Memento create/restore on complex state**: real performance cost — match
  the pattern to how often state actually changes.
- **Template Method with many required steps**: deprecating a step after distribution
  breaks every client that overrode it. Define fewer, and prefer hooks over abstract
  operations.
- **Visitor over a growing element hierarchy**: adding one new element type forces edits
  to *every* visitor implementation. Visitor trades element-extensibility for
  operation-extensibility — only take that trade when the element set is stable.
- **Visitor needing private state**: visitors see only public members; if you must expose
  internals for the visitor, the pattern is fighting you.

## Code Examples

Iterator — classic form with lazy loading:

```typescript
interface Iterator<T> {
  hasNext(): boolean
  next(): T | null
}

interface Playlist {
  createIterator(): Iterator<Song>
}

class PlaylistIterator implements Iterator<Song> {
  private currentIndex: number = 0
  constructor(private playlist: Song[]) {}

  hasNext(): boolean { return this.currentIndex < this.playlist.length }

  next(): Song | null {
    if (this.hasNext()) {
      if (!this.playlist[this.currentIndex]) {
        this.loadMoreSongs()          // lazy: fetch only when reached
      }
      return this.playlist[this.currentIndex++] || null
    }
    return null
  }

  private loadMoreSongs(): void { /* fetch from an external source */ }
}

class MusicPlaylist implements Playlist {
  private songs: Song[] = []
  addSong(song: Song): void { this.songs.push(song) }
  createIterator(): Iterator<Song> { return new PlaylistIterator(this.songs) }
}
```

Iterator — the modern async form (preferred in TypeScript):

```typescript
class AsyncSongIterator {
  private currentIndex = 0
  private songs: string[] = []

  private async fetchSongs(): Promise<string[]> {
    await new Promise((resolve) => setTimeout(resolve, 1000))
    return ["Song 1", "Song 2", "Song 3"]
  }

  async next(): Promise<{ value: string | null; done: boolean }> {
    if (this.currentIndex === 0) this.songs = await this.fetchSongs()
    return this.currentIndex < this.songs.length
      ? { value: this.songs[this.currentIndex++], done: false }
      : { value: null, done: true }
  }

  [Symbol.asyncIterator]() { return this }
}

for await (const song of new AsyncSongIterator()) console.log(song)
```

- **What it demonstrates**: implementing `[Symbol.asyncIterator]` gets you the Iterator
  pattern with native `for await...of` syntax — no `hasNext()`/`next()` ceremony.

Memento — snapshot type plus the sealed memento:

```typescript
interface TextEditorState {
  content: string
  cursorPosition: number
}

class EditorMemento {
  constructor(private readonly state: TextEditorState) {}
  getState(): TextEditorState { return this.state }   // only the Originator uses this
}
```

State — with a transition guard:

```typescript
interface State { handle(): void }

class Context {
  private state: State
  constructor(initialState: State) { this.state = initialState }

  public request(): void { this.state.handle() }

  public changeState(newState: State): void {
    if (this.state instanceof ConcreteStateA && !(newState instanceof ConcreteStateB)) {
      throw new Error("Invalid state transition")
    }
    this.state = newState
  }
}

class ConcreteStateA implements State {
  public handle(): void { console.log("Handling request in ConcreteStateA") }
}
class ConcreteStateB implements State {
  public handle(): void { console.log("Handling request in ConcreteStateB") }
}

const context = new Context(new ConcreteStateA())
context.request()                          // ConcreteStateA
context.changeState(new ConcreteStateB())
context.request()                          // ConcreteStateB
```

Template Method — skeleton + concrete + abstract steps:

```typescript
abstract class DocumentProcessor {
  public processDocument(): void {         // <- the Template Method
    this.openDocument()                    // concrete
    this.extractContent()                  // abstract
    this.analyzeContent()                  // abstract
    this.saveDocument()                    // concrete
  }

  protected openDocument(): void { console.log("Opening document") }
  protected abstract extractContent(): void
  protected abstract analyzeContent(): void
  protected saveDocument(): void { console.log("Saving processed document") }
}

class PDFProcessor extends DocumentProcessor {
  protected extractContent(): void { console.log("Extracting content from PDF") }
  protected analyzeContent(): void { console.log("Analyzing PDF content") }
}

const pdfDoc: DocumentProcessor = new PDFProcessor()
pdfDoc.processDocument()   // polymorphic dispatch picks the PDF steps
```

## Reference Tables

Picking a state/behavior pattern:

| Need | Pattern |
|---|---|
| Traverse without exposing structure | Iterator |
| Undo/redo, checkpoints, snapshots | Memento |
| Behavior depends on internal state | State |
| Same algorithm, varying steps | Template Method |
| New operations over a fixed hierarchy | Visitor |

Memento's three roles:

| Role | Responsibility | Must NOT |
|---|---|---|
| Originator | owns state; `save()` → memento; `restore(m)` | — |
| Memento | immutable snapshot | be mutated |
| Caretaker | stores history, undo/redo stack | inspect or modify memento contents |

Template Method step kinds:

| Kind | Defined where | Subclass must override |
|---|---|---|
| Template Method | base class | no — it's the skeleton |
| Concrete operation | base class | no |
| Abstract operation | base class (abstract) | yes |
| Hook operation | base class (default impl) | optional |

Real-world sightings:

| Pattern | In the wild |
|---|---|
| Iterator | RxJS `Observable` (ES6 iterators enabling composable operators) |
| Memento | VS Code undo/redo — `ITextSnapshot` (Memento), `TextModel` (Originator), `EditStack` (Caretaker) |
| State | React Router's `Route` switching match strategies (string vs. regex) |
| Template Method | React class-component lifecycle (`render` required; `componentDidMount`, `componentWillUnmount`, `shouldComponentUpdate` optional); Angular `ngOnInit` |
| Visitor | The TypeScript compiler; `@typescript-eslint` `VisitorBase`; AST complexity/security analyzers |

What to test:

| Pattern | Assert |
|---|---|
| Iterator | `next()`/`hasNext()` walk the collection correctly; `createIterator()` returns the right concrete iterator |
| Memento | save/restore round-trips state; Originator ops; Caretaker history; integration + edge cases |
| State | each state holds correct parameters; `changeState()` transition logic; behavior matches current state |
| Template Method | subclasses produce expected outcomes; steps run in the correct order (the abstract class can't be instantiated, so test concretes) |
| Visitor | composite forwards the visitor to every child; each element calls the *correct* visit method; each visit method behaves per type |

## Worked Example

**Visitor over a Composite document tree** — the double-dispatch mechanism end to end:

```typescript
// 1. One visit method per concrete element type
export interface DocumentVisitor {
  visitPdfDocument(pdfDocument: PdfDocument): void
  visitWordDocument(wordDocument: WordDocument): void
  visitCompositeDocument(compositeDocument: CompositeDocument): void
}

// 2. Elements only need to know how to accept
export interface AcceptsVisitor {
  accept(visitor: DocumentVisitor): void
}

// 3. Each element dispatches to *its own* visit method, passing itself
export class PdfDocument implements AcceptsVisitor {
  accept(visitor: DocumentVisitor): void {
    visitor.visitPdfDocument(this)      // <- second dispatch: element type
  }
}

export class WordDocument implements AcceptsVisitor {
  accept(visitor: DocumentVisitor): void {
    visitor.visitWordDocument(this)
  }
}

// 4. The composite forwards to children first, then visits itself
export class CompositeDocument implements AcceptsVisitor {
  private documents: AcceptsVisitor[] = []
  addDocument(document: AcceptsVisitor): void { this.documents.push(document) }

  accept(visitor: DocumentVisitor): void {
    for (let document of this.documents) {
      document.accept(visitor)          // recursive traversal
    }
    visitor.visitCompositeDocument(this)
  }
}

// 5. Client: one line adds a whole new operation over the tree
const composite = new CompositeDocument()
composite.addDocument(new PdfDocument())
composite.addDocument(new WordDocument())
composite.accept(new DocumentProcessingVisitor())   // <- first dispatch: visitor type
```

The same shape drives real static analysis, where the visitor accumulates a result:

```typescript
interface ASTVisitor {
  visitFunctionDeclaration(node: FunctionDeclaration): void
  visitVariableDeclaration(node: VariableDeclaration): void
}

class ComplexityAnalyzer implements ASTVisitor {
  private complexity = 0
  visitFunctionDeclaration(node: FunctionDeclaration): void {
    this.complexity += 1
    // analyze function body
  }
  visitVariableDeclaration(node: VariableDeclaration): void { /* ... */ }
}
```

**The trade being made:** adding a *new analysis* costs one new class and zero changes to
the AST. Adding a *new node type* costs a change to every visitor. Visitor is the right
call exactly when the element set is stable and the operations keep growing — which is
why compilers and linters use it and why it's a poor fit for an evolving domain model.

## Key Takeaways

1. Implement `[Symbol.asyncIterator]` rather than a hand-rolled `hasNext()/next()` pair
   when you're in modern TypeScript — you get `for await...of` for free.
2. Don't build an Iterator for a plain array or a read-only collection.
3. Memento's discipline is that the Caretaker never opens the envelope; break that and
   you've broken encapsulation, which is the whole point.
4. Bound your Memento history and consider storing *operations* instead of full
   snapshots (the VS Code approach) when state is large.
5. Use State when transitions are complex enough to warrant guards; use an enum when they
   aren't.
6. Keep Template Method's required steps few — every abstract step is a contract you
   can't deprecate without breaking clients.
7. Visitor optimizes for adding operations, at the cost of adding element types. Only
   take that trade when the hierarchy is stable.
8. Visitor + Composite is the canonical pairing: Composite builds the tree, Visitor
   walks it with an operation the tree knows nothing about.

## Connects To

- **Ch 4**: Composite (the structure Visitor traverses); the DOM as both.
- **Ch 5**: Strategy (contrast with State); Command (contrast with Memento for undo —
  Command stores *how to reverse*, Memento stores *what it was*).
- **Ch 7**: functional programming — immutability makes Memento snapshots cheap and safe.
- **Ch 8**: RxJS Observables build directly on the Iterator abstraction.
- **Ch 11**: the TypeScript compiler and `@typescript-eslint` as large-scale Visitor
  implementations.
