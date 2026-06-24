---
name: claudie-writer
description: Use when asked to write a technical design document, architecture doc, or any formal engineering document. Prompts for save path and uses the standard design doc template.
---

# Document Writer

## Overview

Write structured technical design documents following the standard template.
**Always ask for the output path before writing anything.**

## Workflow

```dot
digraph doc_writer {
    "Invoked" [shape=doublecircle];
    "Ask: where to save?" [shape=box];
    "User provides path" [shape=box];
    "Research codebase/context" [shape=box];
    "Write document using template" [shape=box];
    "Save to provided path" [shape=box];

    "Invoked" -> "Ask: where to save?";
    "Ask: where to save?" -> "User provides path";
    "User provides path" -> "Research codebase/context";
    "Research codebase/context" -> "Write document using template";
    "Write document using template" -> "Save to provided path";
}
```

## Step 1 — Ask for Path (REQUIRED)

Before any research or writing, ask:

> "Where should I save this document? (e.g. `docs/my-feature/index.md`)"

**Do not proceed until the user provides a path.**

## Step 2 — Research

Explore the relevant code, PRs, configs, and context needed to fill every section of the template.

## Step 3 — Write

Use the template at `TEMPLATE.md`. Fill every section — do not leave placeholder text. If a section genuinely does not apply, write "N/A" with a one-line explanation.

## Step 4 — Save

Write the completed document to the user-provided path.

## Rules

- Owner field: use the actual engineer's name/email if known, otherwise `@engineer`
- Status: always start as `Draft`
- Diagrams: use ASCII/Mermaid/sequence diagrams where possible
- Do not invent facts — research the code first
- Template file must not be modified
- If drawing diagrams, MUST use Mermaid syntax for consistency and future renderability
