# import boto3
# import logging
# import json

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# def lambda_handler(event, context):
#     """
#     Register an OU with AWS Control Tower
    
#     Expected event structure:
#     {
#         "ou_id": "ou-xxxx-xxxxxxxx"
#     }
#     """
    
#     try:
#         # First, check if Control Tower is available and set up
#         controltower_client = boto3.client('controltower')
#         organizations_client = boto3.client('organizations')
        
#         # Get OU details
#         try:
#             ou_response = organizations_client.describe_organizational_unit(
#                 OrganizationalUnitId=event['ou_id']
#             )
#             ou_name = ou_response['OrganizationalUnit']['Name']
#             logger.info(f"Processing OU: {ou_name} ({event['ou_id']})")
#         except Exception as e:
#             logger.error(f"Failed to describe OU {event['ou_id']}: {e}")
#             return {
#                 "status": "error",
#                 "details": f"Failed to describe OU: {str(e)}",
#                 "ou_id": event["ou_id"]
#             }
        
#         # Check if OU is already registered
#         try:
#             # Try to get OU registration status
#             response = controltower_client.get_enabled_baseline(
#                 baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_IDENTITY_CENTER_V1_0_0",
#                 targetIdentifier=event['ou_id']
#             )
#             logger.info(f"OU {ou_name} is already registered with Control Tower")
#             return {
#                 "status": "success",
#                 "details": f"OU {ou_name} is already registered",
#                 "ou_id": event["ou_id"]
#             }
#         except controltower_client.exceptions.ResourceNotFoundException:
#             # OU is not registered, proceed with registration
#             logger.info(f"OU {ou_name} is not registered, proceeding with registration")
#             pass
#         except Exception as e:
#             logger.warning(f"Could not check OU registration status: {e}")
        
#         # Register the OU with Control Tower using the new API
#         try:
#             response = controltower_client.enable_baseline(
#                 baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_IDENTITY_CENTER_V1_0_0",
#                 baselineVersion="1.0",
#                 targetIdentifier=event['ou_id']
#             )
            
#             logger.info(f"Successfully initiated OU registration for {ou_name}")
#             logger.info(f"Registration response: {json.dumps(response, default=str)}")
            
#             return {
#                 "status": "success",
#                 "details": f"OU registration initiated for {ou_name}",
#                 "operation_identifier": response.get('operationIdentifier'),
#                 "ou_id": event["ou_id"]
#             }
            
#         except Exception as e:
#             logger.error(f"Failed to register OU {ou_name}: {e}")
            
#             # If the new API doesn't work, fall back to the legacy API
#             try:
#                 logger.info("Trying legacy Control Tower API...")
#                 response = controltower_client.register_organizational_unit(
#                     OrganizationalUnitId=event['ou_id']
#                 )
                
#                 logger.info(f"Legacy API response: {json.dumps(response, default=str)}")
#                 return {
#                     "status": "success",
#                     "details": f"OU {ou_name} registered using legacy API",
#                     "ou_id": event["ou_id"]
#                 }
                
#             except Exception as legacy_error:
#                 logger.error(f"Legacy API also failed: {legacy_error}")
#                 return {
#                     "status": "error",
#                     "details": f"Both new and legacy APIs failed. New API: {str(e)}, Legacy API: {str(legacy_error)}",
#                     "ou_id": event["ou_id"]
#                 }
        
#     except Exception as e:
#         logger.error(f"Unexpected error registering OU: {e}")
#         return {
#             "status": "error",
#             "details": str(e),
#             "ou_id": event["ou_id"]
#         }


