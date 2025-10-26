# Accessing Grafana from Windows (WSL2)

## Quick Access

Grafana is running at **http://localhost:3000** but WSL2 networking can be tricky.

### Method 1: Open in Default Browser (Easiest)
```bash
cmd.exe /c start http://localhost:3000
```

### Method 2: Use IP Address
1. Open Windows browser
2. Go to: http://172.28.227.137:3000

### Method 3: Check Windows Firewall
```bash
# Run in Windows PowerShell (as Admin)
New-NetFirewallRule -DisplayName "WSL2 Grafana" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

### Method 4: Port Forward (if above don't work)
```bash
# In Windows PowerShell
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=172.28.227.137
```

## Verify Container is Running
```bash
docker ps
# Should show pkb-grafana container running
```

## Login
- Username: `admin`
- Password: `admin`

## Troubleshooting
If still not accessible:
1. Try: http://localhost:3000
2. Try: http://127.0.0.1:3000  
3. Check Windows Firewall rules
4. Restart Docker: `docker-compose restart`
