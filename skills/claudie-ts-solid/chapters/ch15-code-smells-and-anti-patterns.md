# Chapter 15: Detecting Code Smells & Anti-Patterns *(book ch. 36)*

## Core Idea
Three distinct concepts, in increasing severity: **symptoms of complexity** (design smells — early, pre-smelly warning signs), **code smells** (concrete patterns hinting at a deeper design problem), and **anti-patterns** (well-known recurring "solutions" that produce negative consequences). Smells you refactor; anti-patterns you **avoid from the start** — they usually can't be fixed in one session.

## Frameworks Introduced

- **The Three-Tier Severity Model**
  | Level | What it is | Response |
  |---|---|---|
  | **Symptoms of complexity** | Sprawling conditionals, unclear module boundaries, methods that keep growing | Refactor incrementally *now* — cheapest moment |
  | **Code smells** | Concrete patterns: Long Parameter List, Large Class, Feature Envy | Investigate; small tweak or restructure depending on depth |
  | **Anti-patterns** | God Object, Golden Hammer | Can't be refactored away — requires rethinking architectural foundations |

- **The Five Categories of Code Smells** — the classification that makes smells systematic:
  1. **Bloaters** — code/methods that grow excessively large and unwieldy. *Symptoms*: long methods, wide classes, hefty parameter lists, repeated blocks.
  2. **Object-orientation abusers** — procedural code forced into an OO structure. *Symptoms*: over-reliance on `static` state, long `switch` statements that should be polymorphic, bypassing encapsulation.
  3. **Change preventers** — code that makes change cascade. *Symptoms*: **Shotgun Surgery** (one change → many files), **Parallel Inheritance Hierarchies**.
  4. **Dispensables** — elements serving no purpose. *Symptoms*: dead code, unused parameters, redundant comments.
  5. **Couplers** — **inappropriate intimacy** between modules. *Symptoms*: one class reading another's private fields; two classes depending on each other's internals.

- **The Three Prevention Strategies** (in the order Stemmler applies them):
  1. **Object Calisthenics** — "keeping a good baseline of form. It'd be very hard to have a ton of code smells if you keep this in mind as you're coding."
  2. **Object Role Stereotypes** — while coding, ask *"what stereotype is this?"* If it's more than one or two — **or you can't tell** — refactor.
  3. **Refactoring techniques** — two steps: (1) identify the smell, (2) apply the matching refactoring.

## Reference Table — smell → refactoring

| Smell (category) | Apply |
|---|---|
| **Data Clumps** (bloater) | Introduce Parameter Object, Encapsulate Collection |
| **Long Function** (bloater) | Extract Method, Introduce Parameter Object |
| **Switch Statements** (OO abuser) | Replace Conditional with Polymorphism |
| **Shotgun Surgery** (change preventer) | Move Method, Inline Class, Encapsulate Collection |
| **Comments** (dispensable) | Extract Method, Rename Variable, Replace Comment with Function |
| **Inappropriate Intimacy** (coupler) | Hide Delegate, Move Method |

## The Seven Most Common Code Smells
> *"Out of all the code smells that come up, there are 7 that are like weeds that just keep cropping up. Focus on dealing with these and you'll be in good shape."*

1. **Duplication** → Extract Method or Template Method
2. **Long Method** → break into smaller, focused methods
3. **Large Class** → Extract Class
4. **Long Parameter List** → Introduce Parameter Object, or Replace Parameter with Method Call
5. **Primitive Obsession** → replace primitives with Value Objects that encapsulate behavior
6. **Feature Envy** → move the method to the class it operates on most
7. **Message Chains** → replace chains with intermediary methods or objects

## Code Examples

**Bloater — Long Function + Long Parameter List:**
```typescript
// ❌ Seven parameters, seven jobs
function processOrder(
  userId: string, productId: string, shippingAddress: string,
  paymentMethod: string, discountCode?: string,
  giftWrap?: boolean, loyaltyPoints?: number
) {
  // 1. Retrieve user  2. Validate payment  3. Apply discount
  // 4. Calculate loyalty points  5. Generate invoice  6. Send email
  // (imagine another 50+ lines)
}

// ✅ Introduce Parameter Object + Extract Method
interface OrderRequest {
  userId: string;
  productId: string;
  shippingAddress: string;
  paymentMethod: string;
  discountCode?: string;
  giftWrap?: boolean;
  loyaltyPoints?: number;
}

class OrderProcessor {
  public processOrder(request: OrderRequest): void {
    const user = this.retrieveUser(request.userId);
    if (!this.validatePayment(request.paymentMethod, user)) {
      throw new Error("Invalid payment method");
    }
    const discount = this.applyDiscount(request.discountCode);
    const pointsUsed = this.applyLoyaltyPoints(request.loyaltyPoints, user);
    const invoice = this.generateInvoice(request, discount, pointsUsed);
    this.sendConfirmation(user, invoice);
  }
  private retrieveUser(userId: string) { /* ... */ }
  private validatePayment(paymentMethod: string, user: any) { /* ... */ }
  private applyDiscount(discountCode?: string) { /* ... */ }
  // ...
}
```

