# Chapter 03: Organizing Things & Documentation *(book ch. 6–7)*

## Core Idea
Structure your folders around **features (use cases)**, not technology. Features are **vertical slices** cutting through every layer, and they're the **entry point** for all work you're ever assigned. A feature-driven structure makes the codebase *scream* what the system does. The repository README then answers the handful of questions a new developer actually has, and **tests act as the primary form of documentation**.

## Frameworks Introduced

- **The Three Symptoms of Poor Project Structure** — the diagnostic:
  1. **Forgetting what the system does** — you return after a few months and can't remember its capabilities.
  2. **Hard to locate features** — "how long does it take to find the `login` feature and *all* the code associated with it?"
  3. **Energy spent flipping back and forth between files** — the *distance* between a feature's files determines the cognitive load of changing it.

- **The Three-Question Test for any structure** — apply it to each candidate approach:

| Approach | Remember what it does? | Locate features? | Reduce file-flipping? |
|---|---|---|---|
| **Just evolve it over time** | ❌ No | ❌ No | ❌ No |
| **Package by infrastructure/technology/type** | ❌ No | ❌ No | ❌ No |
| **Package by domain** | 🟡 General idea | ✅ Yes, if you know the top-level domains | ❌ No |
| **Package by feature (use case)** | ✅ | ✅ | ✅ |

  - "Just evolve it" fails hardest with **more than one developer** — a recipe for conflicts and constant "does this belong here?"
  - "Package by type" is the pattern-matcher's trap: features are split across several unrelated folders, so changing or removing one requires intimate knowledge of how it's realized across all of them. Discoverability for a *new* developer is remarkably low.

- **Features are vertical slices**: *systems are merely features/use cases and the infrastructure that supports them.* A `CreateUser` feature on the frontend spans the signup form (presentation), form-checking (interaction logic), and the API call plus caching (transport & persistence).

- **Screaming Architecture** (Robert C. Martin):
  > *"Software architectures are structures that support the use cases of the system. Just as the plans for a house or a library **scream** about the use cases of those buildings, so should the architecture of a software application scream about the use cases of the application."*

  When you open your editor, does the project scream "this is a React app" — or "this is forum software"? You want the latter.

- **The Four Project Organization Rules**:
  1. **Use top-level conventions** — `src/` (source), `dist/` (compiled output), `public/` (web-served; assume anything here is publicly readable).
  2. **It belongs to a feature or it's shared.** Two places, always. That's what makes placement *consistent*.
  3. **Group files related to a particular feature** — including **tests colocated with production code**.
  4. **Fight the framework.** Frameworks push package-by-infrastructure. *"We have very different goals from framework designers. For us — discoverability; for them — getting all the pieces up and working."* Tuck framework code into `/shared/infrastructure/<framework_name>/`.

- **The Documentation Abstraction Hierarchy** — push complexity downwards:
  > **Repository → feature folders → tests → implementation boundary (controller or page) → implementation internals**

## Code / Structure Examples

**Backend — feature-driven:**
```
src/
  modules/                    # Top-level modules of our application
    users/                    # Domain
      useCases/               # Use cases / features
        createUser/
        editUser/
        deleteUser/           # Delete user feature
          DeleteUserUseCase.ts       # Use case
          DeleteUserErrors.ts        # Errors
          DeleteUserController.ts    # Controller
          DeleteUserDTO.ts           # DTO
  shared/                     # Everything else is shared
    core/
    infra/
    utils/
```

**Colocate tests — don't mirror the tree:**
```
# ❌ Parallel tests/ tree
src/modules/users/useCases/createUser/createUser.ts
tests/users/useCases/createUser/createUser.spec.ts

# ✅ Colocated
src/modules/users/useCases/createUser/createUser.ts
src/modules/users/useCases/createUser/createUser.spec.ts
```
**Why**: a parallel tree makes refactoring more complicated and forces the developer to remember to adjust two structures every time. More fundamentally, **it doesn't promote cohesive modules**.

**What goes in `shared/`:**

| Frontend | Backend |
|---|---|
| Configuration files / setup | Configuration files / application setup |
| Generic components (`Button`, `TextInput`, `InputField`) | Database infrastructure (connections) |
| Global state not belonging to a page (`services`, `hooks`, `graphql`) | Caching infrastructure (Redis adapter) |
| State management config (Apollo Client, Redux) — **but not** page-specific actions/queries/mutations | API infrastructure (GraphQL, web server setup) |

## Worked Example — Frontend: pages are where features live

**The argument for page (container) components:** most developers don't distinguish container from presentational components — *"it is exactly this lack of distinction that keeps client-side architecture hard to reason about."*

A **page** is the top-level component rendered when you land on a route:
```tsx
function App() {
  return (
    <Router>
      <Route path="/" exact component={HomePage} />
      <Route path="/login" component={LoginPage} />
      <Route path="/dashboard" component={DashboardPage} />
    </Router>
  );
}
```

