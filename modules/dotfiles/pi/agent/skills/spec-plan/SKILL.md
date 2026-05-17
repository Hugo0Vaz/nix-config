---
name: spec-plan
description: Creates a thorough specification and plan before writing any implementation code. Use when the user asks to build, create, implement, or design a feature, system, module, refactor, or any non-trivial code change.
---

# Spec-Plan

Before writing implementation code, deliver a complete specification that the user
can review and approve. This prevents wasted effort on the wrong solution.

## When To Use This Skill

Trigger on any request that implies building or changing something non-trivial:
- "create/build/implement X"
- "design a system for..."
- "add a feature that..."
- "refactor/rewrite/restructure..."
- "figure out how to..."

Skip for one-line fixes, typos, or trivial config changes.

## Process

### Phase 1: Understand (Gather Requirements)

Ask questions that disambiguate intent. Prefer concrete over vague:

- **What is the desired outcome?** Restate it in your own words, confirm alignment.
- **Who are the users/consumers?** Human, machine, internal, external?
- **What are the constraints?** Platform, performance, dependencies, backwards compatibility.
- **What already exists?** Read relevant files in the repo. Don't guess.
- **What are the hard edges?** Error states, empty inputs, concurrency, security, scale.
- **What does "done" look like?** How will the user verify the result?

Stay in this phase until you can answer all of the above with confidence.
If the user is terse, propose reasonable defaults and ask for confirmation.

### Phase 2: Synthesize (Write The Spec)

Once requirements are clear, write the specification. Structure it as:

```markdown
## Spec: <short title>

### Goal
One sentence. What problem are we solving?

### Scope
- **In scope:** Explicit list of what will be delivered.
- **Out of scope:** Explicit list of what is intentionally excluded (prevents creep).

### Design
- **Approach:** The high-level strategy. Why this approach over alternatives?
- **Components / Files:** What will be created, modified, or deleted. One line per file.
- **Data flow:** If applicable, how data moves through the system.
- **API / Interface:** Signatures, types, contracts. Show, don't tell.

### Edge Cases & Error Handling
- Bullet list of failure modes and how each is handled.
- What happens on empty input, missing deps, timeouts, permission errors, etc.

### Verification
- How to test/validate the result.
- Commands to run, expected outputs, manual checks.
```

### Phase 3: Align (Get Approval)

Present the spec. Explicitly ask:

> "Does this match what you had in mind? Any changes before I implement?"

Do not start implementing until the user confirms. If they propose changes,
revise the spec and re-confirm.

## Rules

- Never implement before the spec is approved.
- If the user says "just do it", push back gently: "Let me write a quick spec first so we're aligned."
- Keep the spec concise. It's a blueprint, not documentation.
- If the task is genuinely trivial (one line, obvious fix), skip the spec and just do it — but state that you're skipping.
