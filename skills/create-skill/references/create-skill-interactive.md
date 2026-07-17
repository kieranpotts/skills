# Interactive vs. non-interactive skills

Read this when deciding whether a skill should prompt the user mid-flow, and
whether to declare `metadata.interactive`.

A skill is said to be **interactive** if it allows or instructs the agent to
block on user input — pausing to ask a question and waiting for the answer
before continuing. A skill is **non-interactive** if it explicitly tells the
agent to do its work from start-to-finish from its inputs and the workspace
alone, never stopping to get more input from the user.

Interactivity is desirable where human interaction is the core value in the
skill, for example a structured interview, or discovery of context that exists
only in the user's head.

Non-interactivity is desirable where there may be valid use cases for running
agents unattended, for example in continuous integration systems.

A skill MAY declare its mode under the `metadata:` map:

```yaml
metadata:
  interactive: no   # This skill never blocks on the user.
```

The value is `yes` or `no`. When the field is omitted, the default is `yes`.

This is a proprietary metadata field and few clients (agent harnesses) will
support it. See https://github.com/kieranpotts/pi for an example implementation.

> [!NOTE]
> `metadata` is the Agent Skills standard's sanctioned place for vendor data, so
> the key validates against the canonical schema and the skill stays portable.
> Clients tha do not support the `interactive` field will simply ignore it.
