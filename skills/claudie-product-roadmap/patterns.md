# Patterns — Product Roadmaps Relaunched

## Discovery & Input Gathering

### Product Life-Cycle Assessment
**When to use**: First move of any roadmapping effort.
**How**: Place the product in one phase, gather its input. New Product → assumptions, then prototype and test. Growth → prioritize for scale, remove features that no longer serve. Expansion → prove the format transfers to an adjacent need. Harvesting → a revolving customer-feedback loop. End-of-Life → sunset plan plus stakeholder comms.
**Trade-offs**: A Growth "rank the backlog" process on a New Product has nothing validated to rank.
*(Ch 3)*

### Business Model Analysis (Lean Canvas / Business Model Canvas)
**When to use**: As a gate — can't fill one in, you aren't ready to roadmap.
**How**: Fill the pillars: problem/solution, value proposition, unfair advantage, key metrics, customer segments, channels, costs, revenue model, key partners, key resources. Lean Canvas (Maurya) for new products, Business Model Canvas (Osterwalder) for established. Every team member fills it, not just the PM.
**Trade-offs**: Up-front time; skipping it means navigating with half the map.
*(Ch 3)*

### Customer Development Model
**When to use**: Validating a problem before spending capacity on a solution.
**How**: Discovery — get out of the building, confirm the core problem (what they name is usually a symptom). Validation — prove some will pay. Creation — show early success becomes sustained demand. Company Building — formalize departments once product and sales justify it.
**Trade-offs**: Slow; hard to sell in orgs that reward shipping.
*(Ch 3)*

### Voice-of-Customer Merged Top-10
**When to use**: Several internal teams each claim to represent the customer.
**How**: Each customer-facing team writes its own top-10 → merge and rank collaboratively (the merging is what makes teams feel ranked-in) → uplevel feature suggestions into themes → add tactical and strategic factors.
**Trade-offs**: Still request-shaped — don't let it become prioritization-by-popularity.
*(Ch 3)*

### Stakeholder Interviews (benefit / contribute)
**When to use**: Building the shuttle-diplomacy list.
**How**: Ring stakeholders around the product core by influence and interaction frequency. For each write both columns — what they get from the roadmap, what they contribute (sales → what makes prospects buy; support → top call reasons; finance → budget and ROI targets).
**Trade-offs**: Rings go stale as the org changes.
*(Ch 3)*

### Roles vs Personas
**When to use**: Deciding who the roadmap serves.
**How**: Roles = jobs/functions (student, instructor), use to categorize. User type = permissions. Separate buyer from user (B2B usually differ). Personas add feelings and preferences, use to empathize — persona-level differences become distinct roadmap items.
**Trade-offs**: Conflating the two loses either the categorization or the depth.
*(Ch 3)*

## Vision & Strategy

### Value Proposition Template
**When to use**: Creating a product vision, or gut-checking one.
**How**: `For: [target customer] / Who: [needs] / The: [product] / Is a: [category] / That: [benefit] / Unlike: [competitors] / Our product: [differentiation]`, then `Supports our: [objective(s)]`. Compress to *A world where the [customer] no longer suffers from the [problem] because of [product] they [benefit]*, then to *To [benefit] by [differentiator]*.
**Trade-offs**: Plug-and-play phrasing — scaffolding only, then rewrite in your own voice.
*(Ch 4)*

### Mission Four-Elements Test
**When to use**: Writing or auditing a mission statement.
**How**: Check Value (what value to the world?), Inspiration (does it move the team toward the vision?), Plausibility (achievable — implausible disheartens), Specificity (specific to your business/industry?). Verify it names what you do for customers, not shareholders.
**Trade-offs**: Won't catch a mission posing as a vision — check destination-vs-direction separately.
*(Ch 4)*

### OKRs for Roadmapping
**When to use**: Turning vision into something implementable.
**How**: Objectives qualitative, key results quantitative, several KRs per objective. Three rules: every roadmap item ties to at least one objective; keep objectives under five; measure outcomes not output. Keep the weekly metrics review under an hour.
**Trade-offs**: Too many objectives kills focus; revenue-only tracking flags trouble too late.
*(Ch 4)*

