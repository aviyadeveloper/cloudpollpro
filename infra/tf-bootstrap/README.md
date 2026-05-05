# Terraform Bootstrap - CloudPollPro

One-time setup to create AWS foundation for the CloudPollPro project.

## What it creates

- **IAM Role**: `cloudpollpro-terraform-role` (with assume role policy)
- **S3 Bucket**: Terraform state storage with encryption
- **DynamoDB Table**: State locking
- **Auto-generates**: 
  - `../terraform/backend.tf` (S3 backend with role assumption)
  - `../terraform/provider.tf` (AWS provider with role assumption)
  - `../terraform/README-SETUP.md` (Usage instructions)

## Security Advantages

✅ **No static access keys** - uses temporary credentials via AssumeRole  
✅ **No secrets in state files** - role ARNs are public information  
✅ **Auto-rotating credentials** - temporary credentials expire automatically  
✅ **Better audit trail** - CloudTrail shows both your identity and assumed role  
✅ **Instant revocation** - modify role trust policy to revoke access

## Usage

```bash
# Run once with admin credentials
terraform init
terraform apply

# Switch to main project
cd ../terraform

# Review the generated setup instructions
cat README-SETUP.md

# Verify role assumption works
aws sts assume-role \
  --role-arn $(cd ../tf-bootstrap && terraform output -raw role_arn) \
  --role-session-name test \
  --external-id cloudpollpro

# Proceed with main project (role is assumed automatically)
terraform init
terraform plan
terraform apply
```

## How Role Assumption Works

1. **You authenticate** with your admin AWS credentials
2. **Terraform calls** `sts:AssumeRole` to get temporary credentials
3. **AWS returns** temporary credentials (valid ~12 hours)
4. **All operations** use these temporary credentials
5. **Credentials expire** automatically, no rotation needed

## Important

- Bootstrap state stays **local** - backup `terraform.tfstate`
- Only run this once per AWS account
- Use admin credentials here, role assumption everywhere else
- Main project MUST USE THE SAME REGION as bootstrap
- **Your admin user must have `sts:AssumeRole` permission**

## Monitoring Role Usage (Optional)

Track what actions are performed through the assumed role:

```bash
# View AssumeRole events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --max-results 50

# View all actions performed by the role
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=cloudpollpro-terraform-role \
  --max-results 100
```

Or use AWS Console:
- **CloudTrail** → Event history → Filter by role name
- Shows both who assumed the role AND what actions were performed
