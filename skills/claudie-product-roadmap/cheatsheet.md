# Cheatsheet — Product Roadmaps Relaunched

## Is This Even a Roadmap? (fast diagnostic)

| See this | You have | Fix |
|---|---|---|
| Feature+date columns, Gantt, burndowns | Release/project plan | Themes instead: `Ensure [result] for [stakeholder]` |
| Items tracing to no objective | Feature factory | Tag to an objective; reframe, defer, or cut |
| Named solutions in far-out columns | False precision | Problem in Next/Later; features only in Now |
| Schedule/resources/status embedded | Conflated artifact | Complementary tier; co-present with eng lead |
| Feature level with themes | Lost *why* | Nest as subtheme |

Features earn a slot for three reasons only: probable solution · infrastructure · carryover. Always carry a disclaimer.

## Which Prioritization Framework?

| Situation | Use | Limit |
|---|---|---|
| Scoping an MVP or big scope expansion | **Critical Path** | Ignores effort, risk, business goals |
| Choosing among add-ons | **Kano** | Delighters decay into normal needs |
| Small set of initiatives / rival solutions | **D/F/V** 1–3 each, out of 9 | Useless when all score 8–9 |
| Long list, many factors | **ROI Scorecard** `((ΣCN+ΣOG)/Effort)×Conf%` | Needs alignment on the columns |
| Communicating launch criteria | **MoSCoW** | Communicates priority, doesn't set it |
| Narrowing a list in a workshop | **$100 Test**, D/F/V split by function | To focus, never to decide |

Cut order: Could first, Should last, Must never; Won't agreed up front kills scope creep.
Compare like with like. Dependencies, resources, promises change **scheduling**, not priority.

## Thresholds & Defaults

| Decision | Number |
|---|---|
| Health Assessment | 14 questions, 0–2, **max 22** (overpromising + overdesigning subtract) |
| ≥18 / 12–17 | Approach A — tweak / same but expect a long road |
| ≤11 | Approach B — full relaunch, Ch3→Ch10 |
| Timeframe by stage | Discovery months (Now/Next/Later) · growth quarters · maturity years |
| Intel *public* roadmap | 2–3 years; fast startup a few months |
| Refresh rate | = the roadmap's time scale (quarterly roadmap → quarterly review) |
| Confidence | Now 70–95% (95/85/80/70) · Next ~50% · Later ~25% · never 100% |
| Objectives | Fewer than five (3–5 for metrics); weekly metrics review under 1 hour |
| Software team size | 3–7 people |
| Steering committee | Every 3–6 weeks (<3 no effects yet; >6 loses shared context) |
| Co-creation workshop | 90 min — intro 5 · hopes/fears 10 · vision 10 · back-plan 15 · sizing 40 · wrap 10 |
| Roadmap workshop | A few days; full relaunch months; Approach A first goal a few weeks |
| T-shirt sizing | XS=1 S=2 M=3 L=4 XL=5; scales 0/1/2, 1–3, 1–5, negatives legal |
| Test combinations | **2ⁿ − 1** (3 features = 7, 10 = 1,023) |

## What to Show Which Audience

One foundation (vision → strategy → themes → timeframes) + **one slide per audience**. Never divergent roadmaps.

| Audience | Add | Withhold |
|---|---|---|
| **Dev** | Features, stage, product areas; platform/project info after the primaries | Gantt *as* the roadmap; dictated deadlines |
| **Sales/Mktg** | Stage (beta/early access), target customers, **confidence %**, external drivers | Hard specificity — say *likely / probable* |
| **Execs/Board** | Vision, strategy, themes; market opportunity, P&L, break-even | Operational detail unless asked |
| **Customers** | Themes, rough timeframes, disclaimer, Considering/In development/Released | Internal infra, differentiating directions |

Detail shrinks with distance from the core team — except enterprise/component buyers betting millions, where detail is the price of the deal.

## When the Roadmap Must Change

| Change | Response | Communicate |
|---|---|---|
| Cycle refresh | Rerun from vision down; leave execution alone between cycles | Like a new roadmap |
| Feature late | Outcome-focused → absorb and shift resources. Threatens a commitment, window, or compliance → pick an iron-triangle lever | New date *and* its cost |
| Quality compromise | Only when demand is unprojectable → MVP + rebuild trigger; never the unchosen absorber | A deliberate learning investment |
| Special request | 3 questions: what problem? aligned to objectives? beats what's on now? Prefer **swapping out** | Show what moved out |
| External pressure | Adjust off-cycle; vision unchanged, route changes | Market shift, then route |
| Pivot | Revisit from vision down; redo buy-in | What changes, what doesn't, **why** |

Revisit depth: minor → Ch8 · new priorities → Ch7 · new functionality → Ch6 · needs/customers changed → Ch5 · vision/strategy changed → Ch3. Always **why → what → when**.

## Tells & Smells

- Ships on time, KPIs flat → output-focused / feature factory (Ch1,4)
- Shiny-object churn, "why are we doing that?" → no shared vision (Ch1,4)
- Sales writes roadmap items into contracts → no confidence %; intentions read as promises (Ch1,9)
- Execs digging into operational detail → they've lost trust in execution (Ch9)
- Stakeholder keeps pushing an off-strategy item → an unwritten goal exists; dig for it (Ch8)
- Each feature takes longer than the last → carrying cost + 2ⁿ−1 test growth (Ch7)
- Slip happened, nobody chose a lever → quality absorbed it, repaid as future delay (Ch10)
- Roadmap frozen while the market moves → treating it as a contract (Ch10)
- Decision nobody owns → chased consensus, not alignment (Ch8)
- Everything scores 8–9 → wrong framework; go to ROI Scorecard (Ch7)

## Anti-pattern Quick Reference

**Six bad ways to prioritize** — fine as *input*, never as decider: gut · analysts · popularity · sales requests · support requests · competitive me-too. Meta-mistake: letting others define your strategy.

**Sharing risks**: Osborne Effect (premature announcement kills current sales; worst for non-upgradable hard goods) · overpromising · leaking differentiating direction · multiple divergent roadmaps · over-specific roadmap handed to sales.

**Process**: change by fiat · fix everything at once · chase consensus on the diagnosis · force-fit a template · treat the relaunch as one-and-done.
