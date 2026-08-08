# Chapter 8: Progressing from Metrics to Engineering

**Author**: Neal Ford

## Core Idea
A metric is only a measure; it becomes **engineering** when it is applied **regularly and automatically, against an objective threshold, on every code change**. Fitness functions are the unifying name for that practice — an executable checklist of the important-but-not-urgent principles that schedule pressure otherwise erodes.

## Frameworks Introduced

- **Architecture fitness function** — "any mechanism that provides objective evaluation criteria for architecture characteristic(s)." Read the definition backwards; every clause is load-bearing:
  - **"architecture characteristic(s)"** — design splits into the **domain** (the problem you're writing software for) and **architecture characteristics** (also called nonfunctional requirements, cross-cutting requirements, system quality attributes): performance, scalability, elasticity, availability, and many more. Fitness functions target architecture characteristics **because mature tooling already exists for the domain** (unit, functional, user-acceptance testing). Their contribution is **unifying validations that were always related but never treated uniformly** — previously scattered across build-time checks, production monitors, forensic logging, and other tools.
  - **"objective evaluation criteria"** — the industry has never succeeded at a standard list of architecture characteristics, because the ecosystem changes too fast (web performance measures don't suit mobile). Whatever the characteristic, an architect must be able to measure it **objectively** to validate it.
  - **Composite architecture characteristic** — one too encompassing to measure directly, e.g. *reliability*, which subsumes availability, data integrity, and others. **Heuristic**: if you can't work out how to measure something, it's probably a composite — decompose it further.
  - **"any mechanism"** — developers expect one testing tool per platform, but architecture spans platforms and behaviours. Expect to use **testing libraries, performance monitors, chaos engineering, metrics tools like SonarQube, holistic stress-testing frameworks like Netflix's Simian Army** — and fitness functions overlap with unit testing rather than replacing it.

- **The metric → engineering transformation** — the chapter's central mechanic. A metric becomes a fitness function via **regular application, preferably automated on every code change, modeled after unit and other domain testing**, with **objective thresholds established**.
  - **The failure mode it fixes**: wiring SonarQube into the build to produce dashboards, but never running the metrics regularly against thresholds — so the gathered metrics become **evidence after the fact rather than a proactive force**.
  - Fitness functions sit **alongside** unit, functional, and user-acceptance testing in the pipeline; constant execution means governance violations are caught as fast as possible.

- **Automation as the optimizing force for engineering** — the historical argument, in three episodes:
  - **XP and TDD** (Kent Beck, C3 project, early 1990s) — unimpressed by the era's processes, the team took what they knew worked and did it in the most extreme way. Observation: higher test coverage correlated with higher-quality code → **test-driven development**, which *guarantees* all code is tested because tests precede code.
  - **Continuous integration** — the era's practice was weeks or months of isolated coding followed by an **integration phase**, a manufacturing metaphor that tools like ClearCase actively enforced. The XP developers noticed **more frequent integration correlated with fewer issues** → every developer commits to the mainline at least once a day. Teams using CI don't just spend less time on merges each time; they spend **less time overall**, because conflicts are resolved as they appear instead of letting "the combinatorial mass of merge conflicts grow into a ball of mud" to untangle at the end.
  - **DevOps (early 2000s)** — teams manually installing operating systems and applying patches let important problems fall through the cracks; **Puppet and Chef** automated provisioning and enforced consistency.
  - **The same pattern applied to governance**: architects were doing governance via code reviews, architecture review boards, and other manual, bureaucratic processes. Tying fitness functions to CI converts those checks into **regularly applied integrity validation** — preventing damaging code from entering the repository at all, **without requiring superhuman diligence from architects**.

- **The fitness-function-as-checklist framing** (Atul Gawande, *A Checklist Manifesto*) — surgeons and airline pilots use checklists not because they don't know their jobs or are forgetful, but because **performing the same task repeatedly makes it easy to fool yourself when a step is accidentally skipped**. Fitness functions are the architect's checklist of important-but-not-urgent principles, run as part of the build so developers can't skip them — accidentally *or* purposefully under schedule pressure.
  - **This is the named cause of technical debt**: "We know this is bad, but we'll come back to fix it later"… and later never comes.

## Key Concepts
- **Fitness function (origin)** — from genetic algorithms: an objective function that helps determine a design's suitability, used to influence mutation. **Roulette mutation** is the named example: where an algorithm uses constant values, the mutation picks a new value at random as if from a roulette wheel.
- **Component cycle** — a cyclic dependency between components. An anti-pattern because **reusing one entangled component drags all the others along**; architects want the count kept low.
- **Fidelity fitness function** — one that compares old and new implementations to guarantee they produce the same results, answering "how do I replace this old system and be sure the new one behaves identically?"
- **Zero-day exploit governance slot** — a stage reserved in every project's deployment pipeline where the security team can deploy fitness functions.

## Code Examples

**Component cycle check with ArchUnit** — a testing tool inspired by (and using facilities of) JUnit, for testing architecture features:
```java
public class CycleTest {
    @Test
    public void test_for_cycles() {
        slices().
          matching("com.myapp.(*)..").
          should().beFreeOfCycles()
    }
}
```
- **What it demonstrates**: a metric available in dozens of tools becomes engineering purely through continual automated application. **Why this one matters**: modern IDEs pop up an **autoimport dialog** whenever you reference an unreferenced package, and developers "swat it away as a reflex action, never actually paying attention." Usually harmless; occasionally it creates a component cycle. No code review reliably catches that; an automated check does.

**Layered-architecture governance with ArchUnit** — an English-like unit test using ArchUnit's Hamcrest matchers to define layer relationships and preclude undesirable coupling:
```java
layeredArchitecture()
  .layer("Controller").definedBy("..controller..")
  .layer("Service").definedBy("..service..")
  .layer("Persistence").definedBy("..persistence..")

  .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
  .whereLayer("Service").mayNotBeAccessedByAnyLayer("Controller")
  .whereLayer("Persistence").mayNotBeAccessedByAnyLayer("Service")
```
- **What it demonstrates**: an architect can ensure a designed topology is actually *implemented* — whether teams are ignorant of why isolation matters, or work somewhere "asking for forgiveness is preferable to asking for permission."
- **Limits**: ArchUnit is Java-only and compile-time only. **NetArchTest** is the .NET equivalent. Neither helps with distributed architectures.

**Hand-rolled fitness function for a microservices orchestration rule** (pseudocode) — enforcing that domain services talk only to the orchestrator, never to each other:
```ruby
def ensure_domain_services_communicate_only_with_orchestrator
  list_of_services = List.new()
                          .add("orchestrator")
                          .add("order placement")
                          .add("payment")
                          .add("inventory")
  list_of_services.each { |service|
     service.import_logsFor(24.hours)
     calls_from(service).each { |call|
        unless call.destination.equals("orchestrator")
            raise FitnessFunctionFailure.new()
      }
    }
end
```
- **What it demonstrates**: no framework can exist for this — building one would be nearly impossible given the variation among distributed architectures — so the architect writes code to **discover** the information (here: 24 hours of per-service call logs, parsed for destination) and raise on rule violation. **Variant**: with real-time monitors instead of forensic logging, the same function becomes event handlers that investigate and alert on incorrect calls.
- **The lesson**: "architects must not despair if they cannot immediately find a ready-made tool" — many modern tools allow small ad hoc fitness functions to glue their output together.

**GitHub's Scientist — a fidelity fitness function in production**:
```ruby
def create_merge_commit(author, base, head, options = {})
  commit_message = options[:commit_message] || "Merge #{head} into #{base}"
  now = Time.current

  science "create_merge_commit" do |e|
    e.context :base => base.to_s, :head => head.to_s, :repo => repository.nwo
    e.use { create_merge_commit_git(author, now, base, head, commit_message) }
    e.try { create_merge_commit_rugged(author, now, base, head,
        commit_message) }
  end
end
```
- **What it demonstrates**: the `science` block dispatches two clauses — `use` (old code) and `try` (new code). **`use` always executes and its output is always what the user receives, so the user never realizes they're in an experiment.**

## Reference Tables

| Concern | Java | .NET | Distributed / other |
|---|---|---|---|
| Component cycles | ArchUnit | NetArchTest | Hand-rolled |
| Layer coupling rules | ArchUnit (compile-time) | NetArchTest | Hand-rolled from logs or monitors |
| Code quality metrics | SonarQube | SonarQube | SonarQube |
| Holistic resilience | Simian Army / chaos engineering | — | Chaos engineering |
| Old-vs-new fidelity | Scientist (and ports) | — | Scientist pattern |

## Worked Example

### Case study: Zero-day security check (Equifax)
The timeline, as the chapter lays it out:
- **7 March 2017** — the Apache Foundation announces the Struts vulnerability (CVE-2017-5638) and releases a patch.
- **8 March 2017** — the Department of Homeland Security warns Equifax and similar companies.
- **15 March 2017** — Equifax runs scans that find *most* of the affected systems… **most of them**.
- **29 July 2017** — the critical patch still hadn't reached many older systems; security experts identify the hacking behaviour.
- **7 September 2017** — Equifax announces the data breach.

The alternative world: **every project has a deployment pipeline — even idle ones — and the security team owns a "slot" in each pipeline** where it can deploy fitness functions. Most of the time that stage does mundane chores (e.g. preventing developers from storing passwords in databases). But when a zero-day appears, the same mechanism lets security **insert a test in every project checking for a framework and version number, and kick off a build**; if the dangerous version is present, the build fails and security is notified.

Pipelines are configured to **awaken for any change to the ecosystem** — code, database schema, deployment configuration, *and fitness functions*. That's what makes governance universal, and it shows the scope of "metrics" can be as broad as an organization needs, not just low-level code evaluation.

### Case study: Coupling — when the tool exists, and when you build it
The layered-architecture case (ArchUnit above) and the microservices-orchestration case (pseudocode above) are deliberately paired: **first use an existing tool, then build one when necessary.** The reasoning behind the second: "most architectures aren't generic but rather a hodgepodge combination of good/bad, old/new, and chosen/imposed tools, as well as frameworks, packages, and so on."

### Case study: Fidelity fitness functions — GitHub's "Move Fast and Fix Things"
GitHub does **continuous deployment averaging 60 deployments per day**, at a scale where edge cases appear almost instantly. The target: replace merging performed by a **shell script invoking command-line Git** — flawless but poorly scaling — with new **in-memory merge** functionality.

They tested the new behaviour, but deployment was still the scary part: bad enough if the merge code fails, but **what if an unknown coupling point in the old merge code causes a more catastrophic failure?** "This is the fear that keeps many teams from embracing modern techniques."

Their answer, open-sourced as **Scientist**. When both `use` and `try` execute, the framework:
- **randomizes the order** of `use` and `try` to prevent timing anomalies,
- **compares the results** of both calls for fidelity,
- **swallows but records** any exception raised by `try`,
- **publishes results to a dashboard**.

Operational details that make it work:
- The architect configures **how often** `try` also runs — for the merge experiment, **1% of requests**.
- The dashboard showed just over **2,000 merges at 02:20**; at GitHub's scale the errors were invisible in that view, so a separate errors view was needed. **There were bugs in the new code** — and because of Scientist, users never saw them. Developers fixed and redeployed, with continuous deployment running throughout for this experiment and everything else.
- Performance improvement — one of the experiment's goals — was visible in the metrics.
- They ran it **four days, until they had 24 hours with no mismatches and no slow cases**, then deleted the old merge code. Over those four days: **more than 10 million experiments**, hence high confidence.

Scientist is a fidelity fitness function **implemented using feature toggles and performance metrics** — and the case study "pokes a hole in the common argument that aggressive Agile engineering practices such as continuous deployment increase risk to an unacceptable degree." Teams using these practices find ways to mitigate the risk.

## Anti-patterns
- **Gathering metrics without regular execution against thresholds** — turns them into after-the-fact evidence rather than a proactive force.
- **Component cycles** — and relying on human vigilance (or IDE autoimport discipline) to prevent them.
- **Manual governance** — code reviews and architecture review boards require intervention and *delay* the check.
- **Architects forming a cabal in an ivory tower** to build an impossibly complex, interlocking set of fitness functions that merely frustrate developers and teams. **Fitness functions can be overused.**
- **The integration phase** — letting merge conflicts accumulate into a ball of mud to be untangled at project end.
- **"We know this is bad, but we'll come back to fix it later."**
- **Giving up when no ready-made tool exists** for the validation you need.
- **Assuming metrics must be low-level code evaluations** — the Equifax scenario shows organization-wide scope.

## Key Takeaways
1. Metric + objective threshold + automated execution on every change = engineering. Any two of the three is not enough.
2. Fitness functions unify architecture-characteristic validation that was previously scattered across build checks, monitors, and logs.
3. If you can't measure an architecture characteristic, it's probably composite — decompose it until you can.
4. "Any mechanism" is literal: unit-test libraries, SonarQube, monitors, chaos engineering, and hand-written scripts all qualify.
5. When no framework exists for your architecture (especially distributed), hand-roll a fitness function from logs or monitors — that is the expected case, not a failure.
6. Put a governance slot in every project's pipeline, including idle projects, so a zero-day can be swept organization-wide automatically.
7. To replace a system safely, run old and new side by side on a sampled fraction, return only the old result to users, compare for fidelity, and cut over on an evidence threshold (GitHub: 24 clean hours after 10M+ experiments).
8. Treat fitness functions as a checklist for the important-but-not-urgent — that's the mechanism by which technical debt stops accumulating.

## Connects To
- **Ch 2** (Weiss): the fitness function categories, the pyramid, and the 7-step development process — the complementary "how to design them" chapter.
- **Ch 7** (Woods): fitness functions consume measurements; that chapter supplies the measurement mechanisms.
- **Ch 4** (Lilienthal) and **Ch 9** (von Zitzewitz): cycles and coupling as the canonical structural metrics to wrap in fitness functions.
- **Ch 3** (Farley): the deployment pipeline as the definitive evaluation of releasability — the vehicle every fitness function rides in.
- **Ch 1** (Harmel-Law): the four key metrics measure the pipeline these functions live in.
- **Building Evolutionary Architectures** (Ford, Parsons, Kua); **Atul Gawande, *A Checklist Manifesto***; **Vicent Martí, "Move Fast and Fix Things"** (GitHub blog, 2015); **ArchUnit**, **NetArchTest**, **SonarQube**, **Scientist**, **Simian Army**, **Puppet/Chef**.
