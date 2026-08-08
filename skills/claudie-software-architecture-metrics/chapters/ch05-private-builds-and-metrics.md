# Chapter 5: Private Builds and Metrics — Tools for Surviving DevOps Transitions

**Author**: Christian Ciceri

## Core Idea
When "DevOps" has degenerated into a separate automation team with its own ticket queue (the **ownership shift** anti-pattern), you cannot fix broken builds and you cannot trust the pipeline as your validation authority — so move validation back to the **local environment via private builds**, and use three process metrics to find and prove where the weak spot is.

## Frameworks Introduced

- **Ownership shift** (the author's named anti-pattern) — DevOps stops being a culture and becomes "modern SysAdmin": a structured automations team with its own ticketing workflow. Symptoms:
  - Job roles demand ops skills (automation tools, system scripting) but rarely solid development knowledge.
  - The development team barely knows where or how deployments happen, is separated from the automations workflow, **yet validations are delegated to them**.
  - QA operates separately too. Silos return, and with them the **environment mismatch** between local development and production.
  - **Why it matters**: Fowler's "fix broken builds immediately" silently assumes (a) builds can only break via codebase changes, so a codebase change can fix them, and (b) team members can debug a build autonomously *and* have the access and permissions to fix it. Under ownership shift, **neither assumption holds** — so the build stays broken on the DevOps team's schedule, QA can't review, and the software is left undeliverable.

- **The private build** (Duvall, Matyas & Glover, *Continuous Integration*) — "To prevent broken builds, developers should emulate an integration build on their local workstation IDE after completing their unit tests." It integrates your new working software with everyone else's, by pulling from version control and building locally with recent changes.
  - **When to use**: always a best practice; becomes **critical** when automations and validations are disconnected from the development team.
  - **How**: run it in a **dedicated environment before changes enter the shared mainline**. "Local" means *the environment in which changes are normally introduced* — commonly, but not necessarily, the developer's machine; a dedicated cloud environment counts.
  - **The defining property is that it is private**, i.e. pre-mainline. The author deliberately avoids "personal" because pair and mob programming exist.
  - **Manual is acceptable, temporarily.** If steps can't be automated yet, execute them by hand — "manual is better than nothing." Aim to keep the manual phase close to simple, targeted **smoke testing**, as cheap and easy as possible, and automate anything you find yourself repeating.
  - **Scope rule of thumb**: accept API contract tests plus happy-path tests on functional areas that are globally important (e.g. login) or were touched by the change. A private build is **not** meant to be a perfect, complete validation.

- **Three process metrics for a DevOps transition** — deliberately about the *process of building software*, not the system's static or runtime properties:

  | Metric | Units | Type | Measures |
  |---|---|---|---|
  | **Time to Feedback** | Qualitative | Indirect | Cost and time to market |
  | **Evitable Integration Issues in the Deployed Application per Iteration** | Quantitative | Indirect | Internal quality-control process |
  | **Time Spent Restoring Trunk Stability per Iteration** | Quantitative | **Direct** | Stability of the codebase and the team's capacity to maintain it |

  - **Time to Feedback** — time and effort to get feedback on a new feature implementation. Qualitative because quantifying it depends on the situation: sometimes feedback is slow (slow automations), sometimes the problem is *finding the right person* to give formal feedback. Prioritize the feedback that **blocks the team's own activity** (integration, QA). Indirect: a long cycle warns of a problem without identifying it.
  - **Evitable Integration Issues** — count of issues in each iteration of the *deployed* software that **could easily have been caught by a private build** (automatic or manual). The classical metric is "bugs found in QA"; the difference is the **evitability threshold**. Low or decreasing ⇒ more mature process.
  - **Time Spent Restoring Trunk Stability** — debugging time spent on issues that were checked into the trunk and surface when running a private build *after* an update, plus time fixing breaks to existing features. Direct, because it measures time (and cost) spent on activity that **introduces no features**. Distinguishes itself from "total debugging time" or "number of bugs" by measuring specifically the effectiveness of local regression. High values indicate either lack of discipline in running private builds (often because the local environment isn't standardized or isn't understood) or lack of test automation — which, in these circumstances, is very much expected.

- **The cost argument for private builds** — the standard objection is the toll on developer productivity and check-in frequency. The answer: the effort of running private builds is **far less than the cost of continuous trunk stabilization, QA round-trips, and ticket management**, because the cost of fixing a defect rises exponentially with the delay between introduction and detection.

## Key Concepts
- **CI** (Fowler, 2006) — team members integrate frequently, usually at least daily, each integration verified by an automated build including tests, to detect integration errors as quickly as possible. Automation is *one practice* within CI, and the key point is **not breaking the shared build/code line**.
- **CD (continuous delivery)** — brings ops, QA, and stakeholders onto the rails of automation; CI alone usually involves only the development team. Automation only *supports* the processes.
- **DevOps** (Patrick Debois, 2009) — removing siloed isolation between developers and operations; an extension of the Agile idea of reducing time between a problem's introduction and its discovery. Three pillars: **Process** (SysAdmins/ops fully integrated into the dev team, code always deliverable), **Tools** (the team accountable for deliverable state chooses and shares the whole toolchain), **Culture** (consistent ways of working — ops under version control too, i.e. infrastructure as code; dev automations placed in the broader context of automated environments, deployments, and runtime introspection).
  - **Culture is the biggest change DevOps brought.** Both sides must cross discipline borders: developers learn the execution environment and fix problems in automations and system scripts; ops/SysAdmins learn how the code is written, the solution's architecture, and its critical spots, can write a unit test and debug code, and **own supportability** — asking dev to apply logging and introspection policies.
- **FrequencyReducesDifficulty** (Fowler, 2011) — activities that "hurt" should be done as often as possible, to get more feedback and practice and break work into smaller chunks; those activities are the candidates for automation.
- **Trunk stability** — the stable or reasonably working state of the codebase mainline; when unstable, a `git pull` breaks application functionality in the local environment. It is one of the things that **enable continuously deployable software**.
- **Evitable (avoidable) issue** — one a private build could easily have caught.

## Reference Tables

**Why fully automated private builds stay hard, even with containers and standardized build tools** (each platform has its own issues):

| Obstacle | Detail |
|---|---|
| Test dataset | Must be chosen carefully, often in continuous communication with QA |
| Data control | The mechanism is not yet effectively standardized |
| DB migrations | Must run automatically inside the build, often differently from the production mechanism |
| Componentization | Microservices need complex communication channels like message brokers |
| E2E tests | Hard to write and run locally — and a clear source of ownership shift toward QA |

**Metrics-in-practice interpretation table** (the chapter's diagnostic core):

| Time to Feedback | Evitable Integration Issues | Time to Trunk Stability | Reading | Action |
|---|---|---|---|---|
| High | High | Low | **Most common combination.** Validations have been shifted to automations and QA; bugs are entering the trunk undetected locally | Analyze "evitability" in retrospectives; ensure *everyone* can run full tests locally; agree a shared set of minimal functional tests to run pre-check-in; demand private-build discipline; iterate |
| Low | High | Low | Time to Feedback is qualitative and may be biased — treat as the case above. Alternatively, a highly efficient QA team is absorbing the rest of the team's poor local validation | Ask for more discipline from the rest of the team |
| High | Low | Low | Ambiguous — two opposite situations. (a) Unsatisfactory general QA process, bugs found very late, inefficient/absent automation; (b) genuinely stable trunk and good process, but bureaucracy, the DevOps team's schedule, and an overwhelmed QA team delay feedback | (a) check other metrics — customer satisfaction, bugs introduced per iteration; (b) remove barriers between dev, DevOps, and QA — dev is already efficient |
| — | Low | High | Many bugs enter the trunk but never reach integration/QA. Likely an *imbalance*: some members spend heavy time fixing, others are undisciplined about private builds | Address via the team's internal retrospective process |

## Worked Example

### Case study: The Unstable Trunk (Company A)
A nominally "multidisciplinary" team whose Agile practice hadn't matured — really separate frontend, backend, DBA, DevOps, and QA sub-teams on variable-length iterations. A QA member reported the software was broken **every time** they got the latest version, and fixes took a long time to appear. Root-cause analysis produced a bug table, and the team chose to focus on the **"inevitable" bugs** — those that could not have been avoided:

| Bug | Component | Avoidable? | Easily automatable? | Caused by |
|---|---|---|---|---|
| A1 | Frontend | No | No | An unchecked, undefined value coming from the server |
| A2 | Backend | Yes (missing test) | Yes | Not fitting data type into the API |
| A3 | Integration with real data | No | Yes | Real data format as a corner case |
| A4 | Integration | No | No | A backward compatibility issue |

What actually happened, bug by bug:

- **A1** — the frontend developer had tested against a "stable" backend API locally, a reasonable way to avoid churn, and didn't know how to manage the backend API and test data. Running the *latest* backend before check-in would have caught it trivially. Fix: teach frontend, DBA, and DevOps members to run the whole backend environment locally, including pulling and integrating others' changes. The learners complained the local environment was complex — no reference data, no local database.
- **A2** — the backend team had **no automated API contract tests**. Their cycle was TDD-oriented (unit + integration tests, then confident check-in), and they argued there was no room in the project for contract tests. Instead they asked the frontend team to teach them the frontend local setup, and promised to run private builds using **shared manual test cases** to protect API stability until automation was affordable.
- **A3** — with frontend and backend now testing manually at every update, the complaints moved to **test data stability**: confusing, apparently erratic bugs that took hard debugging to trace to newly introduced buggy data. Fix: the DBA also set up a local environment and ran the manual suite as a **manual private build** at every data change, before and *after* pulling. On finding incompatibilities, DBA and backend developers talked directly; the backend wrote an integration test exposing the incompatibility, then fixed it. Trunk stayed stable.
- **A4** — with manual private builds everywhere, all members caught integration bugs. The QA member shifted to functional checking and version management; deployments got much more stable with far fewer fixes needed. Testing fixes was still slow because automations remained uncontrolled, so QA asked DevOps to improve deployment time — **and asked the team for a local development environment**, so they could validate functionally without a deployed version, understand problems more deeply, report more precisely, and finally start writing E2E automation.

Transformed table — the column header itself is the result:

| Bug | Component | **Avoidable by private build?** | Easily automatable? | Caused by |
|---|---|---|---|---|
| A1 | Frontend | Yes | In progress | Unchecked undefined value coming from server |
| A2 | Backend | Yes | Yes | Not fitting data type into the API |
| A3 | Integration with real data | Yes | Yes | Real data format as a corner case |
| A4 | Integration | Yes | No | Backward compatibility issue |

### Case study: The Blocked Consultant (Company B)
Consultants working inside a big company whose internal DevOps team was still building a complex delivery pipeline. Check-ins frequently produced non-working test deployments with **no way to debug integration problems**. Discovered causes: test data had changed; the DB migration mechanism was temporarily off; the backend container was continuously restarting; a depended-upon component was powered off for a cloud migration.

- **Iteration 1** — barely any functional increment delivered; all time went to discovering and managing these issues.
- **Iteration 2** — formally requested a dedicated test environment. Accepted, but it collided with the separate DevOps team's schedule: **two weeks**, blamed on internal bureaucracy. Unable to unblock themselves, the team shipped features on unit/integration testing alone. Stakeholders then complained about **missing edge cases** and critical bugs in integration with other services. The team *had written* component/contract API tests — but the DevOps team was too busy to wire them into the pipeline, so the tests sat **unrun and therefore unmaintained**.
- **Iteration 3** — accepting that Company B's reality wouldn't change quickly, they adopted a stopgap: **manually execute all API tests before and after every update on their local machine** — explicitly a decision *not to rely on uncontrolled automation*. They then extended the principle to their remaining validations by **building fake replicas of the external services they couldn't rely on**. Result: everything checked locally, independent of Company B's automations — faster delivery, more effective fixes, and time freed to automate validations instead of managing blockers.

Both teams accepted compromises (manual testing) they could have refused as "not their responsibility," and both had been evaluating the situation **implicitly, on these metrics**, before making them explicit.

## Anti-patterns
- **Ownership shift** — DevOps as a ticket-driven automation team; validations delegated to a dev team that has no control over the automation.
- **Treating the CI/CD pipeline as the core of the validation process** — the chapter's central conceptual mistake. Automation exists to make validation cheap and repeatable; it is **not meant to be external to the development process**.
- **Overreliance on automation without real understanding.**
- **Writing tests that never get executed** — they immediately become unmaintained.
- **Losing the sense of ownership over validations and automation.**
- **Assessing a system's architectural properties while the trunk is regularly broken** — likely to lead you to the wrong conclusions. Trunk-stability control comes first.
- **Trying to adopt a methodology without first understanding what's failing** — "many teams fail in adapting new methodologies because they try to change something they don't know isn't working."
- **Letting the manual private-build phase become permanent** — commit to automating repeated steps.

## Key Takeaways
1. If the pipeline is owned by someone else and unstable, stop making it your validation authority — move validation to where defects are introduced.
2. A private build's defining trait is that it runs *before* changes hit the shared mainline; the environment can be anything you fully control.
3. Manual private builds are legitimate as a temporary measure; keep them at smoke-test scope and automate what repeats.
4. Track Time to Feedback (qualitative, indirect), Evitable Integration Issues per iteration (quantitative, indirect), and Time Spent Restoring Trunk Stability per iteration (quantitative, **direct**).
5. Read the metrics as a triple — the combination, not any one value, identifies the weak spot.
6. "Evitability" is the classifier that makes the bug count actionable; audit it in retrospectives.
7. Trunk stability is a precondition for both continuously deployable software and any trustworthy architectural measurement.

## Connects To
- **Ch 1** (Harmel-Law): Time to Feedback is the local-environment counterpart of lead time for changes; trunk stability underpins deployment frequency.
- **Ch 3** (Farley): deployability and "the pipeline defines releasability" — this chapter is the field report on what happens when the pipeline *can't* define releasability.
- **Ch 6** (Rosa): the organizational-scaling view of the same silo problem.
- **Ch 8** (Ford): automation operationalizes metrics — the destination this chapter is surviving the journey toward.
- **Fowler, "Continuous Integration"** and **"FrequencyReducesDifficulty"**; **Duvall, Matyas & Glover, *Continuous Integration*** (source of "private build"); **Patrick Debois** (DevOps, 2009).
