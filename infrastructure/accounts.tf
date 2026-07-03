# -------------------------------------------------- #
# ------ AWS Customer Accounts (Julmo Sport)  ------ #
# -------------------------------------------------- #
resource "aws_organizations_organizational_unit" "customers_julmosport" {
  name      = "julmosport"
  parent_id = aws_organizations_organizational_unit.customers.id
}

resource "aws_organizations_account" "julmosport_web_prod" {
  name      = "julmosport-web-prod"
  email     = var.julmosport_account_email
  parent_id = aws_organizations_organizational_unit.customers_julmosport.id
}
