# Session title, eg. "Payment flow threat model"

- **Facilitator**: Your Name [@your-github-handle] (security champion)
- **Participants**:
  - **Business stakeholder**: _____
  - **Technical architect**: _____
  - **Development lead**: _____
  - **Security analyst**: _____
  - **Privacy officer** (eg. data controller): _____
  - **Other stakeholders**: _____
- **Session date**: YYYY-MM-DD
- **Scope**: owner/repo@<commit>, or the subsystems/services/data flows assessed
- **Frameworks**: STRIDE, LINDDUN, OWASP Top 10, …

## Summary

A short, single-paragraph verdict on the security and privacy posture of the
scoped system, and the headline risks this session surfaced. What is the shape
of the exposure?

## Business context

Why does the system exist, and what business value does it provide? What are the
critical business functions? Who are the key stakeholders?

What is the business impact of a security or privacy failure – financial,
reputational, regulatory, operational?

## Technical scope

What is being threat modeled? Define the system boundaries and in-scope
components. What is expressly out of scope?

What is the technology stack? What are the deployment environments and the
integration points with other (out-of-scope) systems?

## Decomposition

How does the system work? Include or link to architecture diagrams, data-flow
diagrams, and other models used in the session.

### Key components

| Component       | Description                                        | Trust level  | Data handled                         |
| --------------- | -------------------------------------------------- | ------------ | ------------------------------------ |
| Web checkout UI | Browser SPA where the customer enters card details | UNTRUSTED    | Card number (PAN), billing address   |
| Payments API    | Server-side service orchestrating the charge       | TRUSTED      | Card token, order total, customer ID |
| Payment gateway | Third-party processor (eg. Stripe)                 | SEMI-TRUSTED | Card token, transaction result       |
| …               | …                                                  | …            | …                                    |

### Data flows

| Source          | Destination     | Data type             | Protocol | Authentication              |
| --------------- | --------------- | --------------------- | -------- | --------------------------- |
| Web checkout UI | Payments API    | Card details, order   | HTTPS    | Session cookie + CSRF token |
| Payments API    | Payment gateway | Card token, amount    | HTTPS    | API key (server-side)       |
| Payment gateway | Payments API    | Charge result webhook | HTTPS    | Signed webhook payload      |
| …               | …               | …                     | …        | …                           |

### Sensitive assets

| Asset                   | Sensitivity    | Integrity req. | Availability req. | Privacy concern            |
| ----------------------- | -------------- | -------------- | ----------------- | -------------------------- |
| Card data (PAN)         | HIGH (PCI-DSS) | HIGH           | MEDIUM            | Yes – cardholder data      |
| Payment gateway API key | HIGH           | HIGH           | HIGH              | No                         |
| Order + customer record | MEDIUM         | HIGH           | MEDIUM            | Yes – personal data (GDPR) |
| …                       | …              | …              | …                 | …                          |

### Entry points

The external interfaces, APIs, and user interfaces to the system.

### Trust boundaries

Where trust changes, eg. internet to DMZ, DMZ to internal network.

## Threat assessment

Assess each component, data flow, and asset against the chosen framework(s).
Rate each threat by likelihood and impact to yield a severity, using a
consistent scoring scheme.

| Ref | Component / Flow               | Description                                                                  | Type                   | Countermeasures                                          | Likelihood | Impact   | Severity |
| --- | ------------------------------ | ---------------------------------------------------------------------------- | ---------------------- | -------------------------------------------------------- | ---------- | -------- | -------- |
| TA1 | Gateway webhook → Payments API | Attacker forges a "charge succeeded" webhook to mark an unpaid order as paid | SPOOFING               | Signature check on webhook payload                       | POSSIBLE   | CRITICAL | HIGH     |
| TA2 | Web checkout UI → Payments API | Order total tampered client-side to pay less than the cart value             | TAMPERING              | Server recomputes total from cart; ignores client amount | UNLIKELY   | SEVERE   | MEDIUM   |
| TA3 | Payments API logs              | Full card number written to application logs, exposing PAN                   | INFORMATION DISCLOSURE | Tokenize at the edge; never log PAN                      | POSSIBLE   | CRITICAL | HIGH     |
| TA4 | Payment gateway API key        | Long-lived key leaked from source or config grants charge access             | ELEVATION OF PRIVILEGE | Secrets manager; short-lived, rotated keys               | UNLIKELY   | CRITICAL | HIGH     |
| …   | …                              | …                                                                            | …                      | …                                                        | …          | …        | …        |

### Risks raised

Which of the threats above are worth tracking over time, and were therefore
promoted into the risk register. List their register references here. The
register tracks their ongoing status.

- `TA1`: Forged payment-confirmation webhook.
- `TA3`: Card number (PAN) leaked to application logs.
- `TA4`: Long-lived payment gateway API key.

(`TA2` was assessed but not promoted. The server-side total recomputation
already reduces it to Medium, with no residual exposure worth tracking.)

## Mitigation strategies

For each risk raised, capture the agreed mitigation strategy, or the reason for
accepting the risk with no mitigation. Record enough rationale that a future
reader understands _why_ this response was chosen. Detailed step-by-step
remediation belongs in the code repository's own issue tracker — link to it.

## Follow-ups

- [ ] Create tickets for mitigation work in the relevant code repositories.
- [ ] Add / update the corresponding rows in the risk register.
- [ ] Schedule the next threat modeling session.
