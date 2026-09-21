# Chapter 1: Relaunching Roadmaps

## Core Idea
A product roadmap describes **how you intend to achieve your product vision** — it focuses on the value you propose to deliver to your customer and your organization in order to rally support and coordinate effort among stakeholders. It is a strategic communications tool and statement of intent, not a project plan.

## Frameworks Introduced

- **Requirements for a Roadmap Relaunch (5 Shoulds + 3 Should Nots)**: eight requirements, each framed as Problem → Solution. Use as a diagnostic checklist against any existing roadmap.
  - When to use: before rebuilding a roadmap, or when auditing why the current one is ignored/distrusted.
  - How: for each of the eight, look for the listed symptoms in your org; where symptoms appear, apply that requirement's solution.
  - Why it works: each requirement is derived from an observed failure symptom, so the checklist converts vague dissatisfaction ("our roadmap is useless") into a named problem with a named fix.

  **A product roadmap SHOULD:**

  1. **Put the organization's plans in a strategic context**
     - Problem: *Nobody understands why things are on the roadmap.* Traditional roadmaps are so deliverable-focused they omit why the org is focused on these things at all. Symptoms: product doesn't get funding/shelf space/marketing support; lots of questions about features and dates; lots of ideas proposed that don't fit the (unarticulated) vision. Voices: "We suffer from 'shiny object' syndrome." / "No one knows what our end goal should be."
     - Solution: **Tie the roadmap to a compelling vision of the future.** Link the product vision to your organization's reason for being. Then conversations shift from "Why are we doing that?" to "Would decision A or B help us achieve our vision sooner?" The roadmap slots between company vision and detailed development/release/operational plans. (→ Ch 4)

  2. **Focus on delivering value to customers and the organization**
     - Problem: *You are shipping a lot but not making progress.* The traditional roadmap is really a project plan focused on resource efficiency, throughput, and hitting dates, leaving out what is expected as a *result*. Symptoms: releases ship on time but move no business KPIs; implementing customer requests doesn't raise satisfaction; features meet spec but don't solve the customer's problem. Voices: "I have no insight into how my team's work affects the bottom line." / "I never really talk directly to our customers."
     - Solution: **Focus the roadmap on delivering value.** Below the vision, state the *chunks of value* — high-level customer needs, problems, or jobs to be done, which the authors call **themes** — not a laundry list of features with dates. Themes act as "guardrails and goalposts" (David Cancel) giving teams autonomy inside them, and give you a definition of done independent of due dates. (→ Ch 5)

  3. **Embrace learning**
     - Problem: *Executives and customers demand commitments.* The traditional roadmap tries so hard to predict an unpredictable future that it invites blood-oath conversations. Committing too early to a single solution constrains options and stifles team creativity. Symptoms: salespeople write commitments into contracts; customers extract promises before signing; executives believe date commitments are the only way to get results.
     - Solution: **Commit to outcomes rather than output.** When asked "will feature X be in it?", turn the question around — ask *why*. Understand the problem behind the ask, then offer: "If I commit to solving this problem for you the best way I can, do we have a deal?" Or invite the customer into the process (design review) instead of predicting the future. Frame roadmap items as **intentions, not commitments**. (→ Ch 9)

  4. **Rally the organization around a single set of priorities**
     - Problem: *Marketing and sales are not selling what you are making.* Strategy is hollow when marketing tells one story, sales sells another, and engineering builds a third. Symptoms: marketing can't explain the product; sales keeps selling last year's product; many roadmap ideas arrive, none make the cut. Voices: "What are our other product teams doing?" / "We see the same roadmap items again and again."
     - Solution: **Align everyone around common goals and priorities.** Involve affected stakeholders in the decisions *before* the roadmap is concrete. Give each product manager a cross-functional **stakeholder advisory group** to collect priorities from sales, clinical, security, etc.; the product team synthesizes and says "This is it." (→ Ch 7 prioritization, Ch 8 buy-in)

  5. **Get customers excited about the product direction**
     - Problem: *Customers aren't excited about your new features.* Hitting dates and feature targets guarantees neither market acceptance nor business success. Symptoms: customers don't use the features you worked hard on; sales plateau or decline despite updates; a customer confronts you with last year's roadmap accusing you of broken promises.
     - Solution: **Use the roadmap to reality-check your direction with customers.** Treat the roadmap as a two-way communication device and a **prototype of your strategy** — it starts a dialog about business pain and priorities, confirms mutual understanding of needs, and surfaces where you're wrong while you can still change course. Protect against broken-promise accusations by telling customers up front that change is inevitable and that their input is what changes it. (→ Ch 8)

  **A product roadmap SHOULD NOT:**

  6. **Make promises a team cannot deliver on**
     - Problem: *Stakeholders and customers expect a firm commitment on release dates.* Gantt-style roadmaps with specific dates and feature commitments get missed in an agile (arguably post-agile) world. Symptoms: feature-and-date lists that are routinely unrealizable; team scrambling in the final weeks/days before release. Voices: "We always seem to overpromise and underdeliver." / "It feels like we're constantly playing catch-up."
     - Solution: **Prioritization is critical to deliver on your commitments.** A track record of missed commitments signals a prioritization *and* estimation problem. Precise prioritization focuses the team on the most effective use of its time.

  7. **Require wasteful up-front design and estimation**
     - Problem: *Time spent estimating design and development effort takes time away from actually implementing.* Symptoms: roadmap lists features needing "sizing"/"estimating"; team scrambling near release. Voices: "My engineers hate giving estimates." / "We waste too much time arguing over how to solve something."
     - Solution: **Let the teams determine the solutions, and allow them to solve the problem.** The roadmap is a strategy document; a project plan or release plan is the right place for specific dates and specs.

  8. **Be conflated with a release plan or a project plan**
     - Problem: *Your team reads the roadmap as a project plan listing when features ship.* A roadmap is a **strategic artifact**; a release plan is a **tactical artifact about execution**. Symptoms: release plan looks like a Gantt chart with delivery dates; roadmap is a list of features and dates. Voices: "I try to keep my roadmap at a high level, but Sales always demands dates." / "How does my roadmap fit into our Agile methodology?"
     - Solution: **Commit to outcomes rather than output** (deliberately the same solution as #3). Inexperienced product people jump to the solution (output) because we're acculturated to have "the answer"; experienced ones focus on the problem and drive toward the outcomes they're seeking.

## Key Concepts
- **Product roadmap**: A description of how you intend to achieve your product vision, focused on the value you propose to deliver to customer and organization.
- **Product**: How you deliver value to your organization's customers — an artifact, a service (pizza delivery, a Netflix subscription), or an experience (a Broadway play).
- **Stakeholder**: All internal and external colleagues and partners involved with the product being developed, marketed, sold, and serviced — sales, marketing, UX, engineering, research, finance, HR; suppliers, tech partners, vendors, resellers, brokers.
- **Customer**: The recipient of the value your product provides — encompassing both the **buyer** and the **user**, which are often different people (especially in B2B).
- **Theme**: A high-level customer need, problem, or job to be done that organizes the roadmap (e.g., "indestructibility" for a garden hose).
- **Outcome vs. output**: Outcome = the measurable change you intend to cause; output = the feature you ship. Commit to the former.
- **Guardrails and goalposts**: The bounded autonomy themes give a team — freedom to decide the solution inside a defined problem space.
- **Intentions, not commitments**: How far-out roadmap items must be read; customers must be "responsible consumers of the roadmap."
- **Roadmap as a prototype of your strategy**: An artifact you test with customers before building, so you can be wrong cheaply.
- **Strategy gap**: The void left when teams abandon roadmaps — agile and lean methods do not fill it; teams focus so hard on the next few weeks they lose sight of why.

## Mental Models
- **Use the roadmap as the middle layer**: company vision → *product roadmap* → development/release/operational plans. Anything on the roadmap that doesn't visibly serve the vision is a shiny object.
- **Think of the roadmap as a two-way communication device, not a broadcast**: showing it to a customer is how you discover you're wrong while changing direction is still cheap.
- **When someone demands a feature or a date, ask "why?" before answering**: stakeholders make hard demands because they don't know how else to influence product direction. Trade a solution commitment for a problem commitment.
- **Think of "done" as an outcome, not a date**: you're done when you have an indestructible hose you can manufacture and sell at a profit — not when the quarter ends.

## Reference Tables

| # | Requirement | Problem | Solution | Deep dive |
|---|---|---|---|---|
| 1 | Should put plans in a strategic context | Nobody understands why things are on the roadmap | Tie the roadmap to a compelling vision of the future | Ch 4 |
| 2 | Should focus on delivering value | You are shipping a lot but not making progress | Focus the roadmap on delivering value (themes) | Ch 5 |
| 3 | Should embrace learning | Executives and customers demand commitments | Commit to outcomes rather than output | Ch 9 |
| 4 | Should rally the org around a single set of priorities | Marketing and sales aren't selling what you're making | Align everyone around common goals and priorities | Ch 7, 8 |
| 5 | Should get customers excited about the direction | Customers aren't excited about your new features | Reality-check your direction with customers | Ch 8 |
| 6 | Should NOT make promises the team can't deliver on | Stakeholders expect firm date commitments | Prioritization is critical to deliver on commitments | Ch 7 |
| 7 | Should NOT require wasteful up-front design/estimation | Estimating steals time from implementing | Let teams determine solutions and solve the problem | Ch 6 |
| 8 | Should NOT be conflated with a release/project plan | Team reads the roadmap as a project plan | Commit to outcomes rather than output | Ch 2, 9 |

| Artifact | Nature | Contains |
|---|---|---|
| Product roadmap | Strategic | Vision, objectives, themes, broad timeframes, disclaimer |
| Release plan | Tactical, about execution | Specific features per release, dates |
| Project plan | Tactical, about execution | Gantt, schedule, resources, dependencies |

## Anti-patterns
- **Roadmap as feature-plus-date chart**: A graphical list of "feature X on date Y" omits why, so nobody can make aligned decisions and every slip reads as a broken promise.
- **Restricting or abandoning the roadmap entirely**: Teams hide the roadmap to escape the promise trap, but this creates a strategy gap agile/lean don't fill — teams lose sight of why they're working.
- **Committing to a solution before understanding the problem**: Locks in one design, constrains options, stifles team creativity, and usually still misses the customer's real need.
- **Letting sales turn the roadmap into a contract**: A salesperson getting "a little bit aggressive" with a roadmap converts intentions into commitments, which blows up when the business must change direction.
- **Measuring success only by "did we ship on time"**: Being on schedule makes no difference if customer behavior and business results don't change.
- **False precision on dates**: Committing to a date you lack confidence in means someone else banks on it. Keep dates as vague as flexibility requires.

## Worked Example
**Problem → Solution: the demanded feature (Requirement 3, "Embrace Learning")**

A prospect says they won't sign without a commitment to a specific feature this year.

1. Do *not* answer the feature question. Ask "Why? Why is that feature important to you? What is it about that date?"
2. Surface the real problem driving the request (and learn something about the market).
3. Reframe the commitment upward: "If I commit to solving this problem for you the best way I can, then do we have a deal?"
4. Alternatively, trade a promise for participation (David Cancel): "Rather than try to predict the future, why don't I invite you into our process? When we get close to a possible solution for the thing that concerns you, we'll bring you into a design review and let you tell us whether it meets your needs."
5. Accept that some asks are genuinely hard (regulatory standards, production schedules) — call those out honestly.
6. Accept the occasional lost deal (UserVoice): "We sometimes lose deals based on customer asks we cannot guarantee... I need to do what's best for most of them, not just a few."

Result: the commitment moves from *output* (a feature by a date) to *outcome* (a solved problem), preserving the team's solution space and the roadmap's credibility.

## Key Takeaways
1. Define the roadmap as **how you intend to achieve your product vision** — value-focused, not deliverable-focused. Simplicity here is critical to success (simple ≠ easy).
2. Run the eight-requirement checklist against your current roadmap; each symptom list tells you which requirement you're violating.
3. Lead with vision and business context so the question changes from "Why are we doing that?" to "Would A or B get us to the vision sooner?"
4. Organize the roadmap around **themes** (customer needs/problems/jobs to be done), not features and dates — themes give teams guardrails plus autonomy, and a date-independent definition of done.
5. **Commit to outcomes rather than output.** When pressed for a feature or date, ask "why" and commit to solving the problem instead.
6. Build alignment by involving stakeholders early, while the roadmap is still soft — a cross-functional stakeholder advisory group per product manager is a working mechanism.
7. Share the roadmap with customers, framed explicitly as subject to change; treat it as a two-way device that lets you discover you're wrong before you build.
8. Never let the roadmap become a release plan or project plan — strategic artifact vs. tactical artifact about execution.

## Connects To
- **Ch 2**: Turns these requirements into concrete roadmap components (Primary / Secondary / Complementary), including the disclaimer that operationalizes "these are intentions, not commitments."
- **Ch 4**: Product vision and business objectives — the fix for Requirement 1.
- **Ch 5**: Themes and subthemes — the fix for Requirement 2.
- **Ch 6**: Features/solutions detail and letting teams solve — Requirement 7.
- **Ch 7**: Prioritization techniques — Requirements 4 and 6.
- **Ch 8**: Stakeholder and customer buy-in — Requirements 4 and 5.
- **Ch 9**: Update cadence, communicating change, choosing which details to share — Requirements 3 and 8.
- **Jobs to Be Done (Christensen)**: The lens behind expressing themes as customer needs/problems.
- **Lean Startup / Customer Development (Steve Blank)**: "Start with the mission, strategic intent, and only then devise the plan"; the roadmap as confirmation of mutual understanding after discovery.
- **Outcomes over Outputs (OKR thinking)**: Business objectives as measurable outcomes rather than shipped features.
