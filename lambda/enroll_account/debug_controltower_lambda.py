import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Debug Control Tower setup and perform operations
    
    Expected event structure:
    {
        "action": "debug" or "register_ou" or "enroll_account",
        "ou_id": "ou-xxxx-xxxxxxxx",
        "account_id": "123456789012",  # Only for enroll_account
        "email": "example@example.com"  # Only for enroll_account
    }
    """
    sc_client = boto3.client('servicecatalog', region_name='us-east-1')
    org_client = boto3.client('organizations')
    
    try:
        # List Service Catalog portfolios
        portfolios = sc_client.list_portfolios()
        logger.info(f"Available portfolios: {json.dumps(portfolios, default=str)}")
        
        # Find Control Tower portfolio
        ct_portfolio = next((p for p in portfolios['PortfolioDetails'] if p['DisplayName'] == 'AWS Control Tower Account Factory Portfolio'), None)
        if not ct_portfolio:
            raise Exception("Control Tower portfolio not found")
        
        # List products in the Control Tower portfolio
        products = sc_client.search_products_as_admin(PortfolioId=ct_portfolio['Id'])
        logger.info(f"Products in Control Tower portfolio: {json.dumps(products, default=str)}")
        
        # Find Account Factory product
        account_factory = next((p for p in products['ProductViewDetails'] if p['ProductViewSummary']['Name'] == 'AWS Control Tower Account Factory'), None)
        if not account_factory:
            raise Exception("Account Factory product not found")
        
        # Get product details
        product_details = sc_client.describe_product(Id=account_factory['ProductViewSummary']['ProductId'])
        logger.info(f"Account Factory product details: {json.dumps(product_details, default=str)}")
        
        try:
            # Get launch paths for Account Factory
            launch_paths = sc_client.list_launch_paths(ProductId=account_factory['ProductViewSummary']['ProductId'])
            logger.info(f"Launch paths for Account Factory: {json.dumps(launch_paths, default=str)}")
        except Exception as e:
            logger.error(f"Error getting launch paths: {str(e)}")
            launch_paths = {"LaunchPathSummaries": []}
        
        if not launch_paths['LaunchPathSummaries']:
            logger.warning("No launch paths found for Account Factory")
        
        # Get provisioning artifacts
        artifacts = sc_client.list_provisioning_artifacts(ProductId=account_factory['ProductViewSummary']['ProductId'])
        logger.info(f"Provisioning artifacts: {json.dumps(artifacts, default=str)}")
        
        if not artifacts['ProvisioningArtifactDetails']:
            raise Exception("No provisioning artifacts found for Account Factory")
        
        latest_artifact = artifacts['ProvisioningArtifactDetails'][0]
        
        if event['action'] == 'debug':
            return {
                "status": "success",
                "details": {
                    "portfolios": portfolios,
                    "ct_portfolio": ct_portfolio,
                    "products": products,
                    "account_factory": account_factory,
                    "product_details": product_details,
                    "launch_paths": launch_paths,
                    "artifacts": artifacts
                }
            }
        
        # Perform action based on event
        if event['action'] == 'register_ou':
            ou_details = org_client.describe_organizational_unit(OrganizationalUnitId=event['ou_id'])
            ou_name = ou_details['OrganizationalUnit']['Name']
            
            response = sc_client.provision_product(
                ProductId=account_factory['ProductViewSummary']['ProductId'],
                ProvisioningArtifactId=latest_artifact['Id'],
                ProvisionedProductName=f"Register-OU-{ou_name}",
                ProvisioningParameters=[
                    {'Key': 'AccountName', 'Value': f"CT-Management-{ou_name}"},
                    {'Key': 'ManagedOrganizationalUnit', 'Value': ou_name},
                    {'Key': 'AccountEmail', 'Value': f"noreply+{ou_name.lower()}@example.com"}
                ],
                PathId=launch_paths['LaunchPathSummaries'][0]['Id'] if launch_paths['LaunchPathSummaries'] else None
            )
            logger.info(f"Register OU response: {json.dumps(response, default=str)}")
            
        elif event['action'] == 'enroll_account':
            ou_details = org_client.describe_organizational_unit(OrganizationalUnitId=event['ou_id'])
            ou_name = ou_details['OrganizationalUnit']['Name']
            
            response = sc_client.provision_product(
                ProductId=account_factory['ProductViewSummary']['ProductId'],
                ProvisioningArtifactId=latest_artifact['Id'],
                ProvisionedProductName=f"Enroll-Account-{event['account_id']}",
                ProvisioningParameters=[
                    {'Key': 'AccountName', 'Value': f"Enrolled-Account-{event['account_id']}"},
                    {'Key': 'AccountEmail', 'Value': event['email']},
                    {'Key': 'ManagedOrganizationalUnit', 'Value': ou_name},
                    {'Key': 'SSOUserFirstName', 'Value': 'Control'},
                    {'Key': 'SSOUserLastName', 'Value': 'Tower'},
                    {'Key': 'SSOUserEmail', 'Value': event['email']}
                ],
                PathId=launch_paths['LaunchPathSummaries'][0]['Id'] if launch_paths['LaunchPathSummaries'] else None
            )
            logger.info(f"Enroll account response: {json.dumps(response, default=str)}")
        
        else:
            raise ValueError(f"Invalid action: {event['action']}")
        
        return {
            "status": "success",
            "details": json.dumps(response, default=str)
        }
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            "status": "error",
            "details": str(e)
        }
