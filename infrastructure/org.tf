# -------------------------------------------------- #
# --------------- AWS Organization  ---------------- #
# -------------------------------------------------- #
resource "aws_organizations_organization" "this" {
}

# -------------------------------------------------- #
# ----- AWS Organizational Units (Workloads)  ------ #
# -------------------------------------------------- #
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "workloads"
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads_external" {
  name      = "external"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "workloads_internal" {
  name      = "internal"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# -------------------------------------------------- #
# ----- AWS Organizational Units (Customers)  ------ #
# -------------------------------------------------- #
resource "aws_organizations_organizational_unit" "customers" {
  name      = "customers"
  parent_id = aws_organizations_organization.this.roots[0].id
}

