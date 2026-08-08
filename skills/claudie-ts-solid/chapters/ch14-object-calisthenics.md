# Chapter 14: Better Objects with Object Calisthenics *(book ch. 35)*

## Core Idea
Object Calisthenics is nine **deliberate constraints** — not laws — that you apply during the **Refactor** step of Red-Green-Refactor. Origin: Jeff Bay, *The ThoughtWorks Anthology*. They're a shortcut to knowing *when your design is getting out of whack*, without having to reason from first principles every time. Stemmler's framing: *"Just because you can doesn't mean you should."*

## The Nine Rules

| # | Rule | The smell it kills | The fix |
|---|---|---|---|
| 1 | **Only one level of indentation per method** | Nested loops/conditionals hiding multiple responsibilities | Extract helper methods; main method orchestrates |
| 2 | **Don't use the `else` keyword** | Branch juggling | Guard clauses / early returns; polymorphism, Null Object, State pattern |
| 3 | **Wrap all primitives and strings** | **Primitive Obsession** | Value Objects with validation in the constructor |
| 4 | **First-class collections** | Filter/sort/iterate logic scattered everywhere | A collection class wrapping the array |
| 5 | **One dot per line** | Law of Demeter violations, broken encapsulation | Direct methods on the owning object |
| 6 | **Don't abbreviate** | `usrObj`, `calcSrvc` — a missing domain concept | Full, expressive, domain-language names |
| 7 | **Keep all entities small** | God classes and junk-drawer packages | Explicit size caps (below) |
| 8 | **No classes with more than two instance variables** | Low cohesion, multiple responsibilities | Extract a domain concept or merge into a Value Object |
| 9 | **No getters/setters/properties** | External code manipulating fields | Meaningful methods: `addPoints()`, `loseLife()` |

**Rule 7's concrete thresholds** (the specific numbers Stemmler commits to):
- **Class**: 50–100 lines max, ideally 1–2 responsibilities
- **Method**: 5–10 lines max, **2 arguments max**
- **Package**: no more than 10–15 files; otherwise sub-package it

## Code Examples

**Rule 1 — one level of indentation:**
```typescript
// ❌ Two nested loops + a conditional = three layers
class SalesReporter {
  public generateSalesReport(repsByRegion: SalesRep[][]): string {
    let report = "Sales Report:\n";
    for (let regionIndex = 0; regionIndex < repsByRegion.length; regionIndex++) {
      report += `Region ${regionIndex}:\n`;
      for (let repIndex = 0; repIndex < repsByRegion[regionIndex].length; repIndex++) {
        const rep = repsByRegion[regionIndex][repIndex];
        if (rep.sales > 10000) {
          report += ` - ${rep.name} made a bonus!\n`;
        } else {
          report += ` - ${rep.name} under quota.\n`;
        }
      }
    }
    return report;
  }
}

// ✅ Each method has at most one loop or one conditional
class SalesReporter {
  public generateSalesReport(repsByRegion: SalesRep[][]): string {
    let report = "Sales Report:\n";
    for (let regionIndex = 0; regionIndex < repsByRegion.length; regionIndex++) {
      report += this.generateRegionReport(repsByRegion[regionIndex], regionIndex);
    }
    return report;
  }

  private generateRegionReport(reps: SalesRep[], regionIndex: number): string {
    let regionReport = `Region ${regionIndex}:\n`;
    for (const rep of reps) {
      regionReport += this.generateRepReport(rep);
    }
    return regionReport;
  }

  private generateRepReport(rep: SalesRep): string {
    if (rep.sales > 10000) return ` - ${rep.name} made a bonus!\n`;
    return ` - ${rep.name} under quota.\n`;
  }
}
```

**Rule 2 — no `else`, use guard clauses:**
```typescript
// ❌
function login(username, password) {
  if (userService.isValid(username, password)) {
    redirect("homepage");
  } else {
    showError("Bad credentials");
    redirect("login");
  }
}

// ✅ Failure conditions first; the success path flows naturally
function login(username, password) {
  if (!userService.isValid(username, password)) {
    showError("Bad credentials");
    return redirect("login");
  }
  return redirect("homepage");
}
```

**Rule 3 — wrap primitives (kill Primitive Obsession):**
```typescript
// ❌ Multiple primitives floating around
class Order {
  public checkout(price: number, currency: string, userID: string) { /* ... */ }
}

// ✅ Value Objects carry validation and behavior
class Money {
  constructor(private amount: number, private currency: string) {
    if (amount < 0) throw new Error("Amount cannot be negative");
  }
  public add(other: Money): Money {
    if (this.currency !== other.currency) throw new Error("Currencies must match!");
    return new Money(this.amount + other.amount, this.currency);
  }
}

class UserID {
  constructor(private readonly value: string) {
    if (!value) throw new Error("UserID cannot be empty");
  }
}

class Order {
  public checkout(price: Money, user: UserID) { /* ... */ }
}
```

