# Setting Up Grafana Access

## Quick Access (Recommended)

### Option 1: Local Port-Forward (Development)
```bash
# Run this script for easy access
./scripts/access-grafana.sh

# Or manually:
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```
Then visit: http://localhost:3000

### Option 2: LoadBalancer (CI/CD Friendly)
Updated `kubernetes/grafana-service.yaml` to use `type: LoadBalancer`

Get the external IP:
```bash
kubectl get svc -n grafana grafana-service

# Look for EXTERNAL-IP, then visit:
# http://<EXTERNAL-IP>:3000
```

## CI/CD Integration

### Can't Use Port-Forward in CI/CD ❌
Port-forward won't work in GitHub Actions because:
- It's a long-running process
- CI/CD jobs are ephemeral
- No persistence after job ends

### Solution: Use LoadBalancer ✅
The updated service now uses `LoadBalancer` which:
- Gets a public IP automatically
- Works with CI/CD pipelines
- Accessible from anywhere

### Access from CI/CD
The CI/CD workflow will deploy Grafana and show you the LoadBalancer URL in the logs.

## Manual Access

### 1. Check Grafana Status
```bash
kubectl get pods -n grafana
kubectl get svc -n grafana
```

### 2. Port-Forward Locally
```bash
# Simple way
./scripts/access-grafana.sh

# Or manually
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```

### 3. Access Dashboard
- URL: http://localhost:3000 (or LoadBalancer IP)
- Username: `admin`
- Password: `admin`

## Grafana in CDN App

The frontend now includes a Grafana page (`grafana.html`) that:
- Loads Grafana via iframe
- Shows when port-forward is running
- Provides helpful instructions if not

Access it at: **https://your-cdn-url.cloudfront.net/grafana.html**

## Troubleshooting

### "Connection Refused"
1. Make sure Grafana pod is running:
   ```bash
   kubectl get pods -n grafana
   ```
2. Check service is created:
   ```bash
   kubectl get svc -n grafana
   ```
3. Start port-forward:
   ```bash
   kubectl port-forward -n grafana svc/grafana-service 3000:3000
   ```

### LoadBalancer Has No IP
This is normal for local minikube. LoadBalancer requires a cloud provider.
- Use port-forward instead for local development
- Use an actual Kubernetes cluster (EKS, GKE) for LoadBalancer in production

### Can't Access from Browser
1. Make sure port-forward is running in a terminal
2. Try http://localhost:3000 directly
3. Check firewall settings
4. Clear browser cache

## Next Steps

1. Configure CloudWatch data source in Grafana
2. Import the Lambda monitoring dashboard
3. Set up alerts for errors/latency
4. Create custom dashboards for your needs

For detailed setup instructions, see: `docs/grafana/ACCESS_GRAFANA.md`

