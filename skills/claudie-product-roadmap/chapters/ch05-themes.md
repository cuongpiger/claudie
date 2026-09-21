# Chapter 5: Uncovering Customer Needs Through Themes

## Core Idea
Fill your roadmap with customer **needs and problems** (themes), not solutions — because "the viability of a feature may shift dramatically, while the nature of an important customer problem will likely remain the same" (Jared Spool). The roadmap answers *what* needs solving and *why*; the release plan answers *how*.

## Frameworks Introduced

- **Themes and Subthemes**: A theme is a high-level customer (or system) need. A subtheme is a more specific need under it. The only difference is granularity. Themes can stand alone or group subthemes.
  - When to use: as the primary content of every roadmap item, replacing feature lists.
  - How: (1) State the need/problem, never the solution. (2) Group related granular needs as subthemes beneath a parent theme. (3) Keep both "needs" (something the customer doesn't have yet) and "problems" (something not working right with the current product or substitute) in scope — both are a gap or pain in the customer's experience. Example: `Theme: Address key usability issues` → `Subtheme: Pagination`, `Subtheme: Menu navigation`, `Subtheme: Save status`.
  - Why it works: themes force you to define the need *before* considering solutions, then let you evaluate how well each candidate solution meets it. They let the team say "no" to unnecessary solutions, stop playing competitive catch-up, give engineering freedom in solution design, and produce a shorter, more readable roadmap than a laundry list of features.

- **The Theme Format**: `Ensure [result] for [stakeholder]` — deliberately 33% simpler than a user story.
  - When to use: writing any roadmap item.
  - How: name the outcome and who gets it. Examples: "Make mobile experience as good as desktop for users." / "Make sharing via social networks fun and easy for users." / "Ensure access during peak times for users."
  - Why it works: it is outcome-shaped by construction — there is no slot to put a feature in.

- **User Stories** (from Agile): `As a [user type] / I want [desire] / So I can [result]`
  - When to use: supporting a theme with a role-centric need.

- **Job Stories** (from Jobs-to-be-Done): `When [situation/motivation] / I need [desire] / So I can [result]`
  - When to use: supporting a theme when the *triggering situation* matters more than the persona.
  - How: lead with the concrete moment of need, then the desire, then the payoff. Themes are the epic level; job/user stories decompose them, exactly as Agile epics decompose into user stories.
  - Why it works: the "so I can" clause forces you to answer *why* the theme is relevant before committing to it, blocking assumption-driven builds.

- **User Journey Maps / Experience Maps**: Map every step a user takes to solve a problem — from the moment they realize the problem exists, through the current workarounds they employ, to the moment it's solved and they move on.
  - When to use: new product, rethinking an existing one, or cross-referencing an incoming feature request against real experience.
  - How: (1) Define high-level phases. (2) Enumerate minute actions, movements, and tasks within each. (3) Find the snags and pain points — these become your themes and subthemes. (4) Zoom into a step to define each need in more detail. Plot multiple journeys together into an **experience map** to show how actions relate across customer types and phases, and to tease out emotions, technology needs, and other dimensions.

- **Opportunity-Solution Trees** (Teresa Torres, Product Talk): A hierarchy of desired outcome → opportunities → solutions → experiments.
  - When to use: after journey/experience mapping, when the team is drowning in an unstructured mass of problems, solutions, needs, and ideas.
  - How: start from a clear desired outcome (your business objective), branch into opportunities (what Torres calls opportunities, this book calls **themes**), branch those into solutions, and branch those into experiments that validate the solutions. Work down level by level; each decision is a comparison among a small number of like things, so the team tests and builds one problem at a time.

## Key Concepts
- **Theme**: A high-level customer or system need — an organizational construct for defining what's important to your customers at the present time.
- **Subtheme**: A more specific need that adds detail to, or decomposes, a parent theme.
- **Need vs. Problem**: A need is something the customer doesn't have yet; a problem is something not working right — both are a gap or pain in the experience.
- **System / Infrastructure Needs**: Backend functionality and operational tooling required to make the product work; also called technical or nonfunctional needs (vs. functional, customer-focused needs).
- **Roadmap vs. Release Plan**: The roadmap is a high-level view of *what* needs to solve and *why*; the release plan details *how*.
- **Output vs. Outcome**: The output is the deliverable requested; the outcome is the result desired — the end vs. the means.
- **Theme Card**: A card presenting a theme with a color-coded bar at the top identifying which business objective it serves.
- **Carryover**: A theme or subtheme unshipped from a previous plan, rolled into the next roadmap version.

## Mental Models
- **Think of the journey map as crossing a fast-moving stream.** The stream is the user's problem; the rocks are the steps in their journey. The user must pick which rocks, in what order, to land safely — and wants the easiest, most efficient path. Your job is to find where they slip.
- **Think of your system as a special sort of customer.** Infrastructure needs earn roadmap space the same way user needs do.
- **Think of building a product as constructing a home.** Backend = foundation, framing, rough plumbing, electrical. Frontend = flooring, windows, furniture, finishes. The house isn't functional without both.
- **Use "Why?" as the output-to-outcome converter.** When handed a concrete deliverable, ask: Why is this important? What will result? How does the company's fortune or the customer's happiness improve? The answer is the theme.
- **Use themes as epics.** If you know Agile, themes sit where epics sit; job/user stories decompose them. That familiarity is deliberate.

## Reference Tables

### Transforming outputs (solutions) into outcomes (themes)

| Output | Why? | Theme (Outcome) |
|---|---|---|
| HTML5 redesign | Works better on mobile | Make mobile experience as good as desktop |
| Twitter and Facebook integration | Allows customers to promote the product by sharing results | Make it easy and fun for users to promote our product |
| Infrastructure work for scalability | App slows down under heavy traffic | Ensure access and that we can fulfill peak demand |

Translating outputs into themes leaves open that there may be *better* ways to reach the same outcome — maybe a native iOS/Android app for a few core on-the-go functions beats a full HTML5 redesign: less work, more effective.

### The roadmapping hierarchy

| Level | Definition |
|---|---|
| I. Product vision | The problem you're solving, or the change you want to see in the world |
| II. Objectives | The high-level goals for this next version of the product |
| III. Themes and subthemes | The customer needs or problems you are addressing |

Each element informs and feeds the next. Objectives realize the vision; themes and subthemes accomplish the objectives.

### Theme → Job Story (Lyft)

| Term | Definition | Example |
|---|---|---|
| Theme | A high-level customer or system need | Avoid surprises for customers |
| Job story | A motivation-focused story providing as much context as possible on a specific customer need | When a user has to travel across town for a last-minute meeting / She needs to quickly determine how fast she can get there / So she can decide if this mode of transport is her best option for on-time arrival |

## Anti-patterns
- **Solutions without a clear problem to solve**: The most common product failure — features get built on instinct or stakeholder demand, with an unclear or off-base understanding of the real need.
- **Accepting feature requests at face value**: On existing products it's easy to operate on autopilot. Ask "Why does this matter?", "What need does it solve?", "How does it make the customer's life easier?", "Is there a bigger problem here?"
- **Letting journey maps go stale**: Customers evolve; a map you drew years ago may already describe the wrong journey. Return to it regularly.
- **Themes that map to no objective**: A warning sign. Every theme must relate to at least one strategic objective. If you can't connect it, reframe it, defer it to a later column, or cut it.
- **Never revisiting objectives**: Objectives go obsolete as the business shifts. Each new roadmap version starts by revisiting vision and objectives — especially when promoting items from Later → Next → Now.
- **Brainstorming solutions during theme definition**: The strongest temptation in the chapter. Solutions come next; defining them is more effective once you're confident *why*.

## Worked Example

**SpaceX — "The High Cost of Space Travel."** Musk identified the core problem preventing emigration to Mars: **cost**. The roadmap had to reduce the cost of going to Mars by 5 million percent. The technologies don't exist yet, but the four problems that must be solved became the roadmap's themes: Full reusability · Refueling in orbit · Propellant production on Mars · Right propellant. Each maps back to the objective "reduce the cost of space travel to what an average American family can afford" — e.g., "refuel in orbit" is an efficiency priority that, if executed, lowers travel cost.

**Slack's theme-based roadmap (Trello, public).** Item names are chosen with the *goal* in mind, not the deliverable: "Streamlined app development", "Deeper integration points" — leaving the team leeway on solution and design. The "About this roadmap" card names three platform themes — app discovery, interactivity, developer experience — and every item is tagged with one or more. With very few details, it communicates who they serve (app developers), what their priorities are and why, and just enough of what's coming to inspire confidence in the direction.

**Evan's mobile physical therapy app — a customer theme pulling system subthemes.** Clients wanted in-app payment, so the roadmap gained `Theme: Billing & payments`. That required backend integration, so technical subthemes followed: `Subtheme: Billing & payments API integration`, `Subtheme: API integration testing`.

## Key Takeaways
1. Start every roadmap item from a customer need or problem, not a deliverable. Leave the *how* to the release plan.
2. Write themes as `Ensure [result] for [stakeholder]` — the format makes outcome-shaping automatic.
3. Back each theme with a job story (`When… / I need… / So I can…`) or user story to force the *why* into the open before you commit.
4. Mine themes from four sources: user journey/experience maps, existing product needs (re-interrogated, not accepted at face value), system/infrastructure needs, and Opportunity-Solution Trees.
5. Treat infrastructure as a customer. System-level needs belong on the roadmap alongside functional ones.
6. Convert every proposed output to a theme by asking "Why?" — this also surfaces cheaper, better alternatives.
7. Color-code objectives and tag every theme with its objective. A theme that maps to nothing is a theme to reframe, defer, or cut.

## Connects To
- **Ch 4 (Objectives / OKRs)**: Themes must trace back to strategic objectives; the output-vs-outcome distinction is the same one applied to objectives, now applied to themes.
- **Ch 6 (Deepening Your Roadmap)**: Where features legitimately appear — as subthemes under a theme, so the *why* is retained — plus stage of development, confidence, target customers, and product areas as tags.
- **Ch 7 (Prioritization)**: Once themes exist and are tied to objectives, prioritization decides their order.
- **Jobs-to-be-Done (Clayton Christensen)**: The "hire a solution" framing behind job stories.
- **Agile epics and user stories**: Themes occupy the epic tier; the decomposition pattern is intentionally borrowed.
- **Teresa Torres, Opportunity-Solution Trees (producttalk.org)**: Her "opportunities" are this book's "themes"; solutions and experiments share nomenclature.
- **James Kalbach, *Mapping Experiences* (O'Reilly)**: The recommended deep reference for journey and experience mapping.