### The 10 Universal Business Objectives Checklist
**When to use**: Testing whether a theme or initiative deserves roadmap space.
**How**: Ask "why?" repeatedly until it lands on one of: support core value; create barriers to competition; grow market share; fulfill more demand; develop new markets; improve recurring revenue; support higher prices; improve lifetime value; lower costs; leverage existing assets. Attach a key result. Lands on none → question the work.
**Trade-offs**: Internal objectives — never show this framing to customers or channel partners.
*(Ch 4)*

## Themes

### The Theme Format
**When to use**: Writing any roadmap item.
**How**: `Ensure [result] for [stakeholder]` — 33% simpler than a user story, with no slot for a feature. Derive themes by asking "what would need to be true for the product to realize its vision and hit its objectives?" Convert a handed-down deliverable by asking why it matters and what results. Color-code each by the objective it serves.
**Trade-offs**: A theme mapping to no objective must be reframed, deferred, or cut.
*(Ch 2, 5)*

### Subtheme Decomposition
**When to use**: A theme is too coarse to act on, or a solution must appear.
**How**: Keep the need as parent; hang specific needs beneath (`Address usability issues` → `Pagination`, `Menu navigation`). Subthemes may be need- or solution-based. Admit a feature only for three reasons — probable solution, vetted infrastructure solution, carryover — and always as a subtheme, never beside a theme.
**Trade-offs**: A feature level with themes loses the problem it exists to solve.
*(Ch 5, 6)*

### User Journey / Experience Map
**When to use**: New product, rethink, or checking a feature request against real experience.
**How**: Define phases from "user realizes the problem" to "problem solved" → enumerate the minute actions in each → capture emotion per step → the snags become themes and subthemes → zoom into a step to detail its need. Plot multiple roles together into an experience map.
**Trade-offs**: Goes stale as customers evolve — re-map regularly.
*(Ch 5)*

