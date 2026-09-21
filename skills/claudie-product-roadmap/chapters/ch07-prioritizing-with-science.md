# Chapter 7: Prioritizing—with Science!

## Core Idea
You will never get everything done, so ruthlessly rank work by expected contribution to customer needs and organizational goals versus effort — and make that ranking explicit enough that stakeholders can argue with the model instead of with you. Prioritization frameworks add just enough rigor to replace gut feel, politics, and "100 number-one priorities" with a transparent, defensible ordering.

## Frameworks Introduced

- **Critical Path**: From a user journey map, isolate the moments of highest negative emotion, then answer "What is the one thing (or set of things) our solution needs to get right?" Narrow the pain points down to must-haves and link them into a critical path journey — that is your MVP blueprint.
  - When to use: Designing an MVP, or making a major expansion in product scope. Also re-run it on an existing/growth product, because once you solve the original pain, a *new* critical path emerges (and a competitor will use it to get in the door if you ignore it).
  - How: (1) Journey-map each key role. (2) Capture emotion/state of mind at each step. (3) Identify hot-button aggravations that push users to find a better way. (4) Keep only the steps that must be fixed for the user to "hire" your solution. (5) Insert your solution at the moment of peak pain.
  - Why it works: It forces a binary must-fix test, so a mountain of research collapses into one blueprint (BarnManager: of dozens of barn pain points, only secure, easy digital record keeping had to be right — without it, nothing else mattered).
  - Failure mode: Ignores effort, risk, and business goals entirely, and ranks needs no finer than "critical" vs "noncritical."

- **Kano Model** (Dr. Noriaki Kano): Classify customer expectations into three categories — expected needs, normal needs, exciting needs — and prioritize by the customer's own *perception* of value.
  - When to use: You've already covered critical path needs and are deciding among add-ons and enhancements of increasing value.
  - How: Bucket each need as Expected (dissatisfier if missing), Normal (satisfier), or Exciting (delighter/wow). Satisfy expected needs first — missing them means no purchase. Exciting needs typically define category leaders.
  - Why it works: It separates "they'll refuse to buy without it" from "they'll love us for it," which pure request-counting cannot do.
  - Failure mode: Expectations rise over time — today's delighter becomes tomorrow's normal (intermittent wipers were exciting in the 70s; Mercedes had to invent rain-sensing wipers to re-differentiate). Also ignores effort, risk, and business goals, and perception is customer-specific (rain-sensing wipers delight nobody in an arid climate). Merely meeting expected needs usually still leaves you in the dissatisfied half of the curve.

- **Desirability, Feasibility, Viability**: Score each idea 1 (low) / 2 (medium) / 3 (high) on three named axes and sum for a composite priority score out of 9.
  - When to use: Prioritizing among a relatively small set of initiatives or competing solutions to one problem.
  - How: **Desirability** = value to your customer of solving the problem. **Feasibility** = how easy it is for your organization to build (easy scores high; more money/effort/time scores low). **Viability** = how valuable it is to your organization, often revenue or profit. Add the three; high scores on most or all axes rise above one-axis winners.
  - Note: Counterintuitively, exciting needs score *lower* desirability than expected needs, because expected needs are absolute minimums.
  - Failure mode: The three categories aren't clearly decomposed into specific customer needs, organizational goals, or distinct types of effort and risk. Breaks down when dozens of items all score 8 or 9.

