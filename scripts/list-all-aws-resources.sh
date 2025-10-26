#!/bin/bash

set -e

echo "🔍 Listing ALL AWS resources in your account..."
echo "This will help identify orphaned resources"
echo ""

echo "=== LAMBDA FUNCTIONS ==="
aws lambda list-functions --query 'Functions[*].[FunctionName,LastModified,CodeSize]' --output table 2>/dev/null || echo "No Lambda functions found"

echo ""
echo "=== S3 BUCKETS ==="
aws s3api list-buckets --query 'Buckets[*].[Name,CreationDate]' --output table 2>/dev/null || echo "No S3 buckets found"

echo ""
echo "=== DYNAMODB TABLES ==="
aws dynamodb list-tables --output json | jq -r '.TableNames[]' 2>/dev/null || echo "No DynamoDB tables found"

echo ""
echo "=== CLOUDFRONT DISTRIBUTIONS ==="
aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,Comment,Status,Enabled]' --output table 2>/dev/null || echo "No CloudFront distributions found"

echo ""
echo "=== API GATEWAY ==="
aws apigateway get-rest-apis --query 'items[*].[name,id]' --output table 2>/dev/null || echo "No API Gateway APIs found"

echo ""
echo "=== IAM ROLES (Lambda execution roles) ==="
aws iam list-roles --query 'Roles[?contains(RoleName, `lambda`) || contains(RoleName, `pkb`) || contains(RoleName, `budget`)].RoleName' --output text 2>/dev/null || echo "No IAM roles found"

echo ""
echo "=== IAM USERS ==="
aws iam list-users --query 'Users[?contains(UserName, `pkb`) || contains(UserName, `grafana`)].UserName' --output text 2>/dev/null || echo "No related IAM users found"

echo ""
echo "=== IAM POLICIES ==="
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `pkb`) || contains(PolicyName, `grafana`)].PolicyName' --output text 2>/dev/null || echo "No related IAM policies found"

echo ""
echo "=== CLOUDWATCH LOG GROUPS (for Lambda) ==="
aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `/aws/lambda`)].logGroupName' --output text | head -20 2>/dev/null || echo "No CloudWatch log groups found"

echo ""
echo "=== ELASTIC IPs (if using EC2) ==="
aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,AllocationId,AssociationId]' --output table 2>/dev/null || echo "No Elastic IPs found (or permissions missing)"

echo ""
echo "=== EC2 INSTANCES ==="
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,LaunchTime]' --output table 2>/dev/null || echo "No EC2 instances found (or permissions missing)"

echo ""
echo "✅ Resource check complete!"
echo ""
echo "⚠️  If you see resources that don't belong to this project, you may want to delete them."
echo "⚠️  The resources listed above related to 'pkb', 'budget', or 'grafana' are part of this project."
echo "⚠️  Other resources may be from other projects or experiments."

