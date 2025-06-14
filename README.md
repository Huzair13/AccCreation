# AWS Landing Zone

This project implements a secure and scalable AWS Landing Zone using Terraform. It sets up a multi-account structure with centralized networking, security controls, and shared services.

## Structure

- `backend/`: Contains the S3 backend configuration for Terraform state.
- `modules/`: Reusable Terraform modules for different components of the landing zone.
  - `organizations/`: AWS Organizations and OUs setup
  - `scps/`: Service Control Policies
  - `vpc/`: VPC configuration
- `envs/`: Environment-specific Terraform configurations.
  - `global/`: Global resources (org setup, IAM)
  - `shared-services/`: Shared services configuration
  - `production/`, `dev/`, `sandbox/`: Environment-specific configurations (to be implemented)
- `scripts/`: Utility scripts for deployment and management (to be implemented).
- `docs/`: Project documentation (to be implemented).

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform v0.14+
- An S3 bucket for Terraform state storage
- A DynamoDB table for state locking

## Getting Started

1. Update the S3 backend configuration in `backend/s3_backend.tf` with your bucket and DynamoDB table names.

2. Review and customize the modules in the `modules/` directory as needed.

3. Set up your `terraform.tfvars` file in the `envs/global/org-setup/` directory. Example:

   ```hcl
   aws_region = "us-west-2"
   shared_services_vpc_cidr = "10.0.0.0/16"
   shared_services_public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
   shared_services_private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
   availability_zones = ["us-west-2a", "us-west-2b"]
   tags = {
     Environment = "shared"
     Project     = "AWS Landing Zone"
   }
   ```

4. Deploy the global resources:

   ```sh
   cd envs/global/org-setup
   terraform init
   terraform plan
   terraform apply
   ```

5. Review the outputs and ensure all resources are created as expected.

## Dynamic Account Creation

This project now supports dynamic creation of multiple accounts using AWS Service Catalog, Terraform, and GitLab CI/CD pipelines. The process is triggered automatically when you update the account details. Here's how it works:

1. Update the `account_details.json` file in the root directory with the desired account information:

   ```json
   {
     "accounts": [
       {
         "AccountName": "your-new-account-name-1",
         "AccountEmail": "account-email-1@example.com"
       },
       {
         "AccountName": "your-new-account-name-2",
         "AccountEmail": "account-email-2@example.com"
       }
     ],
     "ManagedOrganizationalUnit": "SharedServices",
     "AccountRegion": "us-east-1"
   }
   ```

   You can add as many accounts as needed in the `accounts` array.

2. Commit and push the updated `account_details.json` file to your GitLab repository.

3. The GitLab CI/CD pipeline will automatically detect the changes to `account_details.json` and trigger the account creation process.

4. The pipeline will:
   - Validate the JSON file
   - Use Terraform to create new AWS Service Catalog provisioned products for each account
   - Provision the new accounts using the AWS Control Tower Account Factory product
   - Monitor the provisioning process until completion

5. You can monitor the pipeline execution in the GitLab CI/CD interface. The job will provide status updates during the account provisioning process.

6. Once the pipeline job completes successfully, the new accounts will be created and added to the specified Organizational Unit in your AWS Organization.

This automated process allows you to create multiple new accounts simply by updating the `account_details.json` file and pushing the changes to your repository. There's no need to manually trigger any jobs.

Note: 
- All new accounts will be added to the Organizational Unit specified in the `ManagedOrganizationalUnit` field.
- The SSO user's first name for each account will be derived from the email address (part before the @ symbol).
- The SSO user's last name will be set to "User" by default for all accounts.
- The `AccountRegion` specified will be used for all new accounts.
- Ensure that your GitLab CI/CD environment has the necessary AWS credentials and permissions to interact with AWS Service Catalog and provision new accounts.

## Modules

### Organizations

Sets up the AWS Organization, creates Organizational Units (OUs) for Production, Development, and Sandbox, and a Shared Services account.

### Service Control Policies (SCPs)

Implements basic SCPs to enforce security best practices:
- Deny ability to leave the organization
- Require MFA for all actions
- Restrict allowed AWS regions

### VPC

Creates a flexible VPC setup with public and private subnets, NAT Gateway, and VPC Flow Logs.

## Security Features

- Multi-account structure for isolation
- Service Control Policies for account-level guardrails
- VPC Flow Logs for network traffic analysis
- Centralized logging (to be implemented)

## Next Steps

1. Implement additional modules (e.g., IAM, CloudTrail, AWS Config)
2. Set up environment-specific configurations (Production, Development, Sandbox)
3. Implement centralized logging and monitoring
4. Set up CI/CD pipeline for automated deployments

## Contributing

Guidelines for contributing to this project to be added.

## License

Specify your license here.

## Troubleshooting

### GitLab CI/CD: "No space left on device" Error

If you encounter a "no space left on device" error in your GitLab CI/CD pipeline, particularly when the runner is trying to create a Docker volume for caching, this indicates a problem with the GitLab runner's host machine. Since this error occurs during the preparation phase, before any job-specific scripts run, it needs to be addressed at the runner level.

Here are the steps that your GitLab administrator or DevOps team should take:

1. **Check and increase available disk space**: 
   - On the GitLab runner's host machine, use the `df -h` command to check available disk space.
   - Look for the filesystem that contains `/var/lib/docker` and ensure it has sufficient free space.
   - If necessary, increase the disk space allocated to this filesystem or the entire host machine.

2. **Clean up Docker resources on the host machine**:
   - SSH into the GitLab runner's host machine.
   - Run `docker system prune -af --volumes` to remove all unused Docker resources.
   - **Caution**: Ensure this doesn't interfere with other projects using the same runner.

3. **Optimize GitLab Runner configuration**:
   - Edit the GitLab Runner configuration file (usually located at `/etc/gitlab-runner/config.toml`).
   - Add or modify the `cleanup_policy` in the `[runners.docker]` section:
     ```toml
     [runners.docker]
       cleanup_policy = "always"
     ```
   - This ensures Docker cleanup happens after every job.

4. **Implement periodic cleanup**:
   - Set up a cron job on the host machine to periodically clean up Docker resources.
   - For example, add this line to the root crontab to run cleanup daily:
     ```
     0 1 * * * docker system prune -af --volumes
     ```

5. **Consider runner-specific options**:
   - Use the `pull_policy` option in the runner configuration to control how images are pulled.
   - Set `pull_policy = "if-not-present"` to avoid unnecessary image downloads.

6. **Monitor and alert**:
   - Implement monitoring on the GitLab runner's host machine to alert when disk space is running low.
   - This allows proactive management of resources before jobs fail.

If these steps don't resolve the issue, consider:
- Upgrading to a larger instance or adding more disk space to the existing instance.
- Distributing jobs across multiple runners to reduce load on any single machine.
- Reviewing and optimizing the projects running on this runner to reduce their disk space usage.

Remember, these changes need to be implemented by someone with administrative access to the GitLab runner's host machine. If you don't have this access, please forward these instructions to your DevOps team or GitLab administrator.
