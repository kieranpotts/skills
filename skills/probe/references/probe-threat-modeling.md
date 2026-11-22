# Threat modeling method

...

Read this when the target store documents no threat modeling method of its own:
no framework definitions, no rating scheme, no prompt questions. Where the store
does document one, the store wins.

## STRIDE

STRIDE sorts threats into six categories. Apply them to each component, data
flow, and trust boundary.

| Category               | Threat                                         | Example                                        | Typical countermeasure                            |
| ---------------------- | ---------------------------------------------- | ---------------------------------------------- | ------------------------------------------------- |
| Spoofing               | Impersonating another user or system           | Forged sender address used to extract secrets  | Strong authentication, SPF/DKIM, mutual TLS       |
| Tampering              | Unauthorized modification of data              | Altering a page to redirect to a phishing form | Hashes, digital signatures, integrity checks      |
| Repudiation            | Acting without leaving a trace                 | Editing logs to hide unauthorized access       | Audit logging, tamper-evident logs, log analysis  |
| Information disclosure | Leaking data to unauthorized parties           | Database breach exposing card numbers          | Encryption at rest and in transit, access control |
| Denial of service      | Making the system unusable                     | Request flood that crashes the server          | Rate limiting, load balancing, quotas             |
| Elevation of privilege | Gaining more access than was granted           | Exploit that turns a user into an admin        | Least privilege, role-based access control        |

Prompt questions, one or two per category:

- Spoofing: Who is identity-verified before data is processed? How are
  credentials transmitted and validated?
- Tampering: How is input validated? Are stored and transmitted data
  integrity-checked?
- Repudiation: Which actions are logged, and could the actor alter the log?
- Information disclosure: Where is sensitive data stored, sent, or logged? Who
  can read it?
- Denial of service: Which resources can one actor exhaust? What limits exist?
- Elevation of privilege: Is every privileged action checked server-side? Could
  a user reach another user's or tenant's data?

## LINDDUN

LINDDUN is the privacy counterpart to STRIDE. Add it when personal data is in
scope, particularly where GDPR, CCPA, or similar regulation applies. Trace how
personal data flows through the system and where each category could occur.

- Linkability: an attacker can link two or more items of data without knowing
  the identity behind them.
- Identifiability: an attacker can identify a specific user or entity.
- Non-repudiation: a user cannot deny an action they performed.
- Detectability: an attacker can tell whether an item of interest, such as a
  user or transaction, exists.
- Disclosure of information: sensitive data is exposed to unauthorized parties.
- Unawareness: users do not know their data is collected, processed, or shared,
  and so cannot control it.
- Non-compliance: the system or its operators breach privacy regulation,
  standards, or user agreements.

## Other lenses

Use these only when the user asks, or to augment STRIDE on a complex system.

- OWASP Top 10: the recurring web-application weakness categories. Classify
  each threat under a named entry.
- Attack trees: the attacker's goal is the root, sub-goals are branches, and
  specific actions or vulnerabilities are leaves. Useful for multi-step attacks.
- Kill chain: reconnaissance, weaponization, delivery, exploit, installation,
  command and control, actions on objectives. Useful for layered defenses
  against advanced threats.

## Systems-level threats

Where the system includes memory-unsafe code, such as C, C++, native extensions,
or third-party binaries, the assessment MUST reach below the application layer.
Undefined behavior at the language level does not say how exploitable a defect
is. That depends on the compiler, allocator, runtime library, operating system,
and hardware.

- Rate exploitability against the implementation, not the specification. Where
  the session cannot reason about the compiled artifact, rate the threat as
  exploitable, not as a mere correctness defect.
- Record exploit mitigations (ASLR, DEP/NX, stack canaries, control-flow
  integrity, hardened allocators) as countermeasures, never as remediation. Each
  raises the cost of exploitation and has known bypasses, so the residual risk
  is never zero. Leave the memory-safety defect open until it is fixed or the
  code is replaced.
- Elimination is the only mitigation that removes the class: memory-safe
  languages for new components, and process or sandbox isolation for native code
  that cannot be replaced.
- Where the system has no native code, say so in the technical scope. The
  finding is rarely absolute, because runtimes, interpreters, parsers, and
  compression libraries are native code inherited through dependencies.

## Rating scheme

Rate each threat by likelihood and impact, then combine them into a severity.

Likelihood rises with easy exploitation, few or weak countermeasures, and many
exposed attackers. Impact rises with many customers affected and with major
damage potential.

| Likelihood or impact | Severity |
| -------------------- | -------- |
| High                 | High     |
| Medium               | Medium   |
| Low                  | Low      |

The overall severity follows the higher of the two ratings. Whatever scale is
used, apply it consistently across every threat in the report.

## Mitigation strategies

Record a rationale against each risk, whether the response is a mitigation or a
reasoned decision to accept. Common countermeasures:

- Two-factor authentication and role-based access control.
- Encryption of sensitive data at rest, and encrypted transport.
- Message signatures.
- Logging, monitoring, and alerting.
- Rate limiting.
- Shorter data retention periods.
- Code review and penetration testing.
- Dependency updates and version pinning.
- Scheduled security scans.
