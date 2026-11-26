# Setup, deployment, and teardown

Provisioning is optional and is never run by pull requests or pushes. The workflow is manually dispatched and uses GitHub's OIDC provider to assume an AWS role for a short-lived session. Do not create or store long-lived AWS access keys in GitHub.

## Prerequisites

1. An AWS account with permissions to create the dedicated deployment role, an S3 state bucket, and the project's resources.
2. A globally unique S3 bucket name for the site, within S3's naming rules.
3. GitHub Actions enabled for this repository.

The Terraform backend uses S3 native state locking (`use_lockfile`). Create the state bucket separately before the first run, in the region you will configure. Enable bucket versioning and server-side encryption, block all public access, and restrict access to the deployment role and administrators. The state bucket is not created or deleted by this Terraform project.

## Configure GitHub OIDC in AWS

Register `https://token.actions.githubusercontent.com` as an IAM OIDC provider in the AWS account if it is not already present. The provider audience must include `sts.amazonaws.com`.

Create a dedicated IAM role trusted by that provider. Restrict its trust policy to the audience `sts.amazonaws.com` and the exact subject:

```text
repo:JordanANgeloERASMUS/cloud-environment-provisioner:environment:production
```

The subject is tied to the `production` GitHub environment. Give the role only the permissions needed to manage this stack (S3 bucket and objects/policy, CloudFront distribution/OAC/response headers policy, and AWS Budgets if enabled), plus read access to discover those resources and access to the state bucket. Some AWS create/list APIs require `"Resource": "*"`, so constrain by actions and conditions where AWS supports them. Do not grant unrelated account-wide administrator access. The workflow does not bootstrap the OIDC provider, role, or state bucket.

## Configure GitHub

In **Settings → Environments**, create `production`. Add required reviewers and restrict deployment branches/tags to the intended protected branch before using `apply` or `destroy`.

Add these repository or environment **Variables**:

| Name | Example | Purpose |
| --- | --- | --- |
| `AWS_REGION` | `us-east-1` | AWS provider and deployment region |
| `TF_STATE_BUCKET` | `my-company-terraform-state` | Pre-created private state bucket |
| `TF_STATE_KEY` | `cloud-environment-provisioner/production.tfstate` | State object path |
| `TF_STATE_REGION` | `us-east-1` | Region containing the state bucket |
| `TF_SITE_BUCKET_NAME` | `myname-static-site-2026` | Globally unique private site bucket |
| `TF_PROJECT_NAME` | `cloud-environment-provisioner` | Project tag/name prefix |
| `TF_ENABLE_BUDGET` | `false` | Set to `true` to create budget alerts |
| `TF_MONTHLY_BUDGET_LIMIT` | `5` | Monthly threshold in USD when enabled |
| `TF_BUDGET_NOTIFICATION_EMAIL` | `you@example.com` | Required and verified when budget is enabled |

Add `AWS_ROLE_ARN` as an **Environment secret** containing the deployment role ARN. If `TF_ENABLE_BUDGET` is `true`, AWS Budgets emails may require subscription confirmation.

## Deploy

1. Run **Actions → Provision AWS environment → Run workflow** and select `plan`.
2. Review the workflow log and Terraform plan. A plan reads AWS state but does not apply changes.
3. Dispatch the workflow again with `apply` only after reviewing and accepting the plan. Environment protection rules should require approval.

The `plan` operation is preview-only. An `apply` run creates a fresh plan and applies it immediately after the protected environment approves the job; it does not reuse an earlier plan, which may have become stale. Terraform state and lock files are held in the configured S3 backend. Output values are available in the Terraform run log; the site URL is the `site_url` output.

## Teardown

1. Dispatch the workflow with `destroy` and approve it through the `production` environment. Review the run before confirming.
2. Check AWS for any remaining stack resources. CloudFront deletion may take several minutes.
3. The state bucket is intentionally retained. Keep it and its state version history until you have confirmed the environment is gone; delete it separately only if it is dedicated to this project and you no longer need the state.

The S3 site bucket is configured with `force_destroy = false`. Terraform removes the site objects it manages during destroy, but any unexpected/unmanaged objects will prevent bucket deletion. Inspect and remove only those objects you intend to delete, then retry. Never delete a shared state bucket as part of this stack's teardown.

## Local checks

`./scripts/validate.sh` runs Terraform formatting and validation without AWS credentials. For local plans or applies, configure AWS credentials using your organization's approved short-lived authentication method and use the same remote backend. Do not put credentials in `.tf` files or commit Terraform state.
