# Chapter 04: Naming Things — The Seven Principles *(book ch. 8)*

## Core Idea
Approach naming with **psychological science, engineering, and structure** — not the art, creativity, and novelty used to name companies, bands, and products. The seven principles come from **Tom Benner (NamingThings.co)**, corroborated against Evans' *DDD*, Vernon's *Implementing DDD*, and Martin's *Clean Code*.

**The law of naming**: > **Communicate *what* with names, explain *why* with context.**

---

## The Seven Principles

### #1. Consistency & Uniqueness
> *Each concept should be represented by a single, unique name.*

**Why**: the human brain relies on consistency to learn. In a new codebase you read code, identify choices, ask questions, look for patterns, then **extend those patterns** into new situations. Inconsistency breaks that loop.

| Rule | Detail |
|---|---|
| Avoid **thesaurus names** | Don't use similar words for the same concept (`fetch`/`get`/`retrieve` for one idea) |
| Follow language & project naming conventions | |
| Avoid near-identical names via misspelling or alternate spellings | `color`/`colour` |
| Don't use the same name for different concepts **in the same namespace** | |
| **Don't recycle variable names** | |
| Names should be unique **regardless of case** | `user` vs. `User` vs. `USER` |

### #2. Understandability
> Use **knowledge in the world** — culture, experience, real things.

- **Domain-specific names are a long-term investment.** The domain layer describes core business rules; name things in more technical layers with technical concepts. Use architecture and frameworks to dictate naming.
- **"There's a construct for everything."** If you can't name a class, you *might not yet know the right construct for it.* Stemmler's own example: he called validation classes `Validators` for a long time before discovering the correct construct was a **Value Object**.
  - One resource, many valid constructs: `User`, `UserMapper`, `UserRepo`, `Username`, `UserCreated`.
  - **Avoid tech-y fluff names**: `Processor`, `Manager`, `Helper`. *"Isn't all code processing, managing, or helping in some way?"*

| Rule | Detail |
|---|---|
| Don't randomly capitalize syllables | `PaidJobDeTails` ❌ |
| Avoid names with digits | lowercase `l` looks like `1`. Prefer `ThirdCard` > `3rdCard`; `ThreeSixtyNoScope` > `360NoScope` |
| Use pronounceable names | *"Try asking your customers what `XEN_94_PHXX_` is supposed to mean"* |
| **Use CQS to name methods** | A method either commands or queries — never both |
| Document notable side effects | |
| Use **domain concepts** for business things, **technical concepts** for technical things | |
| Use simple, grammatically correct English without spelling errors | |
| Don't omit vowels or unnecessarily abbreviate | |
| **Avoid misleading names** | |
| **Avoid negatives in boolean methods** | `if (isEmailNotValid(email))` ❌ → `if (!isEmailValid(email))` ✅ — negatives cost the reader logical processing |
| Avoid irrelevant names | `marypoppins = (superman + starship) / god` ❌ |
| **Make meaningful distinctions** | |

### #3. Specificity
> *A name shouldn't be overly vague or overly specific.*

**Heuristic**: *"Better to over-specify than under-specify."* With modern find-and-replace, writing a very specific name and refining later is cheap; a short nebulous one is expensive to fix.

**Worked example — the over-specified method:**
```typescript
class AuthenticationService {
  public userHasAuthenticatedAndVerifiedEmailShouldTheyBeNonAdmins(user: User): boolean { }
}
```
**The good**: well-intentioned; more information about what it's for and how it's determined.
**The bad**: **fatiguing** to read, and **misinformation** — words like *and*, *should*, *they*, *be*, *non* contribute nothing.

**The key insight**: those useless words **signify conditionals** — which tells you they should be **split into their own methods**:
```typescript
class AuthenticationService {
  public userIsAuthenticated(user: User): boolean { }
  public userVerifiedEmail(user: User): boolean { }
  public userIsAdmin(user: User): boolean { }
}
```
> **A name that's too long is usually a design smell, not a naming problem.**

| Rule | Detail |
|---|---|
| **Singular / plural naming** | Optionally `aCar` for a single item; use `collection`, `list`, `array`, or plurals (`todos`, `todosList`) for groups. `const todo: Todo[]` ❌ |
| Don't refer to things as variables/classes/methods in the name | |
| **Name people by their roles** | A `User` may really be an `Admin`, `Editor`, `Employee`, `Cashier`, `Visitor`. Related to **SRP** and **Conway's Law** |
| **Specificity against unions** | `getUser(userOrUserId: User \| UserId)` — the name states what may be stored |
| **Avoid blob parameters** | `static create(args)` ❌. Mostly a JS problem, but `any` recreates it in TS. **Always strictly type object parameters** with a `UserProps` interface |
| Avoid number series parameters | `arg1, arg2, arg3` |
| **Utilize namespaces** | A `Job` in `MediaProcessing` differs from a `Job` in `HR`. **Preferred**: namespace by packaging into modules. **Worst case**: domain-specific prefixes (`MediaProcessingJob`) |
| Use abbreviations sparingly | |

### #4. Brevity
> *A name should be neither overly short nor overly long.* Verbose code is hard to read — and **too-succinct code is also hard to read.**

