# Access Grafana Dashboard

## Quick Start

Grafana is now embedded in your CDN! Access it at:
**https://d3fkfd08m7hmoz.cloudfront.net/grafana.html**

## Setup Steps

### 1. Port Forward (Required First Time)
```bash
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```

### 2. Access via CDN
1. Go to your CDN: https://d3fkfd08m7hmoz.cloudfront.net
2. Click "📊 View Grafana Dashboard" button
3. Or directly: https://d3fkfd08m7hmoz.cloudfront.net/grafana.html

### 3. Login to Grafana
- Username: `admin`
- Password: `admin`

## What's New?

### ✅ Grafana is Integrated
- Separate page in your CDN app (`grafana.html`)
- Embedded via iframe when accessible
- Shows error message with instructions if Grafana is down

### ✅ Easy Access
- Click "📊 View Grafana Dashboard" from main app
- Full-screen Grafana interface
- Navigation back to main app

### ✅ Auto-Detection
- Checks if Grafana is running
- Shows helpful error message if not
- Provides exact command to run

## Troubleshooting

### Issue: "Grafana Not Accessible" Message

**Solution**: Run port-forward command:
```bash
kubectl port-forward -n grafana svc/grafana-service 3000:3000
```

Keep this terminal open while using Grafana.

### Issue: Can't Access Grafana in CDN

**Check**:
1. Is the port-forward command running?
2. Are you accessing http://localhost:3000 directly?
3. Does kubectl show the service?

```bash
# Check service status
kubectl get svc -n grafana

# Check pod status  
kubectl get pods -n grafana

# Restart if needed
kubectl delete pod -n grafana -l app=grafana
```

### Issue: Grafana Shows "Access Denied"

**Try**:
1. Use incognito/private browsing
2. Clear browser cache
3. Check Grafana logs: `kubectl logs -n grafana -l app=grafana`

## Permanent Setup (Optional)

For production, you might want to:
1. Expose Grafana via Ingress/LoadBalancer
2. Add authentication (OAuth, SAML)
3. Set up data persistence
4. Configure custom datasources

## Current Architecture

```
CDN (CloudFront)
  └── grafana.html → iframe → localhost:3000
                              ↑
                              kubectl port-forward
                              ↑
                              Kubernetes
                              └── Grafana Pod
```

## Quick Commands

```bash
# Start Grafana access
kubectl port-forward -n grafana svc/grafana-service 3000:3000

# Check Grafana pods
kubectl get pods -n grafana

# View Grafana logs
kubectl logs -n grafana -l app=grafana -f

# Restart Grafana
kubectl rollout restart deployment/grafana -n grafana
```

## Note

The Grafana iframe in the CDN expects `localhost:3000` to be accessible. This is because:
- Browser security prevents embedding remote Grafana instances directly
- Port-forward provides local access to the Kubernetes service
- The iframe can then load `localhost:3000` when port-forward is active

For a truly remote solution, you'd need to:
1. Expose Grafana via LoadBalancer or Ingress
2. Configure proper authentication
3. Update the iframe URL to the exposed endpoint