**Rule 4 — first-class collections:**
```typescript
// ❌ Filtering logic duplicated across free functions
function getActiveTasks(tasks)      { return tasks.filter(t => t.isActive); }
function countCompletedTasks(tasks) { return tasks.filter(t => t.isCompleted).length; }

// ✅ A collection class owns collection behavior
class Task {
  constructor(private title: string, private completed: boolean) {}
  public isCompleted(): boolean { return this.completed; }
}

class Tasks {
  private items: Task[];
  constructor(tasks: Task[]) { this.items = tasks; }

  public active(): Tasks {
    return new Tasks(this.items.filter(t => !t.isCompleted()));
  }
  public completedCount(): number {
    return this.items.filter(t => t.isCompleted()).length;
  }
}
```
Enables domain-rich reads: `orders.paidOnly()`, `players.activeUsers()`.

**Rule 5 — one dot per line:**
```typescript
// ❌ Exposes the whole chain of internals
person.getWallet().getCreditCard().charge(50);

// ✅ Let `person` handle it
person.chargeCreditCard(50);

// Internally:
chargeCreditCard(amount: number) {
  this.wallet.chargeCreditCard(amount);
}
```
*(Builders and fluent APIs are a legitimate exception — but stay mindful of encapsulation.)*

**Rule 8 — at most two instance variables:**
```typescript
class Game {
  private players: Players;      // instead of: score, level, players, powerUps…
  private gameState: GameState;  // encapsulates score, level, etc.
}
```
Pairs naturally with Rule #3 (wrap primitives) and Rule #4 (first-class collections) — those are *how* you get down to two.

**Rule 9 — no naive getters/setters:**
```typescript
// ❌ External code drives the state
class Game {
  private score: number;
  getScore(): number { return this.score; }
  setScore(score: number) { this.score = score; }
}

// ✅ Meaningful methods; the object protects its own rules
class Game {
  private score: number = 0;

  public addPoints(points: number): void {
    if (points < 0) throw new Error("Cannot add negative points");
    this.score += points;
  }

  public getScore(): number { return this.score; }
}
```
Note the nuance: a *read* accessor is fine; a **setter** is what breaks encapsulation.

## Worked Example — the refactor checklist in TDD

During the **Refactor** step of Red-Green-Refactor, run this scan:

| What you notice | Calisthenic | Action |
|---|---|---|
| Indentation creeping up | #1 | Extract methods or classes |
| `else` blocks appearing | #2 | Early returns; consider polymorphism |
| Raw strings/numbers passed around | #3 | Wrap in a Value Object |
| `.filter()` / `.map()` on the same array in several places | #4 | Introduce a collection class |
| Chained dots | #5 | Add a direct method on the owner |
| Class over ~100 lines, method over ~10 | #7 | Split it |
| 3+ instance variables | #8 | Extract a concept or merge into a VO |
| Getters/setters for every field | #9 | Move the logic inside the domain class |

> **Try two or three per iteration**, not all nine. Each pass pulls the design back toward Simple Design and Responsibility-Driven Design.

## Anti-patterns
- **Primitive Obsession** — raw `string`/`number`/`boolean` carrying domain meaning; the target of Rule #3.
- **Junk-drawer packages** — 30 files in one folder; Rule #7 violation.
- **Anemic classes with full getter/setter surfaces** — the object holds data but makes no decisions; Rule #9 violation and a direct contradiction of Tell, Don't Ask.
- **Treating the nine rules as permanent law** — they're *constraints*, deliberately extreme, meant as a training exercise. Applying all nine dogmatically in production is itself a smell.
- **Method chains through internals** (`a.getB().getC().do()`) — Rules #5 and the Law of Demeter.

## Key Takeaways
1. **Apply these during Refactor, not while writing the first implementation.** They're a design-tightening tool, not a coding style.
2. **Rules #3, #4, and #8 compose**: wrapping primitives and extracting collections is *how* you get a class down to two instance variables.
3. **"Don't abbreviate" is a domain-modeling signal** — a name that feels too long usually means a missing class or missing domain term.
4. **Rule #9 doesn't ban read accessors** — it bans naive setters and getter-for-every-field. `addPoints()` beats `setScore()`.
5. **Concrete thresholds beat vague advice**: ≤10-line methods, ≤2 arguments, ≤100-line classes, ≤10–15 files per package.
6. **Two or three rules per TDD iteration** is the sustainable dose.

## Connects To
- **Ch 13 (Responsibility Driven Design)** — calisthenics are the mechanical enforcement of RDD's cohesion goals.
- **Ch 17 (SOLID)** — Stemmler names Object Calisthenics + Object Stereotypes as *the* practical way to make SRP decidable.
- **Ch 18 (Creational Principles)** — each calisthenic doubles as a trigger for DRY/YAGNI/KISS.
- **Ch 19 (Law of Demeter)** — Rule #5 *is* the Law of Demeter, mechanized.
- **Ch 15 (Code Smells)** — "Strategy #1 to prevent code smells: object calisthenics."
- **Ch 21 (DDD)** — Rule #3 produces Value Objects; Rule #8 pushes you toward Aggregates.
- **Ch 12 (TDD)** — the Refactor step is where all of this happens.

## References
- *The ThoughtWorks Anthology* — Jeff Bay's original nine rules
- *Object Calisthenics* — William Durand
- Fowler's *Refactoring* / Refactoring Guru
