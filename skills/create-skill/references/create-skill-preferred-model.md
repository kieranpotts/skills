# Preferred model

Read this when deciding whether a skill should pin a model, and how.

A skill MAY declare a preferred model under the `metadata:` map, as
`metadata.preferred_model`, to name the model it runs best under. The value is
an exact model id, optionally provider-qualified (`provider/id`):

```yaml
metadata:
  preferred_model: claude-opus-4-8
```

Pin a model only when the skill genuinely depends on it (eg. a judgment-heavy
review skill that needs a stronger model). Most skills should omit the field and
inherit the host's default.

## Choosing a capability

Where the host provides the [`ollama` capability
models](https://github.com/kieranpotts/modelfiles), the vocabulary is
`<DOMAIN>_<TIER>` on two axes.

The **domain** is the material the skill works over, and therefore what the
model has to be good at. Pick it from the *hard part* of the skill, not from
what the skill incidentally touches — `style` runs a formatter over source
files, so its domain is `code`, even though running a formatter is a procedure.

The **tier** is how much model the work needs. It bundles judgment depth
together with context and cost, because in practice these move together: work
that reasons more also reads more.

| Capability | Choose it when the skill… |
| --- | --- |
| `WORKFLOW_BASIC` | Runs a fixed procedure. Checks named fields, flips a label, commits. Nothing is left to judgment. |
| `WORKFLOW_STANDARD` | Applies a documented convention or readiness gate to a concrete case. The rule is written down; deciding whether it is met is not. |
| `CODE_BASIC` | Edits code where the change is already determined — a known fix, a formatter run, an actioned review comment. |
| `CODE_STANDARD` | Writes, modifies, or diagnoses code. |
| `ANALYSIS_STANDARD` | Reasons over a bounded problem, or elicits from the user interactively. |
| `ANALYSIS_DEEP` | Reasons open-endedly about trade-offs, or synthesizes over a large corpus — a whole codebase, many sources, a whole session. |
| `PROSE_STANDARD` | Edits or summarizes text that already exists. The source is the authority. |
| `PROSE_DEEP` | Authors a structured document from scratch. |
| `SECURITY_DEEP` | Reasons adversarially about a system. |

Two failure modes to avoid:

- **Do not reach for a deeper tier out of caution.** A skill that merges a
  pull request looks weighty, but if its steps are fully determined, it is
  `WORKFLOW_BASIC`. Where an irreversible action is gated on a judgment the
  skill states in prose ("MUST NOT merge over unresolved comments"), that
  judgment is what sets the tier — so it is `WORKFLOW_STANDARD`.

- **Do not file by output format.** A skill that produces a written report is
  not automatically a `PROSE_*` skill. If the hard part is the analysis and the
  prose is just how the result is delivered, it is `ANALYSIS_*`.

This is a proprietary metadata field and few clients (agent harnesses) will
support it. See https://github.com/kieranpotts/pi for an example implementation.
