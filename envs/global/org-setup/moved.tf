moved {
  from = aws_servicecatalog_provisioned_product.new_accounts["0"]
  to   = module.service_catalog_accounts[0].aws_servicecatalog_provisioned_product.new_accounts[0]
}

moved {
  from = aws_servicecatalog_provisioned_product.new_accounts["1"]
  to   = module.service_catalog_accounts[0].aws_servicecatalog_provisioned_product.new_accounts[1]
}

moved {
  from = aws_servicecatalog_provisioned_product.new_accounts["2"]
  to   = module.service_catalog_accounts[0].aws_servicecatalog_provisioned_product.new_accounts[2]
}
