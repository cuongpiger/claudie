# Chapter 05: Comments, Formatting & Style *(book ch. 9–10)*

## Core Idea
**Code explains *what* and *how*; comments explain *why*.** The default response to "this needs a comment" is to **refactor first** — comment only when refactoring can't help or when there's contextually important information code cannot express. Formatting is mostly subjective, but three **objective readability truths** derive from human physiology, and tooling (ESLint + Prettier + Husky) is how you enforce the rest.

---

## Part A — Comments

### The rule
> **Code explains *what* and *how*, comments explain *why*.**

- **High-level code excels at explaining the *what***: from the method name, parameters, and declarative body you should deduce what it does without descending a layer.
  ```typescript
  export class SpotifyService {
    public createMusicRecommendations(
      history: ListeningHistory,
      artists: Artists,
      playLists: Playlists
    ): Promise<MusicRecommendations> { }
  }
  ```
- **Lower-level code describes the *how***, layer by descending layer.
- *"If you can get all the way to the bottom without feeling like comments are necessary because the code is that clear and readable, applaud yourself."*

### When a comment IS warranted
You'll encounter cases where you either:
1. Hit something that **can't easily be refactored** to be simpler, or
2. Need an algorithm or implementation that is **fundamentally more complex** (**absolute complexity**), usually for performance or optimization.

At that point, write the comment — **not to describe the *what* or *how*, but the *why***.

### The four-step workflow
1. Notice that code seems complex, or that another human may not understand it.
2. **First attempt to refactor the code.**
3. If it can't be easily refactored, or further refactoring would make it *more* complex, **or** there's something contextually important that can't be said with code — **leave a comment**.

> **The rule of thumb**: *"Prefer refactoring (imperative) code — to declarative code — instead of writing comments."*

Stemmler explicitly disagrees with the common "senior developers leave comments to explain why things work" advice on one point: *"if you're curious about **how the code works**, it's the responsibility of the code to explain that to you, not the comments."*

### The four kinds of bad comment

| Kind | Example |
|---|---|
| **Redundancy** — says what the code already says | `/** This method gets the user by user id. */` above `getUserByUserId()` |
| **Log/journal entries** — belongs in source control, not source code | `/* 01-03-2008 - Tony Soprano - Added the ability to also work on strings. */` |
| **Commented-out code** — delete it | `// function parseHandle (url, type) { ... }` |
| **Closing brace comments** | `} // end of inner if` |

---

## Part B — Formatting & Style

### The Three Objective Readability Truths

Formatting is subjective — Java devs put the brace on the same line, C devs on the next; *"who knows"* which is better. But because we're all human, **certain physiological limitations are shared**:

1. **Without proper use of whitespace, code becomes virtually impossible to read.**
2. **Without consistency, we can't turn on the pattern-matching algorithm in our brains** — increasing the time it takes to grow accustomed to a new codebase. *Consistency helps readers build **comprehension momentum**.*
3. **Without storytelling and succinct expression of the main ideas at the highest layer of abstraction**, readers lose interest and get fatigued plucking through implementation details.

### Whitespace rules

```typescript
// ❌ Bad horizontal spacing
const x=12;
const user={name:"khalil"}
class Employer {
  public update(details:CompanyDetails):Result<UpdateResult>{ }
}

// ✅ Good horizontal spacing
const x = 12;
const user = { name: "khalil" }
class Employer {
  public update (details: CompanyDetails): Result<UpdateResult> { }
}
```
- **Horizontal spacing delineates token types** — each line is slightly easier to read, and *"these small acts of care compound over an entire codebase."*
- **Horizontal indentation makes scope visible** — you see it by comparing how statements sit along the Y-axis.

**Keep code density low**: *code density is how many lines go without a line break.* **Line breaks are like commas in English** — they signal a resting point, another step, or a separate thought.

**Prefer smaller files**: Uncle Bob's research found the average file across several enterprise Java projects was **200–500 lines**. Smaller files mean less to read, less to understand, and less surface area for confusion — and they're *an indication that good **Separation of Concerns** and **Single Responsibility** were implemented.*

### Capitalization — the three conventions

| Convention | Looks like | Typically used for |
|---|---|---|
| **Pascal case** | `LooksLikeThis` | Classes, namespaces |
| **Camel case** | `looksLikeThis` | Variables, methods |
| **Underscores** | `looks_like_this` | (language-dependent) |

Capitalization is **strategic** — it lets you *quickly figure out what type of construct you're looking at* without reading further.

### Storytelling — the two principles

