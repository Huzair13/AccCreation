import json
import os
import requests

GITLAB_URL = os.environ['https://gitlab.com/api/v4/projects/5132/trigger/pipeline']
GITLAB_TOKEN = os.environ['glptt-e18f4d811c5cbae25bde0a07010c1c40ef4d5fcc']

def lambda_handler(event, context):
    print(json.dumps(event))

    account_id = event['detail']['serviceEventDetails']['createManagedAccountStatus']['account']['accountId']
    
    data = {
        "token": GITLAB_TOKEN,
        "ref": "main",
        "variables[NEW_ACCOUNT_ID]": account_id
    }

    response = requests.post(GITLAB_URL, data=data)
    
    return {
        "statusCode": response.status_code,
        "body": response.text
    }
