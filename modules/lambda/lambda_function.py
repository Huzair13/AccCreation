import boto3

def lambda_handler(event, context):
    controltower = boto3.client('controltower')
    account_id = event['account_id']
    contact_email = event['contact_email']
    ou_id = event['ou_id']
    try:
        response = controltower.enroll_account(
            AccountId=account_id,
            ContactEmail=contact_email,
            ManagedOrganizationalUnitId=ou_id
        )
        print(f"EnrollAccount response: {response}")
        return {"status": "success", "details": response}
    except Exception as e:
        print(f"Error enrolling account: {e}")
        return {"status": "error", "details": str(e)}