**Pages have a 1-to-many relationship with features** — and **it's through the pages that we test features** with acceptance tests (E2E or integration style).

Turning a functional requirement into a test:
> *Given "I have an account", When "I try to login", Then "I should be redirected to the dashboard".*

```typescript
describe('Scenario: Successful login', () => {
  describe('Given I have an account', () => {
    describe('When I try to login', () => {
      test('Then I should be redirected to the dashboard', async () => {
        // Arrange — mock the LOGIN mutation
        const mocks = [{
          request: {
            query: LOGIN,
            variables: { input: { email: 'khalil@apollographql.com', password: 'tacos' } } as LoginVariables,
          },
          result: { data: { login: { __typename: 'LoginSuccess', /* ... */ } } },
        }];
        // ...
      });
    });
  });
});
```
- **What it demonstrates**: the Given-When-Then structure of the requirement maps 1:1 onto nested `describe` blocks. The test *is* the documentation for that feature.

## Six Benefits of Feature-Driven Organization
1. **The features are the essential complexity** — components, services, hooks, and objects are implementation details by comparison.
2. **Improved discoverability of what you can do** — folder names signify the system's capabilities, especially for new developers.
3. **Easily discover where code belongs** — feature folder or shared. Two options means *consistent* placement.
4. **Use case folders act as workspaces** — you stop flipping between distant files.
5. **Constrains future changes to a single spot** — less ripple. **Diagnostic**: *if you have to flip between feature folders when doing feature work, there may be a coupling problem.*
6. **Testable architecture** — you test *features*, not just React components.

## The Repository as Leverage — six questions a README must answer
> *"A well-designed repository accounts for the most common things a new developer needs to know… having the codebase answer questions for us instead of having to answer them over and over."*

1. **What is this?** — a title and a one-sentence description.
2. **What is it for?** — helps developers build **affordances** ("ah, this can be used for the problem I'm having").
3. **How do I get started?** — if it's a few commands, make them **copy-and-pastable**.
4. **How do I run the tests?** — should be a single command; link out to an install guide if it's involved.
5. **How do I debug it?** — special flags or modes belong here.
6. **Where are the features?** — with a feature-driven structure, this is the fastest path to productivity.

**Tests as documentation**: *"Our tests will act as the primary form of documentation."* For the ~90% building enterprise applications and web apps for paying customers, **written API documentation may be more work than it's worth**. For developer-tooling teams maintaining public SDKs, libraries, or frameworks (Apollo, Stripe), documentation *is* paramount. For everyone else, what matters is learning **the system's use cases, where they are in the code, and how to add, change, and remove them.**

## Anti-patterns
- **Package by infrastructure/technology/type** (`components/`, `hooks/`, `services/`, `utils/`) — the most common structure and the worst on all three criteria.
- **A parallel `tests/` folder tree** — doubles refactoring cost and breaks module cohesion.
- **Letting the framework dictate your structure** — its goals aren't your goals.
- **Not distinguishing container from presentational components** — the root cause of hard-to-reason-about client architecture.
- **Flipping between feature folders to do one feature's work** — that's a coupling smell, and the folder structure is what makes it visible.
- **Writing extensive API docs for an internal enterprise app** — likely more work than it's worth; invest in tests instead.

## Key Takeaways
1. **Organize by feature (use case), not by type.** It's the only approach that passes all three questions.
2. **Two places for any file: a feature folder, or `shared/`.** That constraint is what makes placement consistent.
3. **Colocate tests with the code they test.**
4. **Your architecture should scream the domain, not the framework.**
5. **Folder boundaries surface coupling** — cross-folder flipping during feature work is a diagnostic signal.
6. **Pages are where frontend features live**, and where you write acceptance tests.
7. **The README answers six questions** and then hands off to feature folders → tests → implementation.
8. **Tests are your documentation** unless you ship a public SDK.

## Connects To
- **Ch 02 (Human-Centered Design)** — proximity, grouping, discoverability, and affordances applied to folder structure; the "gulf of execution."
- **Ch 01 (Complexity)** — file-flipping *is* cognitive load; organizing by type is named there as a cause.
- **Ch 08 (Features/Use Cases)** — why the use case is the unit of everything.
- **Ch 09 (Acceptance Tests)** — Given-When-Then feature tests live in the feature folder.
- **Ch 20 (Architecture)** — vertical boundaries is this principle at architectural scale.
- **Ch 21 (DDDForum)** — a real codebase using exactly this structure.

## References
- *Clean Architecture* — Robert C. Martin (Screaming Architecture)
- Client-Side Architecture Basics [2020] — khalilstemmler.com
- DDDForum folder structure on GitHub
