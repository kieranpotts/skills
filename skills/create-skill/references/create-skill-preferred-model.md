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

Where the host provides the [`ollama` capability models](https://github.com/kieranpotts/modelfiles),
the vocabulary is `<DOMAIN>_<TIER>` on two axes.

The **domain** is the material the skill works over, and therefore what the
model has to be good at. The **tier** is how much model the work needs. The tier
bundles judgment depth together with context and cost, because in practice these
move together

| Capability          | Use cases                                                                   |
| ------------------- | --------------------------------------------------------------------------- |
| `WORKFLOW_BASIC`    | Workloads that run a fixed procedure requiring no judgment.                 |
| `WORKFLOW_STANDARD` | Applying a documented convention or readiness gate to a concrete case.      |
| `CODE_BASIC`        | Small edits to code where the change itself is already determined.          |
| `CODE_STANDARD`     | Writing and modifying program code from scratch. Diagnosing issues.         |
| `ANALYSIS_STANDARD` | Reasoning over a bounded problem, or eliciting from the user interactively. |
| `ANALYSIS_DEEP`     | Reasoning open-endedly, or synthesizing over a large corpus.                |
| `PROSE_STANDARD`    | Editing or summarizing text that already exists.                            |
| `PROSE_DEEP`        | Authoring a structured document from scratch.                               |
| `SECURITY_DEEP`     | Reasoning adversarially about a system.                                     |

This is a proprietary metadata field and few clients (agent harnesses) will
support it. See https://github.com/kieranpotts/pi for an example implementation.
