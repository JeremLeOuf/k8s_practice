# 🎯 Access Grafana

## Current Setup
Grafana is running in Kubernetes and accessible via port-forward.

## Access URL
**http://localhost:3000**

## Default Credentials
- Username: `admin`  
- Password: `admin`

## If Password Doesn't Work

### Option 1: Reset Password
```bash
kubectl exec -n grafana deployment/grafana -- grafana-cli admin reset-admin-password admin
```

### Option 2: Check Pod Status
```bash
kubectl get pods -n grafana
kubectl logs -n grafana deployment/grafana | tail -20
```

### Option 3: Restart the Pod
```bash
kubectl rollout restart deployment/grafana -n grafana
```

## Port Forward
Already running! Access at http://localhost:3000

If port-forward stops:
```bash
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```

## Dashboard Setup
Once logged in:
1. Go to Configuration → Data Sources
2. Add CloudWatch data source
3. Configure with your AWS credentials
4. Start monitoring your Lambda functions!