- **ROI Scorecard** (Bruce's favorite): A prioritization spreadsheet built on `Value / Effort = Priority`, where `Value = Customer's Needs + Organization's Goals`, discounted by a confidence factor.
  - When to use: Long lists (dozens to hundreds of items), multiple competing factors, and answers that aren't obvious at a glance — especially when too many ideas score identically under simpler models.
  - How: Pick a few customer needs and a few organizational goals as columns. Score each idea's contribution to each (0/1/2, 1–3, or 1–5 — negatives allowed). Sum for value. Estimate effort with T-shirt sizing. Divide, multiply by confidence %, sort descending.
  - Why it works: It forces the team to clarify, articulate, and align on strategy just to pick the columns. It reduces opinion and emotion by making everyone frame arguments as relative contribution to shared goals, and it makes multi-criteria success visible.
  - Failure mode: Critics (Roger Cauvin) argue it "addresses organizational dysfunction with formulas that ignore human factors" and can distract from a singular focus on the value proposition. It also excludes intangibles like buzz and innovation, and excludes dependencies, resources, and promises.

- **MoSCoW**: Must have / Should have / Could have / Won't have — a categorization of an already-prioritized list into unambiguous release criteria.
  - When to use: You're uncertain what must be included in a product, service, or release, and need to communicate launch criteria to the development team.
  - How: See the bucket table below. Map dissatisfiers → Must, satisfiers → Should, delighters → Could, out-of-scope → Won't.
  - Note: MoSCoW is **not** a prioritization method — it only communicates priorities you set with another framework.

## Key Concepts
- **Opportunity Cost**: Never getting the chance to do something important because you chose to work on something else instead — "there's no such thing as a free demo."
- **The Law (core tenet, from Lean Startup)**: *Always assume you may have to stop work at any time.* Your funding can be diverted to someone else's bright idea at any moment, even at a Fortune 500.
- **Shiny Object Syndrome**: Pursuing many parallel "number-one priorities" or shifting them hour to hour; what a CEO calls agility, the dev team calls distraction. The antidote is focus.
- **Carrying Cost**: Every feature you ship must be retested per release and environment, documented, trained on, supported, priced, demoed/sold, and positioned/marketed — forever. Two efforts in parallel each take more than twice as long due to communication, coordination, and mental switching costs.
- **Exponential Test Matrix Growth**: Regression test combinations grow as **2ⁿ − 1** with n features — 3 features = 7 tests, 5 = 31, 10 = 1,023, 11 = 2,047. Automation and sampling reduce the work, not the principle.
- **Features Versus Tests**: The book's name for that exponential curve — the reason each new feature takes longer to ship than the last.
- **Kano — Expected needs (dissatisfiers)**: Needs whose absence means your chosen customer will not buy; roughly equivalent to the critical path.
- **Kano — Normal needs (satisfiers)**: Things customers don't strictly need but that satisfy them; customers begin articulating these once expected needs are met.
- **Kano — Exciting needs (delighters / wows)**: Needs met beyond customer expectations; these typically define category leaders.
- **Deliberate Imprecision**: Use coarse scales on purpose — a team will argue endlessly over $500K vs $600K but agree instantly on high/medium/low. Bruce's simplest scale: 0 (low enough it doesn't matter), 1 (some positive effect), 2 (large positive effect).
- **T-shirt Sizing**: Effort estimation as XS=1, S=2, M=3, L=4, XL=5 — relative sizing borrowed from agile story points. What matters is that a small is smaller than a medium, not what a small is in weeks.
- **WAG (wild-ass guess)**: A finger-in-the-air estimate that management converts into a date commitment — why engineers resist estimating.
- **Risk / Confidence Factor**: Multiply Value/Effort by a confidence percentage (the inverse of risk); be less confident about risky things. Risk applies to the value side as much as the effort side.
- **Scope Creep**: Rehashing scope mid-project; agreeing Won't-haves up front is the defense.

## Mental Models

**Tools Versus Decisions.** A framework informs a decision; it never *is* the decision. No one should be a slave to a formula. The real payoff of a scorecard is often the conversation it forces — teams must agree on strategy and value proposition just to choose the columns.

**Estimate first, then ask for a reality check.** Engineers fear premature commitment, so do the estimate yourself and ask an implementer to correct it. It is far easier to get an engineer to tell you why you're wrong than to get them to volunteer a number.

