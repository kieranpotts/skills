# Interactive vs. non-interactive skills

Read this when deciding whether a skill should prompt the user mid-flow, and
whether to declare `metadata.interactive`.

A skill is **interactive** if it may block on user input — pausing to ask a
question and waiting for the answer before continuing. It is **non-interactive**
if it runs start-to-finish from its inputs and the workspace alone, never
stopping to get more input from the user.

- **Interactive** suits stages where human interaction *is* the value: a
  structured interview, a one-question-at-a-time elicitation of judgment,
  preferences, or context only the user holds. An interactive skill MUST make
  clear in its body when and why it prompts.

- **Non-interactive** suits skills meant to run unattended, in pipelines and
  parallel agentic workflows.

When an interactive skill feeds a non-interactive one, resolve all the
human-dependent decisions first, so the downstream skill receives a complete,
settled input.

## Declaring it

A skill MAY declare its mode under the `metadata:` map:

```yaml
metadata:
  interactive: no   # this skill never blocks on the user
```

The value is `yes` or `no`. When the field is omitted, the default is `yes`. A
skill is assumed interactive unless it explicitly says otherwise. This is the
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
