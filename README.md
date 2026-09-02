# Collections Analytics — Recovery Performance & Investment Analysis

## Executive Summary

This project independently validates collections recovery performance using approximately 12 months of multi-source collections data.

The objective is to determine whether the reported claim that **"Recovery has improved by 11% month-on-month"** is supported by the underlying data, identify the factors associated with recovery performance, investigate data-quality and attribution risks, and recommend where leadership should deploy the next **₹10 Cr investment**.

The analysis prioritizes transparent definitions, reproducible calculations, data-quality validation, and decision-oriented recommendations rather than complex modelling.

---

# 1. Business Questions

The analysis addresses four core questions:

1. **What actually happened to recovery performance?**
2. **Why did recovery change?**
3. **Is the reported 11% improvement genuinely sustained?**
4. **Where should the business invest ₹10 Cr next?**

The analysis also evaluates whether the data is sufficiently reliable for operational and investment decisions.

---

# 2. Key Findings

### Recovery Performance

After deduplicating payment records and considering only successful payments, observed successful recovery during the available period was approximately:

**₹131.56 Cr**

The cleaned monthly recovery trend shows:

| Month | Successful Recovery |
|---|---:|
| Jan 2026 | ₹18.72 Cr |
| Feb 2026 | ₹17.01 Cr |
| Mar 2026 | ₹18.89 Cr |
| Apr 2026 | ₹17.51 Cr |
| May 2026 | ₹18.43 Cr |
| Jun 2026 | ₹17.56 Cr |
| Jul 2026 | ₹18.72 Cr |
| Aug 2026* | ₹4.71 Cr |

\*August is a partial observation period and should not be compared directly with the full months.

### Is the reported 11% improvement real?

The February-to-March recovery increase was approximately **11.03%**, so the reported magnitude is observed for that specific month-to-month comparison.

However, this does **not** establish sustained operational improvement.

Additional evidence indicates that:

- Successful payment volume increased by approximately 11.3% from February to March.
- Payment success rate slightly decreased.
- Recovery per agent-hour improved by approximately 5.3%.
- Recovery per targeted account improved by approximately 1.1%.

Therefore, the March recovery increase appears more consistent with a **volume/activity effect than clear evidence of a sustained productivity improvement**.

The analysis does not interpret this observational relationship as causal.

---

# 3. Data Quality Findings

The source data intentionally contains multiple forms of data-quality complexity.

Key findings include:

### Duplicate Payments

- Raw payment rows: approximately 25,500
- Unique payment IDs: 25,000
- Duplicate payment IDs: 500
- Excess successful recovery attributable to duplicate payment rows: approximately **₹2.59 Cr**

Payment IDs are therefore deduplicated before calculating recovery.

### Timestamp Conflicts

Approximately **50.32% of account-status history records** have:

`recorded_at < event_at`

This creates uncertainty around historical status reconstruction and demonstrates why event time and ingestion/recording time must be treated separately.

### Borrower Identity

Event-level borrower identifiers are frequently inconsistent with the borrower associated with the account master.

For analytical purposes, **account_id is treated as the canonical event anchor**, while raw identifiers are retained for auditability.

### Agent Identity

The agent master contains repeated historical records for the same agent identifiers with changing attributes.

As a result, current agent attributes should not be blindly used to make historical causal comparisons of agent performance, tenure, vendor, or team.

### Attribution

The share of successful payments attributed to a prior interaction changes substantially depending on the attribution window.

This demonstrates that latest-touch or window-based attribution should not be interpreted as causal evidence without an experimental design.

---

# 4. Driver Analysis

The analysis investigates recovery across:

- DPD
- Loan/product type
- Risk segment
- Geography
- Agent
- Agent tenure
- Campaign
- Channel
- Telephony vendor
- Calling time
- Attempt frequency
- Borrower segment
- Payment method

The major observed portfolio dimensions are relatively balanced.

Recovery shares across loan types and risk segments are broadly similar, so these dimensions do not provide strong evidence for explaining the overall recovery movement.

The analysis therefore distinguishes conclusions as:

- **Fact** — directly supported by the data
- **Strong Evidence** — supported by multiple consistent analyses
- **Correlation** — statistical/observational association without causal proof
- **Hypothesis** — plausible explanation requiring further testing

---

# 5. ₹10 Cr Investment Recommendation

## Recommended Area: Better Borrower Targeting

The recommended investment area is:

**Better Borrower Targeting**

The rationale is that the observed data does not provide sufficiently reliable causal evidence that additional agents, telephony infrastructure, digital channels, or field operations would generate a superior return.

A controlled targeting experiment provides a more defensible way to establish incremental recovery before committing the entire investment.

### Investment

**₹10 Cr**

### Expected Incremental Recovery

The investment case uses an explicit assumption rather than presenting the estimate as a measured causal effect.

Using the observed successful recovery base of ₹131.56 Cr:

- 5% uplift → approximately ₹6.58 Cr incremental recovery
- 6.5% uplift → approximately ₹8.55 Cr incremental recovery
- 8% uplift → approximately ₹10.53 Cr incremental recovery

### Base Case

Assumed uplift:

**6.5%**

Expected incremental recovery:

**~₹8.55 Cr**

Estimated investment:

**₹10 Cr**

Observed-period equivalent ROI:

**~−14.5%**

### Break-even

The estimated break-even uplift is approximately:

**7.6%**

### Downside Scenario

At a 2% uplift:

**~₹2.63 Cr incremental recovery**

This would result in a substantially negative return relative to the ₹10 Cr investment.

### Confidence

Confidence in the investment estimate is **low-to-moderate**, because the available observational data does not identify a causal targeting uplift.

### Required Validation

Before full-scale deployment, run a controlled pilot:

- Treatment group: accounts receiving the improved targeting strategy
- Control group: comparable accounts continuing with the existing targeting strategy
- Primary outcome: incremental successful recovery per eligible account
- Secondary outcomes: recovery per agent-hour, contact rate, PTP rate and cost per ₹ recovered
- Randomization or carefully matched controls should be used to reduce selection bias.

The ₹10 Cr investment should be scaled only if the experiment demonstrates a statistically and economically meaningful incremental recovery.

---

# 6. Analytical Methodology

The analytical workflow follows:

```text
Raw Data
   ↓
Staging
   ↓
Clean
   ↓
Golden Dataset
   ↓
Feature Analysis
   ↓
Metrics
   ↓
Executive Dashboard
