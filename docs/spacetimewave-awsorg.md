# Spacetimewave AWS Organization

This document describes the AWS Organization structure managed by this repository, and how to operate it: logging into accounts, and onboarding a new client or a new internal/external product.

All resources described here are provisioned with OpenTofu from the `infrastructure/` folder and applied automatically by the `infrastructure.pipeline` GitHub Action on every merge to `main` that touches `infrastructure/**`.

## Structure

```
Root (management account)
├─ Workloads (OU)                 → infrastructure/org.tf
│   ├─ external (OU)               spacetimewave-owned products sold externally
│   └─ internal (OU)               internal tools / products
└─ customers (OU)                 → infrastructure/org.tf
    └─ julmosport (OU)             → infrastructure/accounts.tf
        └─ julmosport-web-prod (account)
```

- **Root / management account**: named `spacetimewave`. It's the AWS account the pipeline's OIDC role runs in, it owns the AWS Organization itself (`aws_organizations_organization.this` in `infrastructure/org.tf`), and is where billing and root-level SCPs live.
- **Workloads OU**: holds spacetimewave-owned products, split into `external` (customer-facing products) and `internal` (internal tooling) sub-OUs. No accounts exist under these yet — add them the same way client accounts are added below.
- **Customers OU**: holds one sub-OU per client. Each client sub-OU holds client's AWS account(s).
- **Security** and **Shared Services** OUs (audit/log-archive, network hub, CI/CD tooling, observability) shown in the diagram above are not implemented yet — planned for later.

Every OU and account inherits any Service Control Policies (SCPs) attached at the Root. None are attached yet.

## Logging in to an account

### Management (root) account

Sign in normally at https://signin.aws.amazon.com/ with your existing IAM user/role, or as root using `root_account_email` (see `prod.tfvars`) if you ever need the actual root user (billing, closing accounts, etc.).

### A member account (e.g. a client account like `julmosport-web-prod`)

Prefer switching roles from the management account over using that account's root user — root should be reserved for actions that require it (e.g. closing the account).

1. Sign in to the **management account** console as usual.
2. Click the account name (top-right) → **Switch role**.
3. Enter:
   - **Account ID**: the member account's ID (`tofu output` — see [Outputs](#outputs) — or the Organizations console).
   - **Role name**: `OrganizationAccountAccessRole` (created automatically by AWS for every account created via Organizations).
4. You land in the member account with admin access, no root password involved.

If you do need the member account's root user (first-time setup, MFA, etc.):

1. Go to https://signin.aws.amazon.com/, choose **Root user**, and enter the account's root email (the `*_account_email` value used when the account was created).
2. New accounts created via Organizations have no root password yet — click **Forgot password?** to trigger a reset email to that same root address, then set a password from the link.
3. Sign in as root and set up MFA immediately; avoid using root for day-to-day work.

## Adding a new client (OU + account)

This is the exact pattern used for Julmosport (`infrastructure/accounts.tf`). To onboard a new client, e.g. `acme`:

1. Add an OU for the client under `customers`, and an account under that OU, in `infrastructure/accounts.tf` (or a new file if you'd rather keep one file per client):

   ```hcl
   resource "aws_organizations_organizational_unit" "customers_acme" {
     name      = "acme"
     parent_id = aws_organizations_organizational_unit.customers.id
   }

   resource "aws_organizations_account" "acme_web_prod" {
     name      = "acme-web-prod"
     email     = var.acme_account_email
     parent_id = aws_organizations_organizational_unit.customers_acme.id
   }
   ```

   Account naming convention: `<client>-<workload>-<env>` (e.g. `julmosport-web-prod`). Add more accounts under the same client OU for other workloads/environments (e.g. `acme-web-dev`, `acme-api-prod`) as needed.

2. Declare the required email variable in `infrastructure/variables.tf`:

   ```hcl
   variable "acme_account_email" {
     description = "Root-user email for acme AWS accounts. Must be globally unique across all AWS accounts."
   }
   ```

3. Set a real, unique value in `infrastructure/prod.tfvars`. A `+` alias off an existing mailbox works (AWS treats it as a distinct address):

   ```hcl
   acme_account_email = "you+acme@example.com"
   ```

4. Open a PR. The pipeline will run `tofu plan` on the PR — review it before merging, since merging to `main` auto-applies:

   ```
   + aws_organizations_organizational_unit.customers_acme
   + aws_organizations_account.acme_web_prod
   ```

5. Merge to `main`. The pipeline applies automatically and creates the OU and the AWS account. AWS sends a welcome email to the root email address you set in step 3 — see [Logging in to an account](#logging-in-to-an-account) to access it.

## Adding a new internal/external product account

Same pattern, but under `workloads_external` or `workloads_internal` (defined in `infrastructure/org.tf`) instead of a client OU:

```hcl
resource "aws_organizations_account" "myproduct_prod" {
  name      = "myproduct-prod"
  email     = var.myproduct_account_email
  parent_id = aws_organizations_organizational_unit.workloads_external.id # or .workloads_internal.id
}
```

Follow the same variable/tfvars/PR steps as above.

## Deploying infrastructure into an account

This repository only manages the AWS Organization, OUs, and accounts themselves — it does not deploy workloads *into* those accounts. Once an account exists (see above), the actual infrastructure for that account (e.g. `julmosport-web-prod`) is typically managed from its own separate OpenTofu project/repository, using credentials scoped to that account.

At a high level, that project follows the same pattern as this one: OpenTofu provider/backend config, per-environment `.tfvars` files, and an `init` → `plan` → `apply` workflow, optionally automated by a pipeline. See [`otf.md`](./otf.md) for detailed step-by-step instructions to follow when setting one up (prerequisites, local vs. remote state, plan/apply/destroy).

## Outputs

`infrastructure/outputs.tf` exposes the OU and root IDs (`organization_root_id`, `workloads_ou_id`, `workloads_external_ou_id`, `workloads_internal_ou_id`, `customers_ou_id`). Account and client-OU-specific IDs aren't output by default — look them up via the AWS Organizations console, or add an output for them following the existing pattern if you need to reference them elsewhere.

## Caveats

- **Enabling the Organization is effectively one-way.** The management account can't easily stop being a management account — that requires AWS Support involvement, not a normal `tofu destroy`.
- **AWS accounts can't be cleanly destroyed via OpenTofu.** Removing an `aws_organizations_account` resource (or `tofu destroy`) does not delete the AWS account; accounts must be closed manually in the console, and AWS caps how many accounts you can close per rolling 12 months. Treat every account creation as a durable decision.
- **The pipeline auto-applies on merge to `main`.** Always review the `tofu plan` output on the PR before merging changes under `infrastructure/`.