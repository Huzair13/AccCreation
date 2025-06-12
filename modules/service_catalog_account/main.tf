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
    value = var.new_accounts[count.index].ManagedOrganizationalUnit
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

resource "aws_ssm_parameter" "account_configs" {
  name  = "/ram/configuration"
  type  = "String"
  value = jsonencode({
    for i, product in aws_servicecatalog_provisioned_product.new_accounts : 
    [for output in product.outputs : output.value if output.key == "AccountId"][0] => {
      share_tgw = var.new_accounts[i].share_tgw
      share_subnets = var.new_accounts[i].share_subnets
    }
  })
  description = "Account configurations for TGW and subnet sharing"
}