**Think cross-functionally about effort.** Effort is the *whole company's* cost: engineering build/test/release plus marketing research into a new segment, sales retraining, partnerships, channel recruitment. A shiny feature you can't market, sell, or service is worthless.

**Compare only like things.** Rank themes against themes and features against features; a theme versus a feature meant to live inside it is not a meaningful comparison.

**Dependencies, Resources, and Promises (Oh, My!).** These override pure scoring at the *scheduling* layer, not the priority layer. You may have to start on your #2 because #1's critical resources aren't available yet or #1 depends on #2; you may have to ship #47 because it was promised to the board or written into a customer contract. Note these in the scorecard margin and consult them when sequencing the roadmap.

## Reference Tables

### Prioritization Frameworks Overview (Table 7-4)

| Framework | Use To | Choose When | Inputs Needed | Output | Weakness / Downsides |
|---|---|---|---|---|---|
| **Critical Path** | Identify the "one thing" that will drive a customer to buy | Designing an MVP or making a major expansion in product scope | User journey maps with emotional states; direct research | An ordered must-fix path = MVP blueprint | Ignores effort, risk, and business goals; ranks needs no finer than critical/noncritical |
| **Kano Model** | Understand how customers perceive relative value | Identifying possible add-ons or enhancements | Deep customer understanding; needs classified by perception | Needs bucketed as expected / normal / exciting | Ignores effort, risk, and business goals; expectations inflate over time; perception varies by customer |
| **Desirability, Feasibility, Viability** | Identify opportunities that meet all key criteria for success | Prioritizing among a relatively small set of initiatives or solutions to a particular problem | 1–3 scores on three axes per idea | Composite priority score out of 9 | Categories not clearly defined in terms of customer needs, organization goals, or types of effort or risk |
| **ROI Scorecard** | Rank ideas according to return-on-investment criteria | Weighing multiple factors and/or a long list of possible initiatives, problems, features, or solutions | Agreed customer needs + org goals as columns; per-goal scores; effort estimate; confidence % | Ranked list with numeric priority scores | More complex model requires alignment on the different components of value and effort |
| **MoSCoW** | Communicate launch criteria | Feeling uncertain about what must be included in a product, service, or release | An already-prioritized list | Four release-criteria buckets | Does not help set priorities, only communicate them |

### Kano Categories (Table 7-1)

| Kano Need | Also Called | Definition | Automobile Example |
|---|---|---|---|
| **Expected** | Dissatisfier if missing | Absent → the chosen customer will not buy; ≈ the critical path | Windshield wipers |
| **Normal** | Satisfier | Not strictly needed, but satisfies; customers articulate these once expected needs are met | Intermittent wipers |
| **Exciting** | Delighter / wow | Goes beyond customer expectations; typically defines category leaders | Rain-sensing wipers |

### ROI Scorecard / A Formula for Prioritization

**Base equation**

```
Value / Effort = Priority
Value = Customer's Needs + Organization's Goals
Value = CN1 + CN2 + OG1 + OG2 + ...
```

**Full formula (with risk discount)**

```
Priority = ((CN1 + CN2 + ... + OG1 + OG2 + ...) / Effort) × Confidence%
```

Effort is the reverse of feasibility — **higher effort scores are bad**.

**Simple scorecard (Figure 7-6 structure)** — columns: Idea | Goal 1 | Goal 2 | Value (sum) | Effort | Confidence % | Priority.

**More complex scorecard (Figure 7-7, "Plush Life")** — a stuffed-animal e-commerce site ranking site enhancements, expansion into China, and new toy concepts against three company goals: **increase sales, increase margins, increase customer lifetime value (LTV)**, plus effort. It rearranges desirability/feasibility/viability into an ROI ratio of *(desirability + viability) / feasibility*, lets you split each value into multiple sub-components (e.g., several aspects of desirability), and adds confidence to account for risk.

**Scoring scales** — use 0/1/2, 1–3, or 1–5; negatives are legal when goals conflict. Keep the math simple enough that a stakeholder can do it in their head; a dozen goals and complex weighting schemes add difficulty without adding decision value.

