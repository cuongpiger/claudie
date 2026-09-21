# Chapter 10: Keeping It Fresh

## Core Idea
A roadmap is a living thing: it must evolve when its environment changes, but stay stable between planned revisions so teams can actually execute. Manage change on a deliberate cycle, and when unplanned change hits, choose which iron-triangle lever to pull and communicate the *why* before the *what* and *when*.

## Frameworks Introduced

- **Roadmap Timeframe by Product Stage of Life**: the faster the pace of change in your market, the more compressed your roadmap — in both total span and interval size.
  - When to use: deciding how far out to plan and how coarse your time buckets should be.
  - How: locate your product's stage, then pick the span. Discovery → **short (months)**, often `Now / Next / Later` buckets. Growth → **longer (quarters)**. Maturity/decline → **longest (years)**. Reference points: Intel's *public* roadmap spans **two to three years** (internal goes further); a startup shipping weekly may stretch only **a few months** out.
  - Why it works: if companies in your space are still figuring out what the future holds, detailed long-term plans are guaranteed waste. Failure mode: a startup borrowing an enterprise 3-year format and treating it as a commitment.

- **Refresh-Rate Rule of Thumb**: *the refresh rate of your roadmap should match the time scale of your roadmap.*
  - When to use: setting your revision cadence.
  - How: if the roadmap is laid out in quarters, revisit and update it **every quarter**. Repeat the same creation steps — reexamine vision, strategy, goals, and themes — rather than patching items. Between updates, leave execution alone (the Scrum-sprint principle at a larger scale).
  - Why it works: punctuated equilibrium — long periods of relative stability interspersed with rapid change — is the least disruptive way to absorb change.

- **The Iron Triangle (four levers)**: schedule, scope, resources, quality. You can never have everything; pick which goals to protect and decide where compromise is least painful.
  - When to use: work is late, or someone wants to add scope.
  - How: (1) name the one variable that is genuinely fixed by your business (hard deadline, regulatory compliance, minimum viable scope); (2) explicitly choose which of the remaining three absorbs the change; (3) decide *before* the slip, not after. Adding scope always hits another variable — "not choosing is to let chance decide for you."
  - Failure mode: holding schedule, scope, and budget all constant means **quality** silently absorbs everything — fatigue defects, cut corners, technical debt, and *later* roadmap delays because the team is fixing the damage.

- **The Three Questions for Special Requests**: run every "can you just slip in…" through these, in order.
  - When to use: sales, a partner, or a stakeholder pet project asks for a one-off.
  - How: (1) **What problem is this request trying to solve?** Speak to the requestor, then trace back to the person with the underlying problem; interview them; ask *why* multiple times. This tells you whether they're in your target market and opens up less disruptive solutions. (2) **Does solving that need align with our objectives?** Distinguishes "provides value" from "advances the goals we aligned on." (3) **Is it more important than what's on the roadmap now?** Forces the trade-off conversation.
  - Why it works: most specific feature requests are one person's guess at a solution to an unstated problem.

- **Forks in the Road (roadmap optionality)**: encode branching strategy plus its decision criteria directly in the roadmap.
  - When to use: a strategic either/or (down-market vs. premium, new tech vs. cost reduction, channel vs. direct) where two paths are nearly equally attractive.
  - How: pick one opportunity to pursue now; draw both pathways; attach **thresholds** — specific performance numbers (key results, Ch4) the product must hit — as the decision criteria for which branch you take; publish the criteria alongside the roadmap visual, and present it at a stakeholder buy-in meeting.
  - Why it works: teams get foresight into the future product, which changes how near-term development is done. You can't switch from ferry to car mid-crossing — the commit point must be known in advance.

