# import boto3
# import logging
# import json

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# def lambda_handler(event, context):
#     """
#     Enroll an existing account in AWS Control Tower
    
#     Expected event structure:
#     {
#         "account_id": "123456789012",
#         "contact_email": "example@example.com",
#         "ou_id": "ou-xxxx-xxxxxxxx"
#     }
#     """
    
#     try:
#         controltower_client = boto3.client('controltower')
#         organizations_client = boto3.client('organizations')
        
#         # Get account and OU details
#         try:
#             account_response = organizations_client.describe_account(
#                 AccountId=event['account_id']
#             )
#             account_name = account_response['Account']['Name']
#             account_email = account_response['Account']['Email']
            
#             ou_response = organizations_client.describe_organizational_unit(
#                 OrganizationalUnitId=event['ou_id']
#             )
#             ou_name = ou_response['OrganizationalUnit']['Name']
            
#             logger.info(f"Processing account: {account_name} ({event['account_id']}) in OU: {ou_name}")
            
#         except Exception as e:
#             logger.error(f"Failed to describe account or OU: {e}")
#             return {
#                 "status": "error",
#                 "details": f"Failed to describe account or OU: {str(e)}",
#                 "account_id": event["account_id"]
#             }
        
#         # Check if account is already managed by Control Tower
#         try:
#             managed_accounts = controltower_client.list_managed_accounts()
#             for managed_account in managed_accounts.get('Accounts', []):
#                 if managed_account.get('AccountId') == event['account_id']:
#                     logger.info(f"Account {account_name} is already managed by Control Tower")
#                     return {
#                         "status": "success",
#                         "details": f"Account {account_name} is already managed by Control Tower",
#                         "account_id": event["account_id"]
#                     }
#         except Exception as e:
#             logger.warning(f"Could not check managed accounts: {e}")
        
#         # Try to enroll the account using the Control Tower API
#         try:
#             logger.info(f"Attempting to enroll account {account_name} in Control Tower...")
            
#             # Use the contact email from the event, or fall back to the account's email
#             contact_email = event.get('contact_email', account_email)
            
#             response = controltower_client.enroll_account(
#                 AccountId=event['account_id'],
#                 EmailAddress=contact_email,
#                 OrganizationalUnitId=event['ou_id']
#             )
            
#             logger.info(f"Successfully enrolled account {account_name}")
#             logger.info(f"Enrollment response: {json.dumps(response, default=str)}")
            
#             return {
#                 "status": "success",
#                 "details": f"Account {account_name} enrolled successfully",
#                 "account_id": event["account_id"],
#                 "response": response
#             }
            
#         except controltower_client.exceptions.ConflictException as e:
#             logger.info(f"Account {account_name} is already enrolled: {e}")
#             return {
#                 "status": "success",
#                 "details": f"Account {account_name} is already enrolled",
#                 "account_id": event["account_id"]
#             }
            
#         except controltower_client.exceptions.ValidationException as e:
#             logger.error(f"Validation error for account {account_name}: {e}")
#             return {
#                 "status": "error",
#                 "details": f"Validation error: {str(e)}",
#                 "account_id": event["account_id"]
#             }
            
#         except Exception as e:
#             logger.error(f"Failed to enroll account {account_name}: {e}")
#             return {
#                 "status": "error",
#                 "details": f"Failed to enroll account: {str(e)}",
#                 "account_id": event["account_id"]
#             }
        
#     except Exception as e:
#         logger.error(f"Unexpected error: {e}")
#         return {
#             "status": "error",
#             "details": f"Unexpected error: {str(e)}",
#             "account_id": event["account_id"]
#         }