**OO Abuser — Replace Conditional with Polymorphism:**
```typescript
// ❌ One class controlling every shape's behavior — adding a shape means editing the switch (OCP violation)
class Shape {
  constructor(public type: ShapeType, public dimensionA: number, public dimensionB: number) {}
  public calculateArea(): number {
    switch (this.type) {
      case ShapeType.Circle:    return Math.PI * this.dimensionA * this.dimensionA;
      case ShapeType.Rectangle: return this.dimensionA * this.dimensionB;
      case ShapeType.Triangle:  return 0.5 * this.dimensionA * this.dimensionB;
      default: return 0;
    }
  }
}

// ✅ Each shape encapsulates its own behavior; no central switch
abstract class ShapeBase {
  constructor(public dimensionA: number, public dimensionB: number) {}
  public abstract calculateArea(): number;
}
class Circle    extends ShapeBase { calculateArea() { return Math.PI * this.dimensionA ** 2; } }
class Rectangle extends ShapeBase { calculateArea() { return this.dimensionA * this.dimensionB; } }
class Triangle  extends ShapeBase { calculateArea() { return 0.5 * this.dimensionA * this.dimensionB; } }

function printShapeArea(shape: ShapeBase) {
  console.log("Area:", shape.calculateArea());
}
```

**Coupler — Inappropriate Intimacy:**
```typescript
// ❌ Casting through `any` to read private fields
class UserStatistics {
  public logProfileData(profile: UserProfile) {
    console.log("Logging user data:",
      (profile as any)._username,
      (profile as any)._email
    );
  }
}

// ✅ Hide Delegate — or Move Method onto the owner
class UserProfile {
  constructor(private username: string, private email: string) {}
  public getUsername(): string { return this.username; }
  public getEmail(): string    { return this.email; }

  // If logging is truly part of the domain, move it here:
  public logProfileData(): void {
    console.log("Logging user data:", this.username, this.email);
  }
}
```
> The `as any` cast to reach a private field is the loudest coupler tell in TypeScript — treat it as an automatic finding.

## Worked Example — Shotgun Surgery → Strategy

**The smell.** Role checks scattered across the codebase. Add a role or a permission, and you must find and edit every one of them — easy to miss a file, giving inconsistent behavior:

```typescript
export enum UserRole { Regular = "REGULAR", Admin = "ADMIN", Moderator = "MODERATOR" }

function canDeletePost(userRole: UserRole) {
  return userRole === UserRole.Admin || userRole === UserRole.Moderator;
}
function canBanUser(userRole: UserRole) {
  return userRole === UserRole.Admin;
}
// ...and repeated role checks across many other files
```

**The refactoring.** Consolidate into a `PermissionChecker` role, one implementation per user role, resolved by a single factory:

```typescript
interface PermissionChecker {
  canDeletePost(): boolean;
  canBanUser(): boolean;
}

class RegularUserPermissions implements PermissionChecker {
  public canDeletePost(): boolean { return false; }
  public canBanUser(): boolean    { return false; }
}
class AdminPermissions implements PermissionChecker {
  public canDeletePost(): boolean { return true; }
  public canBanUser(): boolean    { return true; }
}
class ModeratorPermissions implements PermissionChecker {
  public canDeletePost(): boolean { return true; }
  public canBanUser(): boolean    { return false; }
}

function getPermissionChecker(role: UserRole): PermissionChecker {
  switch (role) {
    case UserRole.Admin:     return new AdminPermissions();
    case UserRole.Moderator: return new ModeratorPermissions();
    default:                 return new RegularUserPermissions();
  }
}
```

**Result**: adding a new role means adding one class and one line in the factory — a single point of change instead of a shotgun blast. Note the *one* remaining switch is acceptable: it lives in the factory, which is exactly where a creational decision belongs.

## Anti-patterns
- **God Object** — a class hoarding too many responsibilities. Architectural rethink, not a refactoring.
- **Golden Hammer** — always using the same tool/solution even when it doesn't fit.
- **`as any` casts to reach private state** — inappropriate intimacy made explicit.
- **Comments that restate the method name** — a dispensable; rename the method instead.
- **Dead code kept "just in case"** — clutters and misleads readers.
- **Treating a code smell as proof of a defect** — smells are *hints*, not guarantees. Some are trivial to fix; others signal a deeper restructure. Judge each.

## Key Takeaways
1. **Catch symptoms of complexity before they become smells** — that's the cheapest refactoring window.
2. **Anti-patterns can't be refactored away.** Avoid them up front; smells you can fix later.
3. **Classify before you fix** — the five categories turn "this feels wrong" into a specific refactoring.
4. **The `switch`-on-type is the #1 OO abuser** — Replace Conditional with Polymorphism, and you satisfy OCP for free.
5. **Prevention beats detection**: Calisthenics for form, Stereotypes for cohesion, Refactorings for repair.
6. **"What stereotype is this?" is the cheapest running check** — if you can't answer, or the answer is three, refactor.
7. **Master the seven weeds** — Duplication, Long Method, Large Class, Long Parameter List, Primitive Obsession, Feature Envy, Message Chains — and most of the rest never appears.

## Connects To
- **Ch 14 (Object Calisthenics)** — prevention strategy #1; Rule #3 directly prevents Primitive Obsession, Rule #5 prevents Message Chains.
- **Ch 13 (Responsibility Driven Design)** — prevention strategy #2; the stereotype question.
- **Ch 17 (SOLID)** — the switch-statement smell *is* an OCP violation; God Object *is* an SRP violation.
- **Ch 16 (Design Patterns)** — Strategy, Template Method, and Polymorphism are the destinations of most refactorings here.
- **Ch 19 (Coupling & Connascence)** — Couplers are connascence made visible.
- **Ch 12 (TDD)** — refactoring happens in the Refactor step; that's where these get applied.

## References
- *Refactoring* — Martin Fowler
- [refactoring.guru/refactoring/smells](https://refactoring.guru/refactoring/smells)
- [github.com/stemmlerjs/CodeSmells](https://github.com/stemmlerjs/CodeSmells)
- *Agile Technical Practices Distilled*