## Key Concepts
- **Punctuated equilibrium**: long periods of relative stability interspersed with rapid change — the target pattern for roadmap revision.
- **Planned change**: scheduled, cadence-driven roadmap revision; stakeholders expect it, because a roadmap is not a contract.
- **Unplanned change**: late features, quality compromises, special requests, external pressures, and strategy changes that arrive off-cycle.
- **Iron triangle**: schedule, scope, resources, quality — the four levers you trade against each other.
- **Technical debt**: the buildup of quality issues that slows development and hampers your ability to move the roadmap forward.
- **MVP**: "that version of a new product which allows a team to collect the maximum amount of validated learning about customers with the least effort" (Ries).
- **Pivot**: "a change in strategy without a change in vision" (Ries).
- **Carryover items**: work pushed from one roadmap version to the next because it landed late (Ch6).
- **Threshold**: a specific performance number built into the roadmap as a decision criterion for a fork.
- **Brooks's Law**: "adding manpower to a late software project makes it later"; small teams of **three to seven** people deliver software most effectively.

## Mental Models
- **Think of your roadmap as Darwin's finches**: it changes only in response to a stimulus from its environment. No stimulus, no change — stability is a feature, not staleness.
- **Use outcome-absorption when output slips**: if you're focused on a customer/business *outcome*, you can absorb changes in *output* and shift resources to maximize results — no roadmap change needed.
- **Treat quality as a deliberate investment sized to expected scale**: millions of users with few future changes → invest up front (skipping it is irresponsible). Unknowable demand on the cutting edge → ship the MVP, iterate, and rebuild "experiment #6" to full quality only once it succeeds.
- **Think of a special request as a symptom, not a spec**: the stated feature is the requestor's guess; your job is to find the disease.

## Reference Tables

### How far out, and how often

| Product stage of life | Roadmap timeframe | Typical buckets | Refresh cadence |
|---|---|---|---|
| Discovery | Short (months) | Now / Next / Later | Match the scale — frequent |
| Growth | Longer (quarters) | Quarters | Every quarter |
| Maturity / decline | Longest (years) | Half-years, years | Annually / as the market moves |

### Change types → right response → how to communicate

| Change type | Planned? | Right response | Communicate as |
|---|---|---|---|
| **Regular cycle refresh** | Planned | Rerun the full creation process: revisit vision, strategy, goals, themes. Leave execution untouched between updates. | Normal cadence update; socialize exactly like a new roadmap (Ch8). |
| **Features are late** | Unplanned | If you're outcome-focused, absorb it and shift resources. If the delay threatens commitments, a market window, or compliance, convene the team and pick an iron-triangle lever. Treat a delay as a possible symptom of another variable. | Small change: may only affect the release/project plan, not the roadmap. Be explicit about the new date and what it cost. |
| **Quality compromise** | Unplanned, chosen | Acceptable when demand is unprojectable and you expect to iterate — ship an MVP and learn. Unacceptable when scale is known and large. Never let quality be the *unchosen* absorber. | State it as a deliberate learning investment with a rebuild trigger, not as a corner cut. |
| **Special requests / pet projects** | Unplanned | Run the three questions. Preferred resolution: **swap out something already planned**, keeping scope constant and the other levers untouched — easiest when the roadmap is themes-only (Ch5). If you accept added scope, decide immediately which lever gives. | Frame as a trade-off, showing what moved out to make room. |
| **External pressures** (competitors, economy, regulation, fashion) | Unplanned | Respond and adjust the roadmap — don't wait for the cycle. Keep the vision; adjust the route "based on weather and traffic." | Explain the market shift first, then the route change; vision unchanged. |
| **Changes in strategy / pivot** | Unplanned | Don't wait for the scheduled review. Revisit everything from the product vision down. | Be explicit about **what is changing, what is not changing, and why**. Go back through buy-in and alignment. |

### Depth of revisit — "Lather, Rinse, Repeat"

| What changed | Go back to |
|---|---|
| Minor changes only | Ch8 (buy-in, transparency) |
| New priorities, vision unchanged | Ch7 (prioritization rationale) |
| Moving into whole new areas of functionality | Ch6 (features/solutions — real value) |
| Customer or organizational needs changed; new customer types | Ch5 (themes) |
| Company vision, strategy, or key business objectives changed | Ch3 (rethink from the ground up) |

