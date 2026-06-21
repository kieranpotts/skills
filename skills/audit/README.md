# 🤖 `/audit`

The `/audit` skill is all about **architectural review**.

It evaluates the as-built architecture for modularity, consistency, security, communication patterns, and other structural qualities. The agent is instructed to conduct the evaluation on its own terms, with no reference to the documented architecture and no knowledge of trade-offs already considered.

That deliberate blindness is the point. It keeps the review unbiased so it can surface genuinely useful suggestions.

This is an evaluation skill. It does not change any code. To do that, pass the output from `/audit` as input to [`/refactor`](../refactor/).

This skill is a companion to [`/validate`](../validate/). Whereas `/validate` asks whether the *specification* should evolve, `/audit` asks whether the *design* should.

This skill instructs the agent to run non-interactively (🤖).

## How to invoke

- `/audit`, `/skill:audit` (prompts vary by harness).
- "Audit the architecture."
- "Is the design still sound?"
- "Check the codebase for structural drift."
