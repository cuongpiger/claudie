# Chapter 21: Domain-Driven Design & Building DDDForum *(book ch. 56–60, 70)*

## Core Idea
DDD is for projects with **lots of business logic complexity**. The method: discover the domain model with domain experts, agree on a **Ubiquitous Language**, embed those exact terms in code, **protect that zero-dependency domain model** from all technical concerns, and continuously crunch domain knowledge into the implementation. The goal of the code is to **make it virtually impossible to represent an illegal state**.

## Frameworks Introduced

- **The Four-Step DDD Process**:
  1. Discover the domain model by **interacting with domain experts**; agree on a common language for processes, actors, events, and side effects.
  2. **Embed those terms in code** — a rich domain model reflecting the living business and its rules.
  3. **Protect that (zero-dependency) domain model** from databases, web servers, and other technical intricacies.
  4. **Continuously crunch** domain knowledge into a software implementation of that knowledge.

- **Domain model** (the definition): *a **declarative** layer of code, without dependencies on any upper-layer concern, that encapsulates the business rules of a problem domain.* It's the **solution space** to a problem domain.
  - Domain models are **central to the architecture**, hold the **highest-level policy**, are the **most stable** (a drastic domain change would mean a drastic business change — unlikely), **may not rely on anything above them**, yet **can be relied on by every upper layer**.

- **Ubiquitous Language** — the common language describing domain model concepts, learned through conversation with domain experts. Once agreed, those words *become* your classes, use cases, and types.
  > *"To communicate effectively, the code must be based on the same language used to write the requirements — the same language that developers speak with each other and the domain experts."* — Eric Evans
  > *"It is not the domain expert's knowledge that goes to production, it is the **assumption of the developers** that goes to production."* — Alberto Brandolini

- **The Three Enablers of Domain Purity** — you cannot do DDD without all three:
  1. **A Layered Architecture** (formally, Clean Architecture) — separation of concerns
  2. **Dependency Inversion** — keeps inner-layer code testable
  3. **The Dependency Rule** — enforces the use of DI; **source code dependencies always point inward**

## The DDD Building Blocks

| Block | What it is | Compared by | Notes |
|---|---|---|---|
| **Entity** | A domain object we care to **uniquely identify** (`User`, `Post`, `Vinyl`) | **Unique identifier** (UUID/PK) | Lives a lifecycle: created, updated, persisted, retrieved, archived, deleted |
| **Value Object** | Has **no identity**; an *attribute* of an Entity (`Name`, `JobStatus`, `PostTitle`) | **Structural equality** | The target of "wrap all primitives" |
| **Aggregate** | A collection of entities bound by an **aggregate root** | — | Nothing inside the boundary may be referenced externally. **Dispatches Domain Events** — the most powerful part |
| **Domain Service** | Domain logic belonging to no single object conceptually | — | Lives in the Domain Layer, so it **may not depend on Repositories**. Application Services fetch entities and pass them in |
| **Repository** | Retrieves domain objects from persistence | — | LSP + layering means you can swap in-memory (test) → MySQL (today) → MongoDB (in 2 years) |
| **Factory** | Creates domain objects from raw SQL rows, JSON, or ORM Active Records | — | Also via prototype pattern or abstract factory |
| **Domain Event** | An object describing an event **domain experts care about** | — | *"The best part of Domain-Driven Design"* |

## Subdomains & Bounded Contexts
- **Subdomains** create **logical** boundaries; **Bounded Contexts** create **physical** ones.
- A **subdomain** is a smaller logical slice of the **problem space** (everything the business must solve).
- Each subdomain can implement **its very own layered architecture** — horizontal assignment of problems, vertical separation of concerns.

**Eric Evans' three questions to identify the core domain:**
1. What makes the system worth writing?
2. Why not buy it off the shelf?
3. Why not outsource it?

| Type | Meaning | Vinyl-trading example |
|---|---|---|
| **Generic** | Not core; every SaaS needs it; **could be outsourced** (e.g. Auth0) | Users, Notifications, Billing |
| **Supporting** | Necessary and domain-specific, but **not** the main thing | Shipping, Catalog |
| **Core** | The main focus | **Trading** |

