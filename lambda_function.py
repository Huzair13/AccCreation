# import json
# import boto3
# import cfnresponse

# def lambda_handler(event, context):
#     org_client = boto3.client('organizations')
#     try:
#         if event['RequestType'] == 'Create':
#             response = org_client.create_organizational_unit(
#                 ParentId=event['ResourceProperties']['ParentId'],
#                 Name=event['ResourceProperties']['OUName']
#             )
#             ou_id = response['OrganizationalUnit']['Id']
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {'OUId': ou_id}, ou_id)
#         elif event['RequestType'] == 'Delete':
#             ou_id = event['PhysicalResourceId']
#             org_client.delete_organizational_unit(OrganizationalUnitId=ou_id)
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
#         elif event['RequestType'] == 'Update':
#             # Optional: implement rename/move logic
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
#     except Exception as e:
#         cfnresponse.send(event, context, cfnresponse.FAILED, {'Message': str(e)})


# import json
# import boto3
# import cfnresponse
# import time

# def lambda_handler(event, context):
#     org_client = boto3.client('organizations')
#     ct_client = boto3.client('controltower')

#     try:
#         if event['RequestType'] == 'Create':
#             # Step 1: Create the OU in Organizations
#             ou = org_client.create_organizational_unit(
#                 ParentId=event['ResourceProperties']['ParentId'],
#                 Name=event['ResourceProperties']['OUName']
#             )
#             ou_id = ou['OrganizationalUnit']['Id']

#             # Step 2: Register the OU with Control Tower
#             reg = ct_client.register_organizational_unit(
#                 OrganizationalUnitId=ou_id
#             )
#             reg_id = reg['OrganizationalUnitRegistration']['OrganizationalUnitRegistrationId']

#             # Step 3: Wait for registration to complete (polling)
#             status = "IN_PROGRESS"
#             for _ in range(30):  # Poll up to 5 minutes (10s x 30)
#                 resp = ct_client.describe_organizational_unit_registration(
#                     OrganizationalUnitRegistrationId=reg_id
#                 )
#                 status = resp['OrganizationalUnitRegistration']['Status']
#                 if status == "SUCCEEDED":
#                     break
#                 elif status == "FAILED":
#                     reason = resp['OrganizationalUnitRegistration']['StatusReason']
#                     raise Exception(f"Control Tower OU registration failed: {reason}")
#                 time.sleep(10)
#             if status != "SUCCEEDED":
#                 raise Exception("OU registration timed out")

#             # Respond success with OU ID
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {'OUId': ou_id}, ou_id)

#         elif event['RequestType'] == 'Delete':
#             ou_id = event['PhysicalResourceId']
#             # (Optional: Deregister from Control Tower before delete, if needed)
#             org_client.delete_organizational_unit(OrganizationalUnitId=ou_id)
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
#         elif event['RequestType'] == 'Update':
#             # Implement if you want to allow renames/moves
#             cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
#     except Exception as e:
#         print(f"Error: {e}")
#         cfnresponse.send(event, context, cfnresponse.FAILED, {'Message': str(e)})



import json
import boto3
import cfnresponse
import time
import re

def lambda_handler(event, context):
    org_client = boto3.client('organizations')
    ct_client = boto3.client('controltower')
    try:
        if event['RequestType'] == 'Create':
            parent_id = event['ResourceProperties']['ParentId']
            ou_name = event['ResourceProperties']['OUName']

            # Check if OU exists under parent
            paginator = org_client.get_paginator('list_organizational_units_for_parent')
            ou_id = None
            for page in paginator.paginate(ParentId=parent_id):
                for ou in page['OrganizationalUnits']:
                    if ou['Name'] == ou_name:
                        ou_id = ou['Id']
                        break
                if ou_id:
                    break

            # If not exists, create OU
            if not ou_id:
                ou_response = org_client.create_organizational_unit(
                    ParentId=parent_id,
                    Name=ou_name
                )
                ou_id = ou_response['OrganizationalUnit']['Id']

            # Describe OU to get its ARN
            ou_desc = org_client.describe_organizational_unit(
                OrganizationalUnitId=ou_id
            )
            ou_arn = ou_desc['OrganizationalUnit']['Arn']

            # List baselines to find AWSControlTowerBaseline
            baselines = ct_client.list_baselines()
            ct_baseline = next(
                b for b in baselines['baselines']
                if b['name'] == 'AWSControlTowerBaseline'
            )
            baseline_arn = ct_baseline['arn']
            baseline_version = ct_baseline['latestVersion']

            # Enable the baseline on the OU
            enable_response = ct_client.enable_baseline(
                baselineIdentifier=baseline_arn,
                baselineVersion=baseline_version,
                targetIdentifier=ou_arn
            )
            operation_id = enable_response['operationIdentifier']

            # Wait for operation to complete
            for _ in range(36):  # 6 minutes
                op_status = ct_client.get_baseline_operation(
                    operationIdentifier=operation_id
                )
                status = op_status['status']
                if status in ['SUCCEEDED', 'FAILED']:
                    break
                time.sleep(10)

            if status == 'SUCCEEDED':
                cfnresponse.send(event, context, cfnresponse.SUCCESS, {'OUId': ou_id}, ou_id)
            else:
                reason = op_status.get('statusMessage', 'Baseline enable operation failed.')
                cfnresponse.send(event, context, cfnresponse.FAILED, {'Message': reason}, ou_id)

        elif event['RequestType'] == 'Delete':
            ou_id = event['PhysicalResourceId']
            # Only delete if the OU ID is in the correct format
            if re.match(r"^ou-[a-z0-9]{4,}-[a-z0-9]{8,32}$", ou_id):
                org_client.delete_organizational_unit(OrganizationalUnitId=ou_id)
            cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, ou_id)

        elif event['RequestType'] == 'Update':
            cfnresponse.send(event, context, cfnresponse.SUCCESS, {})

    except Exception as e:
        print(f"Error: {e}")
        cfnresponse.send(event, context, cfnresponse.FAILED, {'Message': str(e)}, event.get('PhysicalResourceId'))