**The Newspaper Code Principle**: **front-load a file with the most important things.** Unlike a traditional story (set the scene, introduce characters, pose the conflict), code should *get to the interesting stuff right away* — so readers learn the primary reason the class exists much sooner.

```typescript
// ❌ Private details first — the reader learns nothing about why this class exists
export class RecordingStudio {
  private getDemoFromLibrary(demoNameQuery: string, artist: Artist): Demo { }
  private recordVocals(demo: Demo): void { }
  private prepareInstrument(instrument: Instrument): void { }
  // ... public API buried at the bottom
}
```

**The Step-down Principle / consistent level of abstraction**: within one method, all statements should sit at the *same* altitude.

```typescript
// ❌ Mixed abstraction levels
public async recordSong(demoNameQuery: string, artist: Artist): void {
  const demo = this.getDemoFromLibrary(demoNameQuery, artist);

  // ── this level is detail-oriented ──
  const instruments = demo.getInstruments();
  for (let instrument of instruments) {
    this.prepareInstrument();
  }
  this.metronome.setBpm(demo.bpm);
  this.assembleMusiciansForInstruments(instruments);
  this.controls.startRecording();
  await this.bandroom.performSong(demo);
  this.controls.stopRecording();

  // ── ...but this level is high-level ──
  await this.recordVocals(demo);
  await this.mixLevels(demo);
  await this.masterDemo(demo);
}
```
**The fix**: group the detailed operations into `recordMusicFromDemo()`, so `recordSong()` reads at one consistent altitude and the details live one layer down.

> **Code should descend in abstraction towards lower-level details.** Also: **keep related methods close to each other.**

### Tooling — the JS/TS trifecta

| Tool | Role |
|---|---|
| **ESLint** (over TSLint) | Enforces style, formatting, and coding standards — tells you when you're off-standard |
| **Prettier** | Auto-formats |
| **Husky** | Pre-commit hooks so the rules actually run |

```json
// .eslintrc
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint", "no-loops"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "no-console": "error"
  }
}
```
```json
// package.json
{ "scripts": { "lint": "eslint . --ext .ts" } }
```

**ESLint severity levels**: `"off"` = 0 (rule disabled) · `"warn"` = 1 · `"error"` = 2.

## Anti-patterns
- **Comments explaining *how* the code works** — that's the code's job; refactor instead.
- **Redundant comments** restating the method name.
- **Changelog comments in source** — source control already does this.
- **Commented-out code** — delete it; it's an *accidental signifier* that something is in progress.
- **`} // end of if`** — if you need it, your nesting is too deep (Object Calisthenics Rule #1).
- **Dense code with no line breaks** — prose without commas.
- **Files well over 500 lines** — a Separation of Concerns / SRP failure showing up as a formatting problem.
- **Private helpers at the top of a class** — Newspaper Code violation; the reader learns implementation before purpose.
- **Mixed abstraction levels in one method** — the reader has to keep changing altitude.
- **Relying on team discipline instead of tooling** — with 20+ developers, only automation keeps everyone aligned.

## Key Takeaways
1. **Refactor before you comment.** The comment is the fallback, not the first move.
2. **Comment the *why*, never the *what* or *how*.**
3. **Absolute complexity is the legitimate case for a comment** — an algorithm that's inherently complex, usually for performance.
4. **Whitespace, consistency, and storytelling are objective**, not matters of taste — they follow from how humans read.
5. **Line breaks are commas.** Keep density low.
6. **File size is a design signal**: 200–500 lines is the empirical norm; well beyond it means SoC/SRP problems.
7. **Front-load the file** with the most important, public, purpose-revealing code.
8. **One altitude per method.** Extract to descend.
9. **Enforce with ESLint + Prettier + Husky** — subjective debates end when the tool decides.

## Connects To
- **Ch 04 (Naming)** — the naming law's other half: names give *what*, context/comments give *why*.
- **Ch 02 (Human-Centered Design)** — comments and tests are *intentional signifiers*; dead code is an *accidental* one.
- **Ch 01 (Complexity)** — essential/absolute complexity is what survives refactoring.
- **Ch 14 (Object Calisthenics)** — Rule #1 (one level of indentation) removes the need for closing-brace comments; Rule #7 (keep entities small) is the file-size rule.
- **Ch 19 (Simple Design)** — "Expresses Intent" is what makes comments unnecessary.
- **Ch 03 (Documentation)** — tests as the primary documentation.

## References
- *Clean Code* — Robert C. Martin (file-size research, Newspaper Code, Step-down Principle)
- khalilstemmler.com — ESLint with TypeScript · Prettier with ESLint in VSCode · Husky pre-commit hooks