import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Register an OU with AWS Control Tower using available APIs
    
    Expected event structure:
    {
        "ou_id": "ou-xxxx-xxxxxxxx"
    }
    """
    
    try:
        controltower_client = boto3.client('controltower')
        organizations_client = boto3.client('organizations')
        
        # Get OU details
        try:
            ou_response = organizations_client.describe_organizational_unit(
                OrganizationalUnitId=event['ou_id']
            )
            ou_name = ou_response['OrganizationalUnit']['Name']
            logger.info(f"Processing OU: {ou_name} ({event['ou_id']})")
        except Exception as e:
            logger.error(f"Failed to describe OU {event['ou_id']}: {e}")
            return {
                "status": "error",
                "details": f"Failed to describe OU: {str(e)}",
                "ou_id": event["ou_id"]
            }
        
        # Check available Control Tower methods
        available_methods = dir(controltower_client)
        logger.info(f"Available Control Tower methods: {[m for m in available_methods if not m.startswith('_')]}")
        
        # Try different approaches to register the OU
        
        # Method 1: Try using enable_baseline (newer API)
        try:
            logger.info(f"Trying enable_baseline for OU {ou_name}...")
            
            # Check if baseline is already enabled
            try:
                baseline_response = controltower_client.get_enabled_baseline(
                    baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_IDENTITY_CENTER_V1_0_0",
                    targetIdentifier=event['ou_id']
                )
                logger.info(f"Baseline already enabled for OU {ou_name}")
                return {
                    "status": "success",
                    "details": f"OU {ou_name} already has baseline enabled",
                    "ou_id": event["ou_id"]
                }
            except controltower_client.exceptions.ResourceNotFoundException:
                # Baseline not enabled, proceed to enable it
                pass
            except Exception as e:
                logger.warning(f"Could not check baseline status: {e}")
            
            # Enable the baseline
            response = controltower_client.enable_baseline(
                baselineIdentifier="arn:aws:controltower:::baseline/AWSControlTowerBP_IDENTITY_CENTER_V1_0_0",
                baselineVersion="1.0",
                targetIdentifier=event['ou_id']
            )
            
            logger.info(f"Successfully enabled baseline for OU {ou_name}")
            logger.info(f"Response: {json.dumps(response, default=str)}")
            
            return {
                "status": "success",
                "details": f"Baseline enabled for OU {ou_name}",
                "ou_id": event["ou_id"],
                "operation_identifier": response.get('operationIdentifier')
            }
            
        except Exception as e:
            logger.warning(f"enable_baseline failed: {e}")
        
        # Method 2: Try legacy register_organizational_unit if available
        if hasattr(controltower_client, 'register_organizational_unit'):
            try:
                logger.info(f"Trying register_organizational_unit for OU {ou_name}...")
                response = controltower_client.register_organizational_unit(
                    OrganizationalUnitId=event['ou_id']
                )
                
                logger.info(f"Successfully registered OU {ou_name}")
                logger.info(f"Response: {json.dumps(response, default=str)}")
                
                return {
                    "status": "success",
                    "details": f"OU {ou_name} registered successfully",
                    "ou_id": event["ou_id"]
                }
                
            except Exception as e:
                logger.warning(f"register_organizational_unit failed: {e}")
        
        # Method 3: Check if OU is already managed
        try:
            logger.info("Checking if OU is already managed by Control Tower...")
            managed_ous = controltower_client.list_managed_organizational_units()
            
            for managed_ou in managed_ous.get('OrganizationalUnits', []):
                if managed_ou.get('OrganizationalUnitId') == event['ou_id']:
                    logger.info(f"OU {ou_name} is already managed by Control Tower")
                    return {
                        "status": "success",
                        "details": f"OU {ou_name} is already managed by Control Tower",
                        "ou_id": event["ou_id"]
                    }
            
            logger.warning(f"OU {ou_name} is not managed by Control Tower and registration failed")
            return {
                "status": "manual_action_required",
                "details": f"OU {ou_name} needs to be registered manually through the AWS Console",
                "ou_id": event["ou_id"]
            }
            
        except Exception as e:
            logger.error(f"Could not check managed OUs: {e}")
        
        # If all methods fail
        return {
            "status": "error",
            "details": f"All registration methods failed for OU {ou_name}. Manual registration required.",
            "ou_id": event["ou_id"]
        }
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            "status": "error",
            "details": f"Unexpected error: {str(e)}",
            "ou_id": event["ou_id"]
        }