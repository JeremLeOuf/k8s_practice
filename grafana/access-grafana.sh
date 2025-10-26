#!/bin/bash

# Help access Grafana from Windows

echo "📊 Accessing Grafana from Windows..."
echo ""

# Get the WSL IP
WSL_IP=$(hostname -I | awk '{print $1}')
echo "WSL IP: $WSL_IP"
echo ""

# Create a simple HTML file that can be opened
cat > /tmp/grafana_access.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Access Grafana</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background: #1e1e1e;
            color: white;
        }
        .link-box {
            background: #2d2d2d;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        a {
            color: #4CAF50;
            font-size: 18px;
            text-decoration: none;
        }
        a:hover {
            color: #66BB6A;
        }
    </style>
</head>
<body>
    <h1>🎊 Grafana is Running!</h1>
    
    <div class="link-box">
        <h2>Option 1: Localhost (Recommended)</h2>
        <a href="http://localhost:3000" target="_blank">http://localhost:3000</a>
    </div>
    
    <div class="link-box">
        <h2>Option 2: Direct IP</h2>
        <a href="http://$WSL_IP:3000" target="_blank">http://$WSL_IP:3000</a>
    </div>
    
    <div class="link-box">
        <h2>Login Credentials:</h2>
        <p><strong>Username:</strong> admin</p>
        <p><strong>Password:</strong> admin</p>
    </div>
    
    <script>
        // Try to open automatically after 2 seconds
        setTimeout(function() {
            window.open('http://localhost:3000', '_blank');
        }, 2000);
    </script>
</body>
</html>
EOF

echo "Opening the access page..."
explorer.exe file:///tmp/grafana_access.html 2>/dev/null || start chrome http://localhost:3000 2>/dev/null || echo "Please open http://localhost:3000 in your browser"

