# Interactive vs. non-interactive skills

Read this when deciding whether a skill should prompt the user mid-flow, and
whether to declare `metadata.interactive`.

A skill is said to be **interactive** if it allows or instructs the agent to
block on user  input — pausing to ask a question and waiting for the answer
before continuing. A skill is **non-interactive** if it explicitly tells the
agent to do its work from start-to-finish from its inputs and the workspace
alone, never stopping to get more input from the user.

Interactivity is desirable where human interaction _is_ the value in the skill,
for example a structured interview, or discovery of context that exists only
in the user's head.

Non-interactivity is desirable where there may be valid use cases for running
agents unattended, for example in continuous integration systems.

## Declaring it

A skill MAY declare its mode under the `metadata:` map:

```yaml
metadata:
  interactive: no   # This skill never blocks on the user.
```

The value is `yes` or `no`. When the field is omitted, the default is `yes`.

A skill is assumed interactive unless it explicitly says otherwise. This is the
safe default. A host that auto-runs skills unattended will not silently run one
that might have needed a human.

Set `interactive: no` only when you are confident the skill runs to completion
without ever blocking on the user. Leave the field off (defaulting to `yes`) for
skills that are interactive, or *conditionally* interactive — those that usually
run through but may stop to ask when a constraint is unclear.

Claiming `interactive: no` for a skill that might actually prompt is the mistake
this field exists to prevent.

> [!NOTE]
> `metadata` is the Agent Skills standard's sanctioned place for vendor data, so
the key validates against the canonical schema and the skill stays portable —
hosts that do not read it simply ignore it.
