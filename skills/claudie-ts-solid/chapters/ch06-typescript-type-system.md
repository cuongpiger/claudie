# Chapter 06: Types — TypeScript as a Design Tool *(book ch. 11)*

## Core Idea
Types are not a safety net bolted onto JavaScript — they are the mechanism that lets you **separate the contract from the implementation**. That separation is what makes design principles, design patterns, and architectural patterns possible at all. Types also act as **constraints** and **feedback** (in the human-centered-design sense), which is why they make a codebase learnable.

## Frameworks Introduced

- **The Two Type-System Axes** — categorize any language with two independent questions:
  - **Static vs. Dynamic**: *Do I declare the type, or does the compiler assume it?* and *When is type-checking done — compile time or run time?*
  - **Strong vs. Weak**: *How strict are the typing rules?* Specifically, will the compiler **coerce** a type rather than complain?
  - **Type coercion**: compiler behavior in weakly-typed languages where it automatically decides the resulting type when two or more are possible.
  - Stemmler's recommendation: a **static + strictly (strongly) typed** language like TypeScript — to avoid unpredictable states, unnecessary uncertainty, and the compiler doing things "auto-*magically*."

| | Static | Dynamic |
|---|---|---|
| **Strong** | TypeScript, Go, Java | Python |
| **Weak** | — | JavaScript, Perl |

  Coercion in practice: JS `"2" + 1 === "21"` (string wins); Perl `"2" + 1 == 3` (integer wins); Python throws `TypeError`.

- **The Five Reasons for Static Types** (the argument, in order):
  1. **Catch silly mistakes** — missing arguments, typos, missing properties. *"The compiler is your wingman."* This is a **feedback** improvement.
  2. **Abstraction techniques** — types, interfaces, abstract classes/methods, generics. *"Split the intent from the implementation. Write the contract, and implement it. Focus on the 'what' (declarative) first, and the 'how' (imperative) later."*
  3. **Enforce policy** — you *could* enforce contracts without interfaces, but with them the compiler enforces it for you: *"the gentle librarian politely asking you 'please don't do that.'"*
  4. **Make the implicit, explicit** — wrap primitives in domain types so illegal states become unrepresentable.
  5. **Communicate design intent** — patterns are far easier to recognize and name in explicitly-typed code.

- **Nominal vs. Structural (Duck) Typing** — the distinction that most surprises developers coming from Java:
  - **Nominal** (Java): a type is valid based on the *explicit declaration of its name*, and/or whether it's a declared subtype. Requires explicit declaration and casting even when the shape already fits — often redundant.
  - **Structural / Duck Typing** (TypeScript): *"If it looks like a Duck and it quacks like a Duck… it must be a Duck."* Compatibility is determined by the computed type's **actual structure**.
  - Why TypeScript chose it: a design goal was an optional type system that doesn't disrupt JavaScript developer productivity.

## Code Examples

**The nominal-typing surprise** — why TypeScript lets a `Synth` through a `Guitar` parameter:
```typescript
class Instrument {}
class Guitar extends Instrument {}
class Synth  extends Instrument {}

function pluckGuitar(guitar: Guitar): void {}

const fender = new Guitar();
const juno60 = new Synth();

pluckGuitar(fender);
pluckGuitar(juno60);  // ⚠️ This shouldn't be allowed — but it is!
```
**Why**: `Guitar` and `Synth` have the *same structural shape* — they aren't built different. Give `Guitar` a distinguishing member and the error appears:
```typescript
class Guitar extends Instrument {
  pluck(): void { console.log('Boing!'); }
}
// Now pluckGuitar(juno60) is an error ✅
```
> **Practical rule**: in TypeScript, an empty marker class buys you *nothing*. If you need nominal behavior, add a distinguishing member (a brand/private field or a unique method).

**Duck typing — extra properties are fine, missing ones are not:**
```typescript
interface Comment {
  id: number;
  name: string;
  content: string;
}

interface Reply {
  id: number;
  name: string;
  content: string;
  parentCommentId: number;
}

function postComment(comment: Comment) { /* ... */ }

postComment(comment);           // ✅ exact match
postComment(reply);             // ✅ extra information is still alright
postComment({ id: 1 });         // ❌ missing 'name', 'content'
```
Compare with the pre-TypeScript runtime approach — a wall of `hasOwnProperty` + `typeof` checks and thrown errors, replaced entirely by compile-time structural checking.

> 💡 **Runtime structural checking still has a place**: TypeScript checks structure at *compile* time; a validation library (Joi, and in modern practice Zod) checks it at *run* time — for data crossing a system boundary.

