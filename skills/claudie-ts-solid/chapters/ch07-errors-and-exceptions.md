# Chapter 07: Errors and Exceptions *(book ch. 12)*

## Core Idea
**Errors and exceptions are entirely different things.** *Errors* are **expected** failure reasons in code you own — they're domain concepts and deserve to be modelled with the same significance as `User` and `Email`. *Exceptions* are **unexpected** failures in code or context you don't own. Model errors as a statically-typed union returned from the function; throw exceptions only when the consumer must be forced to fix something.

## Frameworks Introduced

- **Errors vs. Exceptions** — the load-bearing distinction:

  | | **Errors** | **Exceptions** |
  |---|---|---|
  | Nature | **Expected** reasons an operation failed | **Unexpected** reasons an operation failed |
  | Ownership | Code **we own** (domain/application layer) | Code or context we **don't own** |
  | Complexity type | **Essential** complexity | **Accidental** complexity |
  | Examples | `LoginFailed`, `AccountAlreadyCreated` | Third-party API down, DB unreachable, missing CLI arg |
  | Handling | **Return** them as typed values | **Throw**; wrap I/O in try/catch |

- **One Happy Path, Multiple Sad Paths** — every feature/use case has exactly one success and typically several failures. Enumerate them *when you design the use case*, not after the bug report.
  - `CreateUser` happy path: `CreateUserSuccess` (returns the user's `id`).
  - Domain errors: `UserAlreadyExists`, `EmailInvalid`, `PasswordDoesntMeetCriteria`, `UsernameTaken`.
  - Exceptions: database blows up, a dependency API goes down, some other uncaught error.
  - *"It's only a matter of time until these sad paths are realized… one could even argue it's a lot easier for these sad paths to occur than it is for the happy path."*

- **Aggregate errors with unions** — a union type is *the* tool for modelling both paths in one response object: `type Result = Success | Fail`.

- **The Either type** (credited to Bruno Vegreville) — the concrete infrastructure.

- **Two principles for other people's code**:
  1. **Wrap I/O in a try/catch block.**
  2. **Turn exceptions into meaningful errors** you own (an `ApplicationError`).

- **Throw exceptions when a consumer should be forced to fix the problem** — the *fail fast* rule. Stemmler's examples: a missing third CLI argument; a missing auth token in a payments SDK; a call to a nonexistent REST URL; a subclass that didn't implement an abstract method. *"We can't continue with anything unless the client can properly give us everything we've asked for."*

## Anti-patterns — the two follies

**Folly #1: Return `null`**
```typescript
function CreateUser(email, password) {
  if (!isEmailValid)    { console.log('Email invalid');    return null; }
  if (!isPasswordValid) { console.log('Password invalid'); return null; }
  return new User(email, password);
}
```
Why it fails:
- **Lazy** — requires the caller to *know* that failure means `null`. "Kind of like a bait-and-switch."
- **Provokes mistrust** and litters the codebase with null-checks.
- **Loses information** — two distinct failure states collapse into one `null`. The domain model's expressiveness is gone.

**Folly #2: Log and throw**
```typescript
try {
  const user = CreateUser(email, password);
} catch (err) {
  switch (err.message) {          // ⚠️ Fragile — matching on strings
    case 'The email was invalid':    // handle
    case 'The password was invalid': // handle
  }
}
```
Why it fails:
- Manual throwing means wrapping **your own** code in try/catch everywhere.
- Errors are **not statically typed** — the moment the error text changes, you've "turned this text file into a set of bugs that may be very hard to clue into."

**What's wrong with both**: they're **not expressive** (errors aren't domain concepts), **fragile** (untyped; tests would hinge on implementation details like error text), and **hard for the consumer to use**. Both **leak** — the consumer only learns error handling is needed *after* an error happens.

> Stemmler's framing: unrestrained `throw` is comparable to the **`GOTO`** command Dijkstra fought to remove — it disrupts program flow and makes code hard to walk through.

## Code Example — The `Either` type

```typescript
type Either<S, F> = Success<S, F> | Failure<S, F>;

export class Success<S, F> {
  readonly value: S;
  constructor(value: S) { this.value = value; }

  isSuccess(): this is Success<S, F> { return true; }
  isFailure(): this is Failure<S, F> { return false; }
}

class Failure<S, F> {
  readonly value: F;
  constructor(value: F) { this.value = value; }

  isSuccess(): this is Success<S, F> { return false; }
  isFailure(): this is Failure<S, F> { return true; }
}

// Factory functions — shorthand for creating a valid Either<S, F>
export const success = <S, F>(l: S): Either<S, F> => new Success(l);
export const failure = <S, F>(a: F): Either<S, F> => new Failure<S, F>(a);
```
- **What it demonstrates**: two classes sharing an interface with opposite behavior. The `this is Success<S, F>` return type is a **type predicate** — it's what makes `userResult.value` correctly typed inside each branch.

## Worked Example — `CreateUser`, end to end

**Step 1 — Model the success and failure sides.**

First attempt, modelling errors as `type` aliases, exposes a design flaw:
```typescript
type DomainError = { message: string; }
type EmailInvalid = DomainError;
// ...

if (!isEmailValid()) {
  return failure({ message: 'I have to write the message here?' } as EmailInvalid);
}
```
Two problems: **error message construction leaks into the use case** (it breaks encapsulation — message construction belongs next to the error), and you must **manually cast with `as`**, "which isn't an easy thing to remember not to do."

**Step 2 — Model domain errors as classes instead.** Message construction is now encapsulated:
```typescript
class EmailInvalid implements DomainError {
  public message: string;
  constructor(email: string) {
    this.message = `The email ${email} is invalid.`;
  }
}
class UserAlreadyExists implements DomainError {
  public message: string;
  constructor(username: string) {
    this.message = `The username ${username} is already taken.`;
  }
}
class PasswordDoesntMeetCriteria implements DomainError {
  public message: string;
  constructor(password: string) {
    this.message = `A password must be ..., ${password} is not valid.`;
  }
}
class UsernameTaken implements DomainError {
  public message: string;
  constructor(username: string) {
    this.message = `The ${username} is already in use.`;
  }
}

// Make the success side a class too, for consistency
class CreateUserSuccess {
  id: string;
  constructor(id: string) { this.id = id; }
}
```
> Because TypeScript falls back to **structural typing**, switching from types to classes required **no change to `CreateUserResult`**.

**Step 3 — Declare the result type as an `Either` union:**
```typescript
type CreateUserResult = Either<
  // Success
  CreateUserSuccess,
  // Failures
  UserAlreadyExists |
  EmailInvalid |
  PasswordDoesntMeetCriteria |
  UsernameTaken |
  ApplicationError          // any exception-based errors
>;
```

**Step 4 — Run through all error states, then wrap the I/O:**
```typescript
function createUser(request: CreateUserRequest): CreateUserResult {
  if (!isEmailValid())           return failure(new EmailInvalid(request.email));
  if (!passwordMatchesCriteria()) return failure(new PasswordDoesntMeetCriteria(request.password));
  if (userAlreadyExists())        return failure(new UserAlreadyExists(request.email));
  if (isUsernameTaken())          return failure(new UsernameTaken(request.email));

  let user;
  try {
    // We don't own this code, so we'll wrap it in a try-catch
    user = db.User.save({ email, password });
  } catch (err) {
    return failure(new DatabaseError(err));   // exception → error we own
  }

  return success(new CreateUserSuccess(user.userId));
}
```

**Step 5 — The consumer's experience:**
```typescript
const userResult = createUser({ email: 'khalil', password: 'bingo-bango-boom' });

if (userResult.isSuccess()) {
  userResult.value.id;          // ✅ typed
}

if (userResult.isFailure()) {
  const error = userResult.value;
  switch (error.constructor) {
    case EmailInvalid:
    case PasswordDoesntMeetCriteria:
    case UserAlreadyExists:
    case UsernameTaken:
    default:
  }
}
```
Every failure is discoverable **from the signature**, before running the code.

## Turning exceptions into `ApplicationError`

```typescript
interface ApplicationError {
  message: string;
  error?: any;
}

class DatabaseError implements ApplicationError {
  message: string;
  error?: any;
  constructor(error: string) {
    this.message = "A database error occurred";
    this.error = error;
  }
}
```
**Why generalize it**: which infrastructural exception occurred (database, cache, …) doesn't matter to the consumer. It matters to *you* for logging and reporting — you can reach into the object. But **from a security standpoint it's better to withhold that information from the API consumer** in a web application. This is the 500-status-error equivalent.

## Handling nothingness

Returning `null` for "not found" is "a monkey wrench thrown in the spokes of your bike." At minimum, **signal it explicitly in the signature** so the consumer decides how to handle it up front:

```typescript
type Nothing = null | undefined | '';

class UserService {
  async getUserById(id: string): Promise<User | Nothing> {
    const userOrNothing = await this.db.User.findById({ where: { id } });
    return userOrNothing ? userOrNothing : '' as Nothing;
  }
}
```
Same principle as everything else in the chapter: **make the implicit explicit**.

## Key Takeaways
1. **Errors are returned; exceptions are thrown.** Getting this backwards is the root of most error-handling mess.
2. **Enumerate the sad paths when you design the use case.** One happy path, several sad ones — that's the shape of every feature.
3. **Model domain errors as classes, not type aliases** — so message construction is encapsulated and you never need `as` casts.
4. **Never return bare `null` for failure.** It's untyped, unexpressive, and collapses distinct failures into one.
5. **Never match on error message strings.** The moment the text changes, you have silent bugs.
6. **Wrap all I/O in try/catch and convert exceptions into errors you own.**
7. **Generalize infrastructural errors at the API boundary** — detail for your logs, opacity for your consumers.
8. **Fail fast when the consumer must fix something** — a missing required argument has no recovery path.
9. **Pick a philosophy and be consistent across the entire application.** Stemmler is explicit that these are his opinions; consistency matters more than which choice you make.

## Connects To
- **Ch 06 (Types)** — union types, generics, and type predicates are what make `Either` work.
- **Ch 02 (Human-Centered Design)** — errors as **feedback**, fail-fast as a **constraint**, discoverability of the API.
- **Ch 18 (Design by Contract)** — precondition guards are where you decide throw-vs-return.
- **Ch 21 (DDD)** — "Handling errors as domain concepts" reappears in the DDDForum use cases.
- **Ch 08 (Features/Use Cases)** — the one-happy-path/many-sad-paths model is a property of use cases.
- **Ch 05 (Comments)** / **Ch 04 (Naming)** — making the implicit explicit is the shared theme.

## References
- [khalilstemmler.com — Functional Error Handling](https://khalilstemmler.com/articles/enterprise-typescript-nodejs/functional-error-handling/)
