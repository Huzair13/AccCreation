resource "aws_servicecatalog_provisioned_product" "new_accounts" {
  count                      = length(var.new_accounts)
  name                       = var.new_accounts[count.index].AccountName
  product_id                 = var.product_id
  provisioning_artifact_name = var.provisioning_artifact_name

  provisioning_parameters {
    key   = "AccountEmail"
    value = var.new_accounts[count.index].AccountEmail
  }
  provisioning_parameters {
    key   = "AccountName"
    value = var.new_accounts[count.index].AccountName
  }
  provisioning_parameters {
    key   = "SSOUserEmail"
    value = var.new_accounts[count.index].AccountEmail
  }
  provisioning_parameters {
    key   = "SSOUserFirstName"
    value = split("@", var.new_accounts[count.index].AccountEmail)[0]
  }
  provisioning_parameters {
    key   = "SSOUserLastName"
    value = "User"
  }
  provisioning_parameters {
    key   = "ManagedOrganizationalUnit"
    value = var.managed_organizational_unit
  }
  provisioning_parameters {
    key   = "AccountRegion"
    value = var.account_region
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