## Anti-patterns
- **Treating the roadmap as a contract**: leads you to keep building what mattered nine months ago while sales lose deals to a new competitive threat. Stakeholders *expect* you to respond to the market.
- **Omitting the "why" from a change announcement**: people are embarrassed about change and skip the reason. The team then invents its own, less-charitable reason, and confidence in strategy and leadership erodes.
- **Adding people to a late project**: communication overhead makes it later, and worst of all when added late — the existing team burns premium time onboarding.
- **Holding schedule, scope, and budget fixed after a slip**: quality becomes the default victim, producing defects, returns, churn, and delays to *future* roadmap items.
- **Accepting added scope without naming the cost**: not choosing which lever gives is letting chance choose for you.
- **Pursuing every fork at once**: successful organizations focus on one opportunity at a time and leave the door open to pivot or expand.

## Worked Example
**Garden hose company, ~6 months into the roadmap.**

Before — Vision: "To perfect American lawns and landscapes by perfecting water delivery." Objectives: 1M units, <5% returns, <2% defects, double ASP. Timeframes: H1 2017, H2 2017, 2018, 2019. Seven themes over three years, three features on the first theme.

Two changes surfaced. (1) The 40-foot hose leaks. Judgment: the "no-leak connections" claim matters more than a longer model — so ship only the 20-foot version now and push the longer one into the "extended reach" theme next year (alongside a planned 80-foot model). (2) Test customers found Wombat hoses don't clog when delivering dissolved fertilizer; research showed widespread dissatisfaction with competitors and pent-up demand. "Fertilizer Delivery" was pulled from **2019 to H2 2017**, with a board agreement that hitting sales thresholds triggers a vision change to "To perfect the landscapes of affluent Americans by perfecting nutrient delivery."

The communication, in slide order: (1) reshow the *unchanged* vision slide from last quarter; (2) describe the fertilizer opportunity and the rationale — why it benefits customer *and* company; (3) show the roadmap **annotated** with colors/arrows marking exactly what moved; (4) show the clean updated roadmap, dated in the lower-left — this is the version that leaves the room; (5) make the accelerated item real with a mockup or photo; (6) preview the conditional new strategy (executives only, not shared unless it takes hold).

## Key Takeaways
1. Set your roadmap span by product stage — months in discovery, quarters in growth, years at maturity — and make the refresh rate match the time scale (quarterly roadmap → quarterly review).
2. Between updates, protect execution. Change on a cycle, not on impulse; punctuated equilibrium beats constant churn.
3. When work slips, explicitly choose which iron-triangle lever gives. If you don't choose, quality gives — and pays you back as technical debt and future delays.
4. Compromise quality only when demand is genuinely unprojectable; then rebuild to full quality once an experiment succeeds.
5. Answer every special request with the three questions, and prefer swapping something out over growing scope — themes-only roadmaps give you that flexibility.
6. Don't wait for the cycle to pivot. When strategy is wrong, revisit from the vision down and state what's changing, what isn't, and why.
7. Communicate **why** first, then what and when — anchored to vision, strategy, and goals. Celebrate changes driven by achieved goals; they're evidence of progress.

## Connects To
- **Ch2**: the disclaimer on forward-looking statements — remind customers the roadmap will evolve every time you discuss it.
- **Ch3**: full ground-up rethink when company vision, strategy, or objectives change.
- **Ch4**: key results and thresholds become the decision criteria in a fork in the road.
- **Ch5**: themes-only roadmaps make swapping features in and out painless.
- **Ch6**: carryover items from late delivery; whether solutions deliver real value.
- **Ch7**: objective prioritization for judging a special request against what's on the roadmap.
- **Ch8**: socialize a changed roadmap exactly as you socialized the original.
- **Ch9**: presentation mechanics for the quarterly review deck.
- **Agile Scrum**: leaving the team alone to execute within an increment, then re-prioritizing on output — the same principle, one scale up.
- **Lean Startup (Ries)**: MVP and pivot; "startups that succeed are those that manage to iterate enough times before running out of resources."
