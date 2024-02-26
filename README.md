# WordPress Installation on AWS EC2 using Terraform

This repository contains Terraform configurations to set up an AWS instance as a WordPress site.

## Setup Instructions

### Prerequisites

- Git installed on your machine
- Terraform CLI installed ([Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- AWS account with necessary permissions

### Steps

1. Clone the repository:

   ```bash
   git clone <repository_url>
   cd <cloned_directory>
   ```

2. Create a `terraform.tfvars` file with the following variables:

   ```hcl
   access_key
   secret_key
   aws_region
   name_prefix
   devops_tag
   project_tag
   env_tag
   ami_id
   instance_type
   key_pair
   hosted_zone_name
   zone_id
   certificate_arn
   docker_image_tag
   mysql_database
   mysql_user
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Apply Terraform configurations:

   ```bash
   terraform apply -auto-approve
   ```

5. Once Terraform applies the changes successfully, it will output the address of the EC2 instance. Access WordPress by navigating to `https://<hosted_zone_name>/` in your web browser.

6. Follow the on-screen instructions to complete the WordPress installation process. You might need to provide database details, admin credentials, and site configuration.

## Notes

- Ensure your AWS credentials (`access_key` and `secret_key`) have necessary permissions for creating resources.
- The `terraform.tfvars` file holds sensitive information. Keep it secure and never commit it to version control.
- For more detailed configuration or modifications, refer to the Terraform configuration files (`*.tf`) in this repository.
