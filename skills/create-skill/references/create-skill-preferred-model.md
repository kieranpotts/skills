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

This is a proprietary metadata field and few clients (agent harnesses) will
support it. See https://github.com/kieranpotts/pi for an example implementation.