> Evans' heuristic: *"The Core domain should deliver about **20% of the total value** of the entire system, be about **5% of the code base**, and take about **80% of the effort**."*

## The Three Aggregate Design Rules
1. **All transactions happen against Aggregates.** The Aggregate owns Command decision-making for a single entity. Every Entity/Value Object inside it must serve that purpose — you need them all loaded to decide whether to allow or reject the Command.
2. **Design Aggregates to be as small as possible.** Small aggregates keep **writes fast**. With CQRS, encapsulate only what's needed for decision-making.
3. **You may not alter entities within the aggregate's transaction boundary without going through the aggregate.**

## Code Examples

**Rule #1 in practice — an Aggregate enforcing a business rule, returning `Either`:**
```typescript
// forum/domain/post.ts
// Attempting to update the link on a post that already has comments → PostSealedError
export type UpdatePostOrLinkResult = Either<
  EditPostErrors.InvalidPostTypeOperationError |
  EditPostErrors.PostSealedError |
  Result<any>,
  Result<void>
>;

export class Post extends AggregateRoot<PostProps> {
  public updateLink(postLink: PostLink): UpdatePostOrLinkResult {
    if (!this.isLinkPost()) {
      return left(new EditPostErrors.InvalidPostTypeOperationError());
    }
    if (this.hasComments()) {
      return left(new EditPostErrors.PostSealedError());
    }
    const guardResult = Guard.againstNullOrUndefined(postLink, 'postLink');
    if (!guardResult.succeeded) {
      return left(Result.fail<any>(guardResult.message));
    }
    this.props.link = postLink;
    return right(Result.ok<void>());
  }
}
```
- **What it demonstrates**: business rules live *inside* the aggregate; failures are typed domain errors, not thrown exceptions.

**Making illegal state unrepresentable — remove the setter:**
```typescript
// users/domain/user.ts
export class User extends Entity<UserProps> {
  get userId(): UserId {
    return this.props.userId;
  }

  // set userId (userId: UserId) {          ← deliberately removed
  //   this.props.userId = userId;
  // }
}
```
**Reasoning**: within the `users` subdomain there is **no reason** a `userId` should ever change. Changing it would break the 1-to-1 relationship with `Member` in the `Forum` subdomain. So the setter doesn't exist. *"It's kind of like building your very own DSL."*

## Worked Example — Domain Events replacing transaction-script `if/else`

**The problem.** In CRUD apps, new domain logic arrives as more `if/else` in the controller. In complex applications (think GitLab or Netflix) this becomes unmanageable:

```typescript
// userController.ts — transaction-script style
class UserController extends BaseController {
  public createUser() {
    // ...
    await User.save(user);

    // 1. Recording a referral (if one was made)
    if (user.referred_by_referral_code) {
      // calculate payouts... a lot more logic could live here
      await Referral.create({
        code: this.req.body.referralCode,
        user_id: user.user_id
      });
    }

    // 2. Sending an email verification email
    EmailToken.createToken();
    await EmailService.sendEmailVerificationEmail(user.user_email);

    // ⚠️ Neither of these is the responsibility of the "user" subdomain
    this.ok();
  }
}
```

**The insight**: referrals and email verification belong to *other subdomains*. The controller has become a coordination point for domain logic it doesn't own.

**The fix**: the `User` **Aggregate** dispatches a `UserCreated` Domain Event. Handlers in the *Referral* and *Notifications* subdomains subscribe. The user subdomain never learns they exist — this is the **Hollywood Principle** and **Observer** at architectural scale, and it's how DDD decouples logic **across Subdomain and Bounded Context boundaries**.

## The DDDForum Architecture — five upfront decisions

A Hacker News–inspired forum. The significant upfront decisions:

