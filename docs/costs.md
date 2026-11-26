# Cost and budget guidance

This project does not deploy automatically. A manual apply creates billable AWS resources; review current AWS pricing for your account and region before proceeding.

The main variable costs are CloudFront data transfer and requests, S3 storage and requests, and any tax or data transfer charges. CloudFront is limited to `PriceClass_100` to use the lower-cost North America and Europe edge locations, and the sample site is intentionally small. An idle environment can still incur charges, and AWS prices and free-tier eligibility vary.

The security scan records two deliberate demo tradeoffs in `.trivyignore`: there is no AWS WAF because its recurring charges are disproportionate for this static sample, and the bucket uses SSE-S3 rather than a customer-managed KMS key because the site content is public. Reassess both decisions before adapting this baseline to sensitive content or a higher-risk production site.

An optional AWS Cost Budget can be enabled with `enable_budget = true`, a positive `monthly_budget_limit`, and `budget_notification_email`. The deployment workflow exposes corresponding `TF_ENABLE_BUDGET`, `TF_MONTHLY_BUDGET_LIMIT`, and `TF_BUDGET_NOTIFICATION_EMAIL` variables. It sends notifications at 80% actual spend and 100% forecasted spend. Budgets are alerts, not a spending cap: they are delayed, do not stop resources, and do not guarantee that charges stay under the threshold. Verify email subscriptions and consider account-level AWS Budgets in addition to this stack's alert.

For cost control:

- Start with a reviewed `plan`, deploy only when needed, and run `destroy` promptly after experiments.
- Inspect the S3 bucket and CloudFront distribution after teardown; retain the separate Terraform state bucket deliberately.
- Monitor AWS billing and Cost Explorer, and set account-level alerts appropriate to your account.
- Do not treat a successful Terraform destroy as proof that all account charges have stopped; check for remaining resources and usage.
