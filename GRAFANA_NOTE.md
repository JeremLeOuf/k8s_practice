# ⚠️ Grafana Access Note

## Current Status
Grafana is running in Docker but **may not be accessible from WSL2 host** due to Docker networking issues.

## Workaround Options

### Option 1: Access from Windows Browser
Open in Windows browser:
- http://localhost:3000

### Option 2: Use Port Forwarding in Windows
Run in Windows PowerShell (as Admin):
```powershell
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=[WSL_IP]
```

### Option 3: SSH Tunnel
```bash
# In WSL2
ssh -L 3000:localhost:3000 localhost
# Then access http://localhost:3000
```

### Option 4: Use Minikube Service (Recommended)
If you have minikube running:
```bash
kubectl port-forward deployment/grafana 3000:3000
# Then access http://localhost:3000
```

## Verify Container
```bash
docker ps | grep grafana
docker exec pkb-grafana curl http://localhost:3000/api/health
```

## Alternative: Skip Local Grafana
Instead of local Grafana, you can:
1. Use AWS CloudWatch Dashboard
2. Use CloudWatch Insights
3. Monitor via AWS CLI scripts (already provided)

The monitoring infrastructure is set up and ready when you have a working Docker environment.