### Scoring Pros and Cons (Table 7-3)

| Cons | Pros |
|---|---|
| Scoring lots of little features or requests could provide a false sense of confidence or progress | Scoring items being considered anyway forces discussion of the underlying problems and the value of solving them |
| Simple scale misses finer differences | Simplicity keeps teams from arguing over unimportant details |
| Keeping to a few goals misses important factors | Forcing teams to narrow to a few goals makes them face that they can't do it all |
| Excludes intangibles such as "buzz" or "innovation" | Objective criteria support a more rational, open discussion of trade-offs |
| Excludes dependencies, resource availability, or promises to key customers, the board, Wall Street | Scoring models uncover where resources and promises do not align with priorities |

### MoSCoW Buckets

| Bucket | Definition | Maps To | Cut Order |
|---|---|---|---|
| **Must have** | Requirements that must be met to launch; "minimum-to-ship" — you literally can't launch without them | Critical path items / dissatisfiers / expected needs | Never |
| **Should have** | Not critical to launch, but important and painful to omit | Satisfiers | Last to be cut under budget/deadline pressure |
| **Could have** | Wanted, but less important; "include if easy" | Delighters may land here | First to be cut if they introduce budget or deadline risk |
| **Won't have** | Explicitly out of scope for this release; may return in a future one | Satisfiers and delighters — never dissatisfiers or critical path items | Agreed out up front to prevent scope creep |

Distinguish Could from Should by the degree of pain omission causes the customer, or the reduction in value of the solution.

## Anti-patterns — Bad (but Common) Ways to Prioritize

| Bad Method | Why It Fails | Do Instead |
|---|---|---|
| **Your, or someone else's, gut** | Lack of rigorous analysis means the executive flips confidently from "X is the future" to "Y is the future" days later; and executives once close to customers are no longer in touch with the market. Produces high turnover, low productivity, subpar results | Take executive gut as *input*: find the problem they're solving, test alignment with product strategy, ask if the proposed solution is the best available, then politely explain what outranks it |
| **Analyst opinions** | You know your business and customers better than they do. Analysts extend existing trends in straight lines — they predicted flat-panel monitors would stay expensive for years, missing high-volume Chinese producers; $1,000 monitors now cost under $200 | Do your own research and analysis and stay ahead of yesterday's trends |
| **Popularity** (ranking requests by frequency or customer size) | Outsources strategy to customers, who often can't articulate what they need. Yields a product with no focus, unclear market positioning, and poor usability. Jobs: "people don't know what they want until you show it to them" | Understand the *underlying problems* behind the request list; a more elegant solution set usually renders the list moot |
| **Sales requests** | Prioritizing what closes this quarter's pipeline is short-term thinking — it makes the number once or twice. Cagan: your job is a product that is valuable, usable, and feasible, not documenting requests. Meyers: "You can lock yourself into creating something that really only one company needs" | Use sales input for buyer insight, but serve a *market* rather than individual customers; maintain two-way dialogue or you're just a custom dev shop |
| **Support requests** | Great data for usability — but only prioritize here *if* usability is a key goal. If customers find the product easy but it's missing critical functionality that blocks purchase, current-customer feedback won't expand your appeal to prospects | Weigh support-derived usability work in the context of *all* your goals |
| **Competitive me-too features** | A tit-for-tat feature war makes you easily comparable, collaboratively creating a commodity market where longest-list-lowest-price wins and margin evaporates | Differentiate with capabilities matched to your chosen customer's needs that competitors can't or won't match; charge on value, not a few dollars less |

Note the meta-anti-pattern: **letting others define your strategy** is the single most common product-planning mistake. Gathering input widely is right; decision-by-consensus is not.

## Worked Example

**Desirability / Feasibility / Viability — car features (Table 7-2)**

