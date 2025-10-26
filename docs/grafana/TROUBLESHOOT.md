# Grafana Access Troubleshooting

## Current Status
✅ Container is RUNNING (port 3000 exposed)
✅ Grafana is HEALTHY inside container
❌ May not be reachable from Windows browser

## Try These URLs (in order):

1. **http://localhost:3000** (most likely to work)
2. **http://127.0.0.1:3000**
3. **http://172.28.227.137:3000**

## Open from WSL (Windows PowerShell)

```powershell
Start-Process "http://localhost:3000"
```

## Alternative: SSH Tunnel

If ports aren't forwarding properly, use SSH:

```bash
# In a new WSL terminal
ssh -N -L 3000:localhost:3000 localhost
# Then access http://localhost:3000 from Windows
```

## Or: Restart Container

Sometimes restarting helps:

```bash
cd /home/jerem/serverless_app/grafana
docker-compose restart
# Wait 10 seconds
# Then try http://localhost:3000
```

## Login Credentials
- Username: `admin`
- Password: `admin`

## Verify It's Running
```bash
docker ps | grep grafana
docker logs pkb-grafana --tail 5
```

## If Still Not Working

Check Windows Defender Firewall or try:
```bash
# Stop and restart
cd /home/jerem/serverless_app/grafana
docker-compose down
docker-compose up -d
```