## Worked Example — Making the implicit, explicit

**The problem.** Primitives don't carry rules. Nothing stops this:
```typescript
function createUser(email: string, password: string): User { /* ... */ }

createUser("", "");   // ⚠️ Uh-oh, this works
```

**The fix.** Wrap the primitive in its own domain type, with a **private constructor** so the only path to an instance runs through validation:
```typescript
interface EmailAddressProps {
  value: string;   // here's where the primitive lives now
}

class Email {
  getValue(): string {
    return this.props.value;
  }

  // "Private" means you can't create this using the "new" keyword.
  private constructor(props: EmailAddressProps) {
    super(props);
  }

  private static isValidEmail(email: string): boolean {
    // do validation here
  }

  // Only way to create an Email is through the static factory method
  public static create(email: string): EmailAddress {
    const guardResult = Guard.againstNullOrUndefined(email, 'email');
    if (guardResult.isFailure() || !this.isValidEmail(email)) {
      throw new Error("Not a valid email.");
    }
    return new EmailAddress({ value: email });
  }
}
```

**Then strictly-type the signature instead of "string-ly" typing it:**
```typescript
class Email    { /* ... */ }
class Password { /* ... */ }

function createUser(email: Email, password: Password): User { /* ... */ }

const email    = Email.create("khalil@khalilstemmler.com");
const password = Password.create("verysupersecretpassword");
createUser(email, password);   // ✅
```

**The lesson**: this is how you build "a layer of **core code** that looks almost like a domain-specific language." The point isn't validation — it's **reducing the surface area of what's possible**, i.e. introducing constraints. This is the Value Object pattern, Object Calisthenics Rule #3, and DDD's "make the implicit explicit," all at once.

## Reference — TypeScript constructs covered

| Category | Constructs |
|---|---|
| **Type declaration** | Type annotations (`var name: string`), separate contracts (`type Name = string`), implicit vs. explicit types |
| **Type flavours** | Structural, Nominal, Duck, **Ambient** (declaration files for existing JS libraries) |
| **OO constructs** | Classes, class inheritance, static properties, instance variables, **access modifiers**, `readonly`, interfaces, generics |
| **Special types** | Type assertions, type aliases, **union**, **intersection**, `enum`, `any`, `void`, inline & literal types, **type guards** |

**Ambient types**: TypeScript's answer to using existing JavaScript libraries safely — a *sliding scale* where the more declaration effort you invest, the more type safety and code intelligence you get back.

## Anti-patterns
- **"String-ly typed" domain code** — `createUser(email: string, password: string)`. The type says nothing about the rules.
- **Empty marker classes for type distinction** — structurally identical types are interchangeable in TypeScript; the class name buys nothing.
- **Public constructors on domain objects with invariants** — leaves a path around validation. Private constructor + static `create()`.
- **Expecting Java-style nominal behavior** — leads to bugs where an unrelated same-shaped object is silently accepted.
- **Trusting compile-time types at system boundaries** — data from HTTP, files, or a DB was never checked; validate at runtime.
- **Non-typed languages for large codebases** — *"Non-typed languages don't scale very well."*

## Key Takeaways
1. **Types separate contract from implementation** — that separation is the foundation of SOLID, DI, plugin architectures, and ports & adapters.
2. **TypeScript is structural, not nominal.** Same shape = same type. Design accordingly.
3. **Wrap primitives that carry domain rules.** `Email`, `Password`, `Money`, `UserID` — private constructor + static factory.
4. **Prefer static + strong.** Avoid coercion surprises entirely.
5. **The compiler is a feedback loop and a constraint mechanism** — the two human-centered-design levers that make a codebase learnable.
6. **Compile-time structure ≠ runtime structure.** Validate at boundaries with a runtime validator.
7. **Explicit types make patterns recognizable** — you can only say "that's a Template Method" if the abstraction is visible.

## Connects To
- **Ch 07 (Errors & Exceptions)** — union types are how you aggregate errors; the `Either` type builds on them.
- **Ch 14 (Object Calisthenics)** — Rule #3 "Wrap all primitives and strings" is this chapter's worked example.
- **Ch 17 (SOLID)** — interfaces are how DIP, ISP, and LSP are expressed at all.
- **Ch 16 (Design Patterns)** — the private-constructor + factory-method combination appears again as the DDD entity pattern.
- **Ch 02 (Human-Centered Design)** — types as *constraints* and *feedback*.
- **Ch 21 (DDD)** — Value Objects and Entities are the production form of the `Email` example.