| Feature | Desirability | Feasibility | Viability | Priority Score |
|---|---|---|---|---|
| Hybrid drivetrain | 3 | 3 | 3 | **9** |
| Leather interior | 2 | 2 | 2 | 6 |
| Custom colors | 2 | 1 | 1 | 4 |

Reading the scores: custom colors have *medium* desirability (customers asked for them, 2), but manufacturing needs a separate paint process — hard to build (feasibility 1) and margin-eroding (viability 1) — for a disappointing 4 of 9. Hybrid drivetrain scores 3 across the board: years of prior investment make it viable, fuel-economy demand makes it desirable, and buyers pay a premium so profit is higher. A 9 is a home run.

**ROI Scorecard shape (Figure 7-6 logic)**

| Idea | Goal 1 | Goal 2 | Value | Effort (T-shirt) | Confidence | Priority |
|---|---|---|---|---|---|---|
| Feature A | 2 | 2 | 4 | M (3) | 90% | **1.20** — highest: hits both goals with high confidence |
| Feature B | 2 | 0 | 2 | S (2) | 100% | 1.00 — lower despite *higher* confidence, because it supports only one goal |
| Feature C | 2 | −1 | 1 | XS (1) | 60% | 0.60 — lowest effort of the three, sunk by low confidence and a negative goal score |

Negative goal scores are real and useful: goals conflict (quality vs quantity, power vs weight). Retail discounting raises unit sales while destroying margin — whether to discount depends on the balance of all goals, and a further goal like category sales may be the tiebreaker.

## Key Takeaways
1. Assume work can stop at any time — sequence so the most important things are delivered and demonstrating value first, because opportunity cost is permanent.
2. Match the framework to the situation: **Critical Path** for MVP scoping, **Kano** for add-on value perception, **Desirability/Feasibility/Viability** for a small candidate set, **ROI Scorecard** for long multi-factor lists, **MoSCoW** for communicating launch criteria. Then mix and match.
3. Always keep effort in the equation. Two equally valuable features where one takes days and the other months are not equally prioritized — ship the cheap one first and let it fund the expensive one.
4. Be deliberately imprecise. Coarse 0/1/2 or 1–5 scales and T-shirt sizes produce faster agreement and better conversations than false precision; add rigor only to the top candidates.
5. Define value as customer needs *plus* organizational goals, then discount by confidence. Revenue alone fails for pre-revenue products, unprofitable customers, market-share mandates, and new-market entries.
6. Estimate effort cross-functionally and take responsibility for the first estimate yourself, then ask an engineer to poke holes in it.
7. Treat the score as an aid, not a verdict. Layer dependencies, resource availability, and promises made to customers or the board on top — they change *scheduling*, not priority, and belong in the scorecard's margin.
8. Refuse the six bad inputs as *decision-makers* while still welcoming all six as *inputs*: gut, analysts, popularity, sales, support, and competitors all inform; none of them rank.

## Connects To
- **Ch 2**: The Wombat garden hose example supplies the customer-needs columns (reliable water delivery, reliable nutrient delivery) used in the value equation.
- **Ch 3**: User journey maps with emotional states are the direct input to Critical Path analysis.
- **Ch 4**: Vision and business-outcome objectives become the organizational-goal columns in the ROI scorecard; loose timeframes preserve the flexibility prioritization buys you.
- **Ch 5 & Ch 6**: Understanding and solving customer problems is prerequisite to applying Kano or any customer-value model — perception requires knowing the customer.
- **Ch 8**: The scorecard is the alignment artifact — use it in shuttle diplomacy and group workshops to get stakeholder buy-in on priorities.
- **Lean Startup (Eric Ries)**: "Always assume you may have to stop work at any time" derives from startups failing by running out of money before finding a viable model.
- **Marty Cagan / SVPG**: "Your job is not to prioritize and document feature requests. Your job is to deliver a product that is valuable, usable, and feasible."
- **Agile story points**: T-shirt sizing borrows relative sizing — comparative ordering matters, absolute duration does not.