| # | Decision | Rationale |
|---|---|---|
| **1** | **Use Domain-Driven Design patterns** | Encode business rules in domain models first; define models, relationships, and the policies governing change; make illegal states unrepresentable |
| **2** | **Use a Layered Architecture** | Isolate the domain layer from DBs, controllers, web servers — things that slow tests and clash with the Ubiquitous Language. Bridge layers with Dependency Inversion; **dependencies always point inward** |
| **3** | **Deploy as a Modular Monolith** | Subdomain boundaries without distributed-systems cost |
| **4** | **Use CQRS** (Command Query Responsibility Segregation) | Keep domain logic pure on the write side; read models can be raw data |
| **5** | **Do *not* use Event Sourcing** | Explicitly rejected — the cost wasn't justified |

**Domain objects have zero dependencies** and create source-code dependencies only to other domain objects — which is why entity, value object, and domain service tests **run very fast**.

**Features walked through in the book**: Creating a Member (with domain events dispatched from Sequelize hooks), Upvoting a Post (Domain Service + aggregate design rules + database transactions), and Get Popular Posts (read models + pagination).

## Anemic vs. rich models — the MVC shortcoming DDD addresses

The framing question from the book's opening story: **"How would you design your business-logic layer?"**

For role-based access (Traders see only their own Vinyl; Admins see everyone's), where do the rules go?
- **In the view?** No — business logic doesn't belong in views.
- **In the controller?** No — controllers handle HTTP and delegate.
- **In the model?** **Yes — but how?**

ORMs (Sequelize, TypeORM) yield **slim, logic-less models** — they're *definition files* whose sole purpose is declaring a schema for object-relational mapping. That leaves the business logic homeless, which is exactly the gap DDD's rich domain model fills.

## Anti-patterns
- **Slim/anemic models** — ORM definition files treated as the domain model. Logic ends up in controllers.
- **Getters and setters on every entity property** — a settable `userId` breaks cross-subdomain relationships. Remove setters that have no domain justification.
- **Domain Services depending on Repositories** — violates the Dependency Rule. Application Services fetch entities and pass them in.
- **Large aggregates** — slow writes. Include only what's needed for the Command decision.
- **Reaching into an aggregate to modify a child entity** — violates Rule #3 and destroys consistency.
- **Growing `if/else` in controllers for cross-subdomain side effects** — use Domain Events.
- **Applying DDD to a simple CRUD app** — DDD is for domains with *lots of business logic complexity*.
- **Outsourcing or buying your core subdomain** — by definition it's the thing that makes the system worth writing.

## Key Takeaways
1. **The domain model has zero dependencies.** Everything else in DDD exists to protect that property.
2. **Ubiquitous Language is not documentation** — those exact words become class names, use case names, and types.
3. **Identify your core subdomain with Evans' three questions**, then spend 80% of your effort on 5% of the code.
4. **Aggregates are transaction boundaries** — all commands go through them, they're kept small, and nothing inside is touched from outside.
5. **Domain Events are how you decouple across subdomains** — the alternative is a controller that knows everyone's business.
6. **Make illegal states unrepresentable.** Deleting a setter is a design decision, and a good one.
7. **Generic subdomains can be bought** (Auth0); supporting ones can't be outsourced but aren't core; core is where you invest.
8. **DDD requires layered architecture + DI + the Dependency Rule.** Without all three, the domain model won't stay pure.

## Connects To
- **Ch 13 (RDD)** — Entities/Value Objects are **Information Holders**, Aggregates are **Structurers**, Domain Services are **Service Providers**, Repositories are **Interfacers**.
- **Ch 07 (Errors)** — `Either` and typed domain errors are how aggregates report rule violations.
- **Ch 06 (Types)** — the `Email` private-constructor example is a Value Object in miniature.
- **Ch 20 (Architecture)** — Layered, Hexagonal, CQRS, and Modular Monolith are the styles in play here.
- **Ch 17 (SOLID)** — LSP makes repository swapping work; DIP is the Dependency Rule.
- **Ch 16 (Design Patterns)** — Repository, Factory, Observer (Domain Events), Composite (aggregates).
- **Ch 14 (Object Calisthenics)** — Rule #3 produces Value Objects; Rule #9 explains why setters get deleted.

## Resources
- The DDDForum source: [github.com/stemmlerjs](https://github.com/stemmlerjs) — full project code
- khalilstemmler.com articles on Entities, Value Objects, Aggregates, Repositories, Static Factory Methods, and "Decoupling Logic with Domain Events"