### Opportunity-Solution Tree
**When to use**: After journey mapping, when the team is drowning in unstructured problems and ideas.
**How**: Root = one desired outcome (a business objective) → branch into opportunities (this book's themes) → branch into solutions → branch into experiments that validate them. Work down level by level so each decision compares a few like things.
**Trade-offs**: Only as good as the outcome at the root.
*(Ch 5)*

### Job Story / User Story
**When to use**: Backing a theme with evidence that forces the *why* out before committing.
**How**: Job story `When [situation] / I need [desire] / So I can [result]` when the triggering situation matters more than the persona; user story `As a [user type] / I want [desire] / So I can [result]` when the role matters. Themes are the epic tier; these decompose them.
**Trade-offs**: Neither belongs on the roadmap face — they are supporting detail.
*(Ch 5)*

## Prioritization

### Critical Path
**When to use**: Scoping an MVP or a major scope expansion; re-run on growth products, since a new critical path emerges once the original pain is solved.
**How**: Journey-map each key role → capture emotional state per step → find hot-button aggravations driving users to seek a better way → keep only steps that must be fixed for a user to "hire" your solution → insert your solution at peak pain. The survivors are the MVP blueprint.
**Trade-offs**: Ignores effort, risk, business goals; ranks no finer than critical vs noncritical.
*(Ch 7)*

### Kano Model
**When to use**: Critical-path needs are covered and you're choosing among add-ons.
**How**: Bucket each need as Expected (dissatisfier — absent means no purchase), Normal (satisfier), or Exciting (delighter). Satisfy expected first; exciting needs define category leaders.
**Trade-offs**: Expectations inflate — today's delighter is tomorrow's normal. Perception is customer-specific. Ignores effort and business goals.
*(Ch 7)*

### Desirability, Feasibility, Viability
**When to use**: A small set of initiatives, or competing solutions to one problem.
**How**: Score 1/2/3 on Desirability (customer value of solving it), Feasibility (ease of building — easy scores high), Viability (value to the org, usually revenue/profit). Sum out of 9; strong-on-all-three beats one-axis winners.
**Trade-offs**: Breaks down when dozens all score 8 or 9. Exciting needs score lower desirability than expected ones.
*(Ch 7)*

### ROI Scorecard
**When to use**: Long lists (dozens to hundreds), multiple competing factors, no obvious answer.
**How**: `Priority = ((CN1 + CN2 + … + OG1 + OG2 + …) / Effort) × Confidence%`. Pick a few customer needs and org goals as columns (choosing them forces strategy alignment) → score each idea 0/1/2 (or 1–3, 1–5; negatives legal when goals conflict) → sum for value → size effort by T-shirt → divide, multiply by confidence, sort descending. Note dependencies, resources, and promises in the margin — they change scheduling, not priority.
**Trade-offs**: Excludes intangibles like buzz. The score informs the decision, it never is the decision.
*(Ch 7)*

### T-Shirt Sizing
**When to use**: Any effort input — scorecards, workshops, business cases.
**How**: XS=1, S=2, M=3, L=4, XL=5, relative only. Size cross-functionally (build, test, release, marketing research, sales retraining, channel work). Make the first estimate yourself, then ask an implementer to tell you why you're wrong.
**Trade-offs**: Management converts any number into a date — say "relative size" out loud.
*(Ch 7)*

### MoSCoW
**When to use**: Communicating launch criteria after priorities are already set.
**How**: Must = can't launch without it (critical path / dissatisfiers), never cut. Should = painful to omit (satisfiers), cut last. Could = include if easy (delighters), cut first under deadline risk. Won't = explicitly out of scope, agreed up front to block scope creep, never dissatisfiers. Split Could from Should by pain of omission.
**Trade-offs**: Not a prioritization method — it only communicates priorities set elsewhere.
*(Ch 7)*

### $100 Test
**When to use**: The sizing block of a co-creation workshop, to narrow a long list.
**How**: Give each participant $100 to invest across candidate themes, but only in their own category — Marketing/Sales/UX in desirability, Engineering in feasibility, Product in viability. Tally per theme; take the top as the shortlist, then decide together.
**Trade-offs**: Voting narrows, it never decides. Treating the tally as the verdict is the failure.
*(Ch 8)*

## Alignment & Buy-in

### Shuttle Diplomacy
**When to use**: Stakeholders with competing priorities or political agendas; always before a group roadmap meeting.
**How**: Bring a draft, never a blank page → open on goals, not features → run GROW → put every idea they raise visibly on your scorecard → score their items with them against the goals → record in the Canvas → keep it short, informal, scoped to what they care about → then convene the group to finalize, often in 90 minutes because the hard conversations already happened.
**Trade-offs**: N extra meetings with meeting-allergic people; depends on rapport, and in-person beats video.
*(Ch 8)*

### Shuttle Diplomacy Canvas
**When to use**: Recording each one-on-one. Private to you, never shared.
**How**: One column per stakeholder, five rows — Goals (outcomes, motivation, their metrics), Reality (load and recent events), Options (raw asks), Way forward (priorities they agree on), Additional considerations (politics, hidden agendas). Read Way forward *across* columns: items appearing in several are your alignment.
**Trade-offs**: A stakeholder repeatedly pushing something off-strategy signals an unwritten goal. Dig for it.
*(Ch 8)*

### GROW
**When to use**: Structuring each shuttle-diplomacy one-on-one.
**How**: **G**oals — what are they accomplishing in the next X months, why, on what metric? **R**eality — what's on their plate, what happened recently? **O**ptions — what do they think gets them there, what needs revisiting? **W**ay forward — which options actually serve the goals they named, what's top and why?
**Trade-offs**: Collapses the moment you let it become a feature list.
*(Ch 8)*

### Co-creation Workshop
**When to use**: After shuttle diplomacy, to finalize; or straight away when stakeholders are few and politics cool. Run quarterly.
**How**: Define the outcome before booking the room (a finalized roadmap for the period). 90-minute agenda: intro and rules (5) → Hopes and Fears (10) → Vision MadLibs or Cover Story (10) → Back-plan (15) → sizing and prioritizing via $100 Test (40) → wrap-up (10), confirming decisions and agreeing not to reopen them without significant new information.
**Trade-offs**: Needs constructive disagreement and rough strategy agreement; without predefined outcomes it's just another meeting.
*(Ch 8)*

### Hopes and Fears
**When to use**: Opening block of the workshop.
**How**: Each person writes hopes on one Post-it color, fears on another, one per note. Cluster them, then check the clusters against the established business objectives.
**Trade-offs**: Needs enough safety for real fears to appear.
*(Ch 8)*

### Vision MadLibs
**When to use**: Vision block, to get everyone's vision on the table fast.
**How**: Everyone fills *"A world where the [target customer] no longer suffers from the [problem] because of [product differentiator] they [benefit]."* Pare to *"To [benefit realized] by [product differentiator]."* Compare responses aloud — divergence is the finding.
**Trade-offs**: Generic phrasing; treat output as raw material.
*(Ch 8)*

### Cover Story
**When to use**: Alternative to MadLibs when the group needs to think bigger.
**How**: Each participant draws the magazine cover five years out, after the roadmap has shipped — headline, image, subheadline, sidebars, a quote. Share and compare.
**Trade-offs**: Slower than MadLibs; some participants resist drawing.
*(Ch 8)*

### Back-plan
**When to use**: Right after the Cover Story, to make an aspirational future concrete.
**How**: Start from the envisioned outcome and step *backward*, one realistic step at a time, to today. Future = "solo business travelers enjoy dining with strangers"; first step back = "they can search a desirable local restaurant in an unfamiliar area." Continue to the present.
**Trade-offs**: Teams drift forward again — enforce the backward direction.
*(Ch 8)*

### Presenting Recommendations
**When to use**: Hierarchical orgs with a steering committee or quarterly portfolio review.
**How**: Beforehand each team gathers stakeholder inputs shuttle-diplomacy style ("what are priorities for sales? clinical? security?"), T-shirt sizes each initiative to gauge resources, and assembles business cases answering: what's the story around these initiatives, how do they fit vision and long/near-term strategy, what about competitive landscape and market timing. Present for sign-off.
**Trade-offs**: Heavy homework, and sign-off gives less authorship than co-creation.
*(Ch 8)*

## Presenting & Sharing

### Modular Roadmap
**When to use**: Any time more than one audience needs the roadmap — which is always.
**How**: One foundation, not one roadmap per group. Slides 1–4 identical for everyone: vision → strategy → themes → timeframes. Then exactly one slide per audience carrying that group's secondary and complementary components, kept in the same document so the link from story to detail stays visible.
**Trade-offs**: Divergent per-audience roadmaps destroy alignment — one customer expects feature X, another feature Y.
*(Ch 9)*

### Audience Tailoring
**When to use**: Choosing the per-audience layer.
**How**: Dev team → features/solutions, stage of development, product areas, plus platform and project info co-presented with engineering; never present a Gantt as the roadmap. Sales & Marketing → stage of development incl. beta, target customers, confidence percentages, features sparingly, plus external drivers; use *likely/probable/tentative*. Executives & Board → vision, strategy, themes, plus financials; keep detail on hand, don't lead with it. Customers → themes and rough timeframes only, with disclaimer and "Considering / In development / Released" framing.
**Trade-offs**: An over-specific roadmap handed to sales becomes a commitment in a customer call.
*(Ch 9)*

### Presentation Prep Checklist
**When to use**: Before every roadmap presentation, without exception.
**How**: (1) Identify the audience — peers or executives, have they seen it, what input have they given? (2) Clarify your goal — input on a draft, alignment on one aspect, or informing? (3) Determine what they care about and at what detail. (4) Assemble vision, objectives, themes, timeframes, then pick secondary/complementary pieces from (1) and (3).
**Trade-offs**: Two minutes of prep; skipping it produces the wrong deck.
*(Ch 9)*

### Presentation Sequence
**When to use**: Delivering the roadmap.
**How**: (1) Start with the why — vision before details, plus recent progress since last time, plus emotion via customer quotes. (2) Near term — name which critical needs justified the prioritization and how they tie to objectives; add sales and support stories. (3) Longer term, reinforcing alignment with company objectives.
**Trade-offs**: A list of deliverables invites date interrogation; a story invites buy-in.
*(Ch 9)*

### Detail-by-Distance
**When to use**: Deciding what to reveal externally, by role.
**How**: The further someone sits from the core product development team, the less detail on features, functions, and dates — and the less on brand-new product directions and internal infrastructure work.
**Trade-offs**: Exception — enterprise and component businesses where the customer commits multi-year, multi-million spend. There, detail is the price of the deal.
*(Ch 9)*

## Maintenance & Rollout

### Refresh-Rate Rule of Thumb
**When to use**: Setting revision cadence and roadmap span.
**How**: Match refresh rate to time scale — a quarterly roadmap is revisited quarterly. Span by life stage: Discovery → months with Now/Next/Later; Growth → quarters; Maturity → years. On each refresh rerun the full creation process (vision, strategy, goals, themes) rather than patching items. Between refreshes, leave execution alone.
**Trade-offs**: A startup borrowing an enterprise three-year format and treating it as a commitment.
*(Ch 10)*

### Three Questions for Special Requests
**When to use**: Someone asks you to "just slip in" a one-off.
**How**: In order. (1) What problem is this trying to solve? Trace past the requestor to whoever has the underlying problem, interview them, ask why several times — reveals whether they're even in your target market and opens less disruptive options. (2) Does solving it align with our objectives? ("Provides value" ≠ "advances the goals we aligned on.") (3) Is it more important than what's on the roadmap now? Preferred resolution: swap something planned out, keeping scope constant.
**Trade-offs**: If you accept added scope, name immediately which iron-triangle lever gives — otherwise quality silently absorbs it.
*(Ch 10)*

### Forks in the Road
**When to use**: A strategic either/or (down-market vs premium, new tech vs cost reduction) where both paths look nearly equal.
**How**: Pick one opportunity to pursue now, draw both pathways, and attach thresholds — specific key-result numbers the product must hit — as the decision criteria for which branch you take. Publish the criteria alongside the visual and present at a stakeholder buy-in meeting.
**Trade-offs**: The commit point must be known in advance; you can't switch from ferry to car mid-crossing. Pursuing both forks at once is the failure.
*(Ch 10)*

### Depth-of-Revisit Ladder
**When to use**: Something changed and you need to know how far back to go.
**How**: Minor changes → Ch 8 (buy-in, transparency). New priorities, vision unchanged → Ch 7 (prioritization rationale). New areas of functionality → Ch 6 (features/solutions). Customer or org needs changed, new customer types → Ch 5 (themes). Vision, strategy, or key objectives changed → Ch 3 (rethink from the ground up). Communicate why first, then what and when.
**Trade-offs**: Omit the why and the team invents a less charitable reason.
*(Ch 10)*

### Roadmap Health Assessment
**When to use**: Step 1 of any relaunch, before choosing an approach.
**How**: Score 14 questions 0–2 (0 = mostly no, 2 = definitely yes); max 22. **Add** the positives — clear vision stakeholders can explain; measurable objectives they know; roadmap focused on customer needs; everything tied to needs/objectives; time allowed to learn before committing; updated regularly; established alignment process; accepted prioritization method; regularly shared with stakeholders; customer feedback incorporated; regularly shared with customers. **Subtract** the negatives — precise or best-case dates on it; specific features/deliverables on it; solutions thoroughly designed before the need goes on; project info embedded in it. 12+ → Approach A; ≤11 → Approach B.
**Trade-offs**: Self-scoring is biased — have each stakeholder score independently, then compare.
*(Ch 11)*

### Approach A vs Approach B
**When to use**: Immediately after the health score.
**How**: **A — Course Corrections** (12+): use the assessment answers to find the most promising or most-broken gaps, prioritize them with a Ch 7 method (critical path works well), fix one part of the process at a time with a goal reachable in a few weeks. **B — Full Relaunch** (≤11): build a process from a new baseline, Ch 3 → Ch 10 in order, optionally kicked off with a Design-Sprint-style roadmap workshop — cross-functional stakeholders for a few days producing an initial roadmap plus agreed next steps.
**Trade-offs**: B takes months even for experienced teams; fixing everything at once stalls A.
*(Ch 11)*

### Six-Step Relaunch Process
**When to use**: The org is bogged down predicting the unpredictable, or has abandoned roadmaps and runs sprint-to-sprint.
**How**: (1) Assess and choose A or B. (2) Get buy-in via shuttle diplomacy and co-creation — better, have each stakeholder score the checklist independently; seek alignment, not consensus. (3) Train stakeholders to contribute — they arrive expecting features and dates; explain what's different, why, and how it's better. (4) Start small: under A one area with a few-weeks goal; under B a multi-day workshop, or limit the audience to the product core then widen. (5) Evaluate on a standing cadence — a cross-functional product steering committee every three to six weeks. (6) Keep relaunching; expect resistance, including from your own team.
**Trade-offs**: You can't change process by fiat across departments, and you won't get it right first try.
*(Ch 11)*
