# Collections Analytics — Data Quality Report

## 1. Purpose

The raw collections data contains duplicates, missing values, conflicting timestamps, inconsistent identifiers, multiple time zones, duplicate payment events and changing historical records.

The objective of this report is to identify the major data-quality problems, explain how they were detected and treated, and quantify their impact on recovery analysis.

---

## 2. Data Quality Summary

| Issue | Detection | Finding | Treatment | Business Impact |
|---|---|---|---|---|
| Duplicate payments | Duplicate payment_id count | 500 duplicate payment IDs and 500 extra records | Keep one record per payment_id using latest event_at | Prevents recovery overstatement |
| Payment recovery inflation | Compare raw vs deduplicated successful payments | Duplicate records contributed approximately ₹2.59 Cr excess successful recovery | Use deduplicated payments | Material impact on reported recovery |
| Missing borrower IDs | Null count by dataset | Missing borrower IDs exist in several event datasets | Retain raw value and use account master for analytical identity where possible | Prevents unreliable borrower-level joins |
| Borrower identity mismatch | Compare event borrower_id with account borrower_id | Very high mismatch rate in several event tables | Treat account_id → borrower_id mapping as analytical source of truth | Prevents incorrect attribution |
| Agent identity instability | Group agent records by agent_id | 1,000 agent IDs show multiple employee/name/vendor/team details | Retain agent_id but flag unstable attributes | Agent performance comparisons may be unreliable |
| Timestamp conflicts | Compare event_at and recorded_at | 30,191 of 60,000 status-history records have recorded_at earlier than event_at (50.32%) | Retain both timestamps; do not blindly reconstruct history | Historical status analysis can be misleading |
| Multiple time zones | Frequency check across datasets | UTC, Asia/Kolkata and Asia/Dubai are present | Preserve timezone information | Hour/day operational comparisons require normalization |
| Duplicate rows in event tables | Row-level duplicate checks | Duplicates exist in calls, WhatsApp events and payments | Deduplicate where a reliable event key exists | Prevents inflated activity metrics |
| Partial-period data | Monthly event coverage | August 2026 is incomplete relative to earlier months | Exclude August from full-month trend comparisons | Prevents false deterioration |

---

## 3. Payment Deduplication

The payment table contains:

- Raw payment rows: 25,500
- Exact duplicate rows: 486
- Duplicate payment IDs: 500
- Extra records caused by repeated payment IDs: 500
- Final unique payment rows: 25,000

The analytical recovery definition is:

> Recovery = successful payment amount after payment-level deduplication.

For repeated `payment_id` values, the latest `event_at` record is retained.

This prevents repeated ingestion/event records from being counted as separate recoveries.

The estimated excess successful recovery associated with duplicate payment IDs is approximately:

**₹2.59 Cr**

This is material enough that raw payment sums should not be used for executive recovery reporting.

---

## 4. Borrower Identity

The same borrower identifier is not consistently reliable across event tables.

For analytical purposes, the account master provides the canonical relationship:

`account_id → borrower_id`

Event-level borrower IDs are retained for audit purposes but should not automatically override the account-level relationship.

Where event borrower_id conflicts with the account master, the record is flagged rather than silently corrected.

### Decision

Use the account-level borrower relationship as the analytical source of truth.

---

## 5. Agent Identity

The agent master contains 30,000 rows and 1,000 distinct agent IDs.

The same agent_id can be associated with multiple:

- employee codes
- names
- vendors
- teams

Therefore, agent-level historical performance should not assume that the current agent attributes represent the agent throughout the entire period.

### Decision

Use `agent_id` as the operational identifier while treating employee/name/vendor/team attributes as time-sensitive dimensions.

---

## 6. Timestamp and Timezone Issues

The data contains multiple time zones:

- UTC
- Asia/Kolkata
- Asia/Dubai

This creates a risk when comparing activity by:

- hour
- day
- month
- agent shift
- calling time

Timestamp fields should therefore be preserved with their timezone context before deriving operational time features.

### Status History Issue

There are 60,000 status-history records.

30,191 records have:

`recorded_at < event_at`

This represents approximately:

**50.32%**

of status-history records.

### Decision

Both `event_at` and `recorded_at` are retained.

The latest recorded status should not automatically be treated as the true historical state because the timestamps themselves contain inconsistencies.

---

## 7. Missing Data

Missing values occur in several datasets, including borrowers, accounts, payments, calls and other event tables.

Missing identifiers are not replaced with fabricated values.

Treatment depends on the field:

- Missing analytical keys → exclude from joins requiring that key
- Missing descriptive attributes → retain as NULL
- Missing optional event attributes → retain where the event itself remains usable
- Missing payment status/amount → do not treat the record as successful recovery

The objective is to avoid converting missing information into artificial evidence.

---

## 8. Duplicate and Event-Level Issues

The raw data intentionally contains duplicate and inconsistent event records.

Important examples include:

- duplicate payment IDs
- duplicate payment events
- duplicate call/event records
- repeated WhatsApp events
- multiple agent identifiers
- inconsistent campaign definitions

The cleaning process therefore uses a reproducible rule rather than manually deleting records.

Where a stable event identifier exists, it is used for deduplication.

---

## 9. Partial Month Treatment

The available recovery data runs from January 2026 through August 2026.

August is not a complete comparable month.

Therefore:

- January–July are used for full-month trend analysis.
- August is retained for monitoring/current-period visibility.
- August is excluded from first-to-last full-month performance comparisons.

This prevents a partial month from being incorrectly interpreted as a sharp operational decline.

---

## 10. Impact on Recovery Analysis

Before cleaning, the payment data contained repeated payment IDs that could inflate successful recovery.

After deduplication:

- Unique payment records = 25,000
- Successful payments = 17,534
- Failed payments = 3,677
- Pending payments = 2,535
- Reversed payments = 1,254

The cleaned successful recovery is approximately:

**₹131.56 Cr**

Total outstanding amount is approximately:

**₹104.89 Cr**

Therefore:

**Recovery / Outstanding = 12.54%**

The duplicate-payment issue alone represents approximately:

**₹2.59 Cr**

of excess recovery if repeated payment IDs are counted more than once.

---

## 11. Business Implications

The data-quality issues are not merely technical problems.

They can directly affect:

1. Reported recovery
2. Month-on-month growth
3. Agent performance
4. Channel performance
5. Campaign attribution
6. Borrower-level conversion metrics
7. Recovery-rate denominators
8. Executive investment decisions

The most important issue is that operational conclusions should be made only after the underlying event data has been cleaned and reconciled.

---

## 12. Overall Assessment

### High-confidence findings

- Duplicate payment IDs exist.
- Duplicate payment records materially affect recovery.
- Status-history timestamps contain major inconsistencies.
- Multiple time zones are present.
- Agent attributes are unstable over time.
- August is a partial period and should not be treated as a full month.

### Medium-confidence findings

- Operational activity may explain part of recovery movement.
- Portfolio and activity mix may influence observed recovery changes.

### Low-confidence findings

- Specific channel or campaign causal impact.
- Precise ROI from a ₹10 Cr investment using the current observational data.

A controlled experiment and reliable cost data are required before claiming a causal channel-level ROI.

---

## 13. Golden Dataset Principle

The final analytical layer follows:

Raw Records
→ Rejected / Corrected
→ Golden Dataset

The golden dataset uses:

- canonical account identity
- deduplicated payment events
- explicit exclusion rules
- preserved audit fields
- documented assumptions

The goal is not to make the data look cleaner artificially, but to make analytical decisions reproducible and auditable.