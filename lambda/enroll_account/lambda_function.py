import boto3

def lambda_handler(event, context):
    client = boto3.client('controltower')
    try:
        response = client._make_api_call(
            'EnrollAccount',
            {
                "AccountId": event["account_id"],
                "ContactEmail": event["contact_email"],
                "ManagedOrganizationalUnitId": event["ou_id"]
            }
        )
        print(f"EnrollAccount response: {response}")
        return {"status": "success", "details": response}
    except Exception as e:
        print(f"Error enrolling account: {e}")
        return {"status": "error", "details": str(e)}
