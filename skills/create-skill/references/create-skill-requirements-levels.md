# Requirements levels (RFC 2119)

Read this when deciding how forcefully to word a criterion, instruction, rule,
or success check in a `SKILL.md` file.

The following capitalized keywords — a subset of those defined in
[IETF RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) — MAY appear in `SKILL.md`
front-matter and body content to indicate the requirement level of a skill's
criteria, instructions, rules, or success criteria. Interpret them as RFC 2119
describes:

- **REQUIRED**, **MUST**, **MUST NOT** \
  Absolute obligations and prohibitions. The agent's output is wrong if it
  violates these requirements.

- **RECOMMENDED**, **SHOULD**, **SHOULD NOT** \
  Strong defaults. Deviate only with a clear, stated reason.

- **OPTIONAL**, **MAY** \
  Genuinely discretionary. Either choice is valid.

Reserve "MUST" / "MUST NOT" for things that are genuinely load-bearing, eg. a
fragile command sequence, a destructive-operation guard, a format contract a
downstream skill depends on. Over-using "MUST" flattens the signal. If
everything is mandatory, the agent cannot tell the real constraints from
preferences, and applies less judgment where judgment is wanted.