import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Enroll an existing account in AWS Control Tower using available APIs
    
    Expected event structure:
    {
        "account_id": "123456789012",
        "contact_email": "example@example.com",
        "ou_id": "ou-xxxx-xxxxxxxx"
    }
    """
    
    try:
        controltower_client = boto3.client('controltower')
        organizations_client = boto3.client('organizations')
        servicecatalog_client = boto3.client('servicecatalog')
        
        # Get account and OU details
        try:
            account_response = organizations_client.describe_account(
                AccountId=event['account_id']
            )
            account_name = account_response['Account']['Name']
            account_email = account_response['Account']['Email']
            
            ou_response = organizations_client.describe_organizational_unit(
                OrganizationalUnitId=event['ou_id']
            )
            ou_name = ou_response['OrganizationalUnit']['Name']
            
            logger.info(f"Processing account: {account_name} ({event['account_id']}) in OU: {ou_name}")
            
        except Exception as e:
            logger.error(f"Failed to describe account or OU: {e}")
            return {
                "status": "error",
                "details": f"Failed to describe account or OU: {str(e)}",
                "account_id": event["account_id"]
            }
        
        # Check available Control Tower methods
        available_methods = dir(controltower_client)
        logger.info(f"Available Control Tower methods: {[m for m in available_methods if not m.startswith('_')]}")
        
        # Method 1: Try using enable_baseline for account (newer API)
        try:
            logger.info(f"Trying enable_baseline for account {account_name}...")
            
            # Check if baseline is already enabled
            try:
                baseline_response = controltower_client.get_enabled_baseline(
                    baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_BASELINE_SERVICE_V1_0_0",
                    targetIdentifier=event['account_id']
                )
                logger.info(f"Baseline already enabled for account {account_name}")
                return {
                    "status": "success",
                    "details": f"Account {account_name} already has baseline enabled",
                    "account_id": event["account_id"]
                }
            except controltower_client.exceptions.ResourceNotFoundException:
                # Baseline not enabled, proceed to enable it
                pass
            except Exception as e:
                logger.warning(f"Could not check baseline status: {e}")
            
            # Enable the baseline
            response = controltower_client.enable_baseline(
                baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_BASELINE_SERVICE_V1_0_0",
                baselineVersion="1.0",
                targetIdentifier=event['account_id']
            )
            
            logger.info(f"Successfully enabled baseline for account {account_name}")
            logger.info(f"Response: {json.dumps(response, default=str)}")
            
            return {
                "status": "success",
                "details": f"Baseline enabled for account {account_name}",
                "account_id": event["account_id"],
                "operation_identifier": response.get('operationIdentifier')
            }
            
        except Exception as e:
            logger.warning(f"enable_baseline failed: {e}")
        
        # Method 2: Try legacy enroll_account if available
        if hasattr(controltower_client, 'enroll_account'):
            try:
                logger.info(f"Trying enroll_account for account {account_name}...")
                contact_email = event.get('contact_email', account_email)
                
                response = controltower_client.enroll_account(
                    AccountId=event['account_id'],
                    EmailAddress=contact_email,
                    OrganizationalUnitId=event['ou_id']
                )
                
                logger.info(f"Successfully enrolled account {account_name}")
                logger.info(f"Response: {json.dumps(response, default=str)}")
                
                return {
                    "status": "success",
                    "details": f"Account {account_name} enrolled successfully",
                    "account_id": event["account_id"]
                }
                
            except Exception as e:
                logger.warning(f"enroll_account failed: {e}")
        
        # Method 3: Try Service Catalog approach (Account Factory)
        try:
            logger.info(f"Trying Service Catalog approach for account {account_name}...")
            
            # Get Control Tower Account Factory Portfolio
            portfolios = servicecatalog_client.list_portfolios()
            control_tower_portfolio = None
            
            for portfolio in portfolios.get('PortfolioDetails', []):
                if 'Control Tower' in portfolio.get('DisplayName', ''):
                    control_tower_portfolio = portfolio
                    break
            
            if control_tower_portfolio:
                logger.info(f"Found Control Tower portfolio: {control_tower_portfolio}")
                
                # This approach requires more complex implementation
                # For now, we'll indicate that manual action is needed
                
                return {
                    "status": "manual_action_required",
                    "details": f"Account {account_name} enrollment requires manual action through Service Catalog or AWS Console",
                    "account_id": event["account_id"]
                }
            else:
                logger.warning("Control Tower Account Factory portfolio not found")
                
        except Exception as e:
            logger.warning(f"Service Catalog approach failed: {e}")
        
        # Method 4: Check if account is already managed
        try:
            logger.info("Checking if account is already managed by Control Tower...")
            managed_accounts = controltower_client.list_managed_accounts()
            
            for managed_account in managed_accounts.get('Accounts', []):
                if managed_account.get('AccountId') == event['account_id']:
                    logger.info(f"Account {account_name} is already managed by Control Tower")
                    return {
                        "status": "success",
                        "details": f"Account {account_name} is already managed by Control Tower",
                        "account_id": event["account_id"]
                    }
            
            logger.warning(f"Account {account_name} is not managed by Control Tower and enrollment failed")
            return {
                "status": "manual_action_required",
                "details": f"Account {account_name} needs to be enrolled manually through the AWS Console",
                "account_id": event["account_id"]
            }
            
        except Exception as e:
            logger.error(f"Could not check managed accounts: {e}")
        
        # If all methods fail
        return {
            "status": "error",
            "details": f"All enrollment methods failed for account {account_name}. Manual enrollment required.",
            "account_id": event["account_id"]
        }
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            "status": "error",
            "details": f"Unexpected error: {str(e)}",
            "account_id": event["account_id"]
        }