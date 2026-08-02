# Decide

The **decide** skill is all about framing a technical decision and writing it
up as an RFC.

This skill covers decisions about architecture, process, technology, and
tooling — and any other technical decision that would be expensive to reverse.

The output is a new RFC (or an equivalent proposal document) written against
the target project's template.

## Interactivity

This skill is interactive. The agent is instructed to interview the user —
about motivation, constraints, candidate options, and stakeholders — to help
the user prepare an RFC.

## How to invoke

> Write an RFC for this.

> Draft an RFC proposing we move to trunk-based development.

> We need to decide whether to adopt pnpm across the TypeScript services.

> Help me make the case for replacing the audit log.

## Recommended models

A frontier reasoning model, ideally with extended thinking enabled, is best
suited to this task.

## Related skills

- **[research](../research/).** Establishes facts to support an RFC.

- **[spike](../spike/).** Answers questions by developing working, but
  throwaway, code.

- **[design](../design/).** Supplies architectural trade-off analysis.