**The compression vs. context scale** (the chapter's central mental model):
- **To communicate anything, we have to compress it.** Book summaries, movie trailers, quotes — they convey the main idea but sacrifice detail. *Compressed too much, ideas lose all context and meaning.*
- **To explain something, we provide context.** But too much context loses the main takeaway.

| | Gains | Loses |
|---|---|---|
| **More compression** | **Discoverability** | Context |
| **More context** | **Understanding** | Compression |

**Two questions to ask**:
1. Are we adequately describing **what** is in this name?
2. Does the context reinforce **why** it makes sense for this name to exist?

> This is exactly the role of comments: they supply **context** by explaining **why** — the thing code can't communicate.

| Rule | Detail |
|---|---|
| Use concise English | |
| Refrain from non-conventional single-letter variables | |
| **Grouping indicates context** | Classes, namespaces, folder names, and proximity all communicate context — so you don't have to encode it in the name |
| The operation and resource name must be in context | |
| **Don't use unnecessary member prefixes** | `_firstName` is a JS convention for "private" — **TypeScript has real `private` modifiers**, so drop it |
| **Refactor member prefixes out of objects** | AngularJS's `vmFirstName` → group into an object instead |

**Grouping in action** — context without encoding it in names:
```typescript
// ❌ No context — operating against what?
function create(props) {}
function edit(id, props) {}
function del(id) {}

// ✅ The class supplies the context
export class StudentRepo {
  public create(props) {}
  public edit(id, props) {}
  public del(id) {}
}
```

### #5. Search-ability
> *A name should be easily found across code, documentation, and other resources.*

**Benefits**: easier refactoring, findable in documentation, understandable throughout the codebase.

**What makes names unsearchable**: too short (`a`) · too generic (`user`) · different names for the same concept (outdated documentation).

> Search-ability is **mostly determined by principles #1, #3, and #4** — get consistency, specificity, and brevity right and searchability follows.

| Rule | Detail |
|---|---|
| **Avoid numeric constants** | `function addMovieRating(rating = 8)` ❌ → `const DEFAULT_MOVIE_RATING = 8;` ✅ |
| Keep documentation up to date | Make it part of the release process for new code and features |

### #6. Pronounceability
> *A name should be easy to use in common speech.*

**Why**: unpronounceable names can't be discussed with peers — and *discussing code with peers is a great way to improve design quality*. They're also harder to remember (just like names at a social gathering).

| Rule | Detail |
|---|---|
| Very standard abbreviations needn't be pronounceable | Everyone knows `ssn` |
| Use camelCase to signal word breaks | |
| **Booleans should ask a question or make an assertion** | ✅ Assertion: `potIsEmpty()` · ✅ Question: `isPostEmpty()` · ❌ `makeVar` (signals an operation) · ❌ `hello` (signals nothing boolean) |
| Don't omit vowels | `type timeStamp = Date` > `type tmStmp = Date` |

### #7. Austerity
> *A name should not be clever or rely on temporary concepts.*

**Why**: *"90% of what we do is in the long-term."* Not everyone shares your sense of humour, and there's already enough challenge in writing a name to be understood — why add a secondary meaning?

| Rule | Detail |
|---|---|
| **Don't use temporarily relevant concepts** | Historical events, memes, jokes. Projects survive 5, 10, 20 years — *"imagine having to explain a joke over and over for a decade"* |
| **Avoid being cute, funny, clever** | Save the quips for happy hour |
| **Don't include pop culture references** | *"Not everyone has seen Star Wars… someone shouldn't need to know Han Solo's best mate to understand what a block of code does"* |

---

## Anti-patterns
- **`Manager` / `Processor` / `Helper` / `Util` suffixes** — fluff that adds nothing; usually means you haven't found the right construct.
- **Negated booleans** — `isEmailNotValid()` forces the reader to do logic just to read.
- **Blob / untyped parameters** — `create(args)` or `create(props: any)`.
- **Recycled variable names** — the same identifier meaning different things over its lifetime.
- **`_privateField` in TypeScript** — the language has real access modifiers.
- **Magic numbers** — unsearchable by definition.
- **Different names for the same concept** — kills consistency *and* searchability at once.
- **Names encoding conditionals** (`...ShouldTheyBeNonAdmins`) — that's a method that wants to be three methods.

## Key Takeaways
1. **Communicate *what* with names, explain *why* with context.** The single sentence to remember.
2. **A too-long name is a design signal** — extract the conditionals it's encoding into their own methods.
3. **Over-specify rather than under-specify.** Refactoring a long name is easy; recovering meaning from a vague one isn't.
4. **If you can't name it, you probably haven't found the right construct** — `Validator` was really a Value Object.
5. **Grouping supplies context for free** — put it in the class, module, or folder instead of the identifier.
6. **Booleans ask a question or make an assertion**, and never in the negative.
7. **Name people by their role in the domain**, not `User`.
8. **Search-ability is a consequence** of consistency + specificity + brevity, not a separate effort.
9. **Don't get hung up.** *"Names can always be refactored during development. Pick a name, ask for feedback, improve over time."*

## Connects To
- **Ch 02 (Human-Centered Design)** — Principle #2 *is* "knowledge in the world"; naming is a signifier.
- **Ch 05 (Comments)** — comments supply the *why*/context half of the naming law.
- **Ch 06 (Types)** — "avoid blob parameters" is why you strictly type object parameters.
- **Ch 18 (CQS)** — CQS is invoked directly as a method-naming rule.
- **Ch 21 (DDD)** — the Ubiquitous Language is the source of domain-specific names.
- **Ch 14 (Object Calisthenics)** — Rule #6 "Don't Abbreviate."
- **Ch 19 (Simple Design)** — "Expresses Intent"; *naming is design*.

## References
- [NamingThings.co](https://namingthings.co) — Tom Benner (the seven principles)
- *Domain-Driven Design* — Eric Evans · *Implementing DDD* — Vaughn Vernon · *Clean Code* — Robert C. Martin
- Ward Cunningham's wiki: *"Very Long Descriptive Names That Programming Pairs Think Provide Good Descriptions"*
