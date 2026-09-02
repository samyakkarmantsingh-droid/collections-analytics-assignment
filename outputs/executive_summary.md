# Collections Analytics — Executive Summary

## Executive conclusion

The reported 11% month-on-month improvement in recovery is not supported by the payment transaction data.

After removing exact duplicate records and retaining one record per payment ID, successful recovery declined from ₹18.72 Cr in January 2026 to ₹4.71 Cr in August 2026, representing a 74.84% decline from the first to the last observed month.

Average monthly recovery growth was -10.44%, while median monthly growth was -4.72%.

## Data-quality findings

- 500 payment IDs appear more than once.
- These repeated payment IDs create approximately ₹2.59 Cr of excess successful-payment value.
- Approximately 99.9% of comparable event-level borrower IDs conflict with the borrower associated with the account master.
- `account_id` is therefore used as the primary event linkage key.
- 50.32% of account-status records have `recorded_at` earlier than `event_at`.
- Original event and recording timestamps are retained separately.
- Campaign IDs did not show conflicting campaign definitions in the campaign master.

## Driver findings

Recovery is broadly distributed across loan types and risk segments, with no single category explaining the decline.

Payment-method recovery also declines broadly, rather than showing a problem isolated to one payment method.

Call volumes remain relatively stable while successful recovery declines substantially. This suggests that simply increasing collection activity is unlikely to be sufficient.

## ₹10 Cr Recommendation

### Recommendation: Better Borrower Targeting

The ₹10 Cr investment should be deployed toward a better borrower-targeting and prioritization system rather than simply increasing collection activity.

The analysis does not provide sufficient causal evidence to claim that targeting alone will generate a specific recovery uplift. Therefore, the financial estimate below is an investment case based on explicit assumptions, not a measured causal result.

### Financial case

Observed successful recovery over January-August 2026 was approximately ₹131.56 Cr.

Assuming the targeting intervention produces a 5%-8% incremental recovery uplift:

- Expected incremental recovery: approximately ₹6.58-₹10.53 Cr over the observed-period equivalent.
- Base case: 6.5% uplift = approximately ₹8.55 Cr incremental recovery.
- Investment: ₹10 Cr.
- Base-case ROI: approximately -14.5% on the observed-period basis.

Because the dataset covers only eight observed months for this recovery calculation, a full-year financial return should not be presented as a measured result.

### Break-even

At the observed-period recovery base, the intervention would need approximately a 7.60% incremental recovery uplift to recover the full ₹10 Cr investment.

This is above the central 6.5% assumption, so the investment should not be treated as guaranteed to pay back from the current evidence.

### Key assumptions

1. The targeting system can identify accounts with materially different recovery propensity.
2. Treatment capacity can be redirected toward higher-value/high-propensity accounts.
3. Incremental recovery is measured against a randomized or controlled comparison group.
4. The ₹10 Cr investment represents the full intervention cost.
5. Recovery attribution is performed at the account level using the cleaned payment data.

### Downside scenario

Under a 2% incremental recovery uplift, incremental recovery would be approximately ₹2.63 Cr, resulting in a substantial negative return.

Therefore, the investment should be released through controlled pilots and scale-up gates rather than assuming the full expected uplift.

### Confidence

Confidence in the diagnosis of declining recovery is high.

Confidence that better targeting will produce the estimated financial uplift is low-to-moderate because the available data is observational and does not establish causal impact.

A randomized controlled pilot should be used before full-scale deployment.