
# Setup Documentation

## 1. Install Terraform
To install Terraform, we recommend using `tfenv`, a Terraform version manager available at [tfenv GitHub repository](https://github.com/tfutils/tfenv).
Use the following commands to install and set up Terraform:
```bash
TFENV_ARCH=amd64 tfenv install 1.9.4
tfenv use 1.9.4
```

## 2. Create AWS User for Terraform
In the AWS Management Console, create a new IAM user named `terraform-access`.
Assign the `AdministratorAccess` policy to this user.
Ensure that this user has only programmatic access and no AWS console access.
Generate and download the Access Key ID and Secret Access Key for this user.

## 3. Setup AWS CLI
Install the AWS CLI on a Debian-based system using the following commands:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Configure the AWS CLI using the following command:
```bash
aws configure --profile terraform
```

When prompted, enter the Access Key ID and Secret Access Key you downloaded earlier.
Set the default region and output format according to your preferences.

## 4. Create S3 Bucket for Terraform Backend
In the AWS Management Console, create an S3 bucket named `terraform-backend-eks`.
This bucket will be used to store Terraform state files.

## 5. Prepare Terraform Directory
Unzip the `eks-terraform.zip` and enter the `terraform` directory.

## 6. Generate SSH Key Pair
Execute the script `gen_private_public_key.sh` to generate a key pair for logging into the bastion host. The keys will be stored in the `files` directory.

## 7. Set Environment Variables
Set the following environment variables to pass the AWS credentials as Terraform variables:
```bash
export TF_VAR_aws_access_key_id=<AWS_ACCESS_KEY_ID>
export TF_VAR_aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
```

Replace `<AWS_ACCESS_KEY_ID>` with the value of your Access Key ID.
Replace `<AWS_SECRET_ACCESS_KEY>` with the value of your Secret Access Key.
These variables are required during remote-exec for Terraform.

## 8. Initialize Terraform
Run the following command to initialize Terraform:
```bash
terraform init
```

## 9. Apply Terraform Configuration
Run the following command to apply the Terraform configuration:
```bash
terraform apply
```

## 10. Retrieve Bastion Host Public Address
Once the Terraform apply process is complete, it will output the public address of the bastion host. Keep this address handy for accessing the bastion host.
