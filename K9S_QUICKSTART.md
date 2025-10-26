# 🚀 K9s Quick Start for Your Serverless App

Get started with k9s in 5 minutes!

## Prerequisites

Install these tools (if not already installed):

### 1. Minikube
```bash
# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. K9s
```bash
# Linux (Ubuntu/Debian)
sudo snap install k9s

# Or download from GitHub
wget https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
```

### 3. kubectl (usually comes with minikube)
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

## Quick Start

### Step 1: Setup Environment

```bash
# Start minikube
minikube start

# Setup Docker environment
eval $(minikube docker-env)

# Build images
cd docker
docker-compose build

# Or build individually
docker build -f Dockerfile.lambda -t pkb-get-items:latest ../lambda-functions/get-items/
docker build -f Dockerfile.lambda -t pkb-create-item:latest ../lambda-functions/create-item/
docker build -f Dockerfile.lambda -t pkb-delete-item:latest ../lambda-functions/delete-item/
```

### Step 2: Deploy to Kubernetes

```bash
# Deploy all manifests
kubectl apply -f kubernetes/

# Check deployment
kubectl get pods
kubectl get services
kubectl get deployments
```

### Step 3: Start k9s

```bash
# Start k9s
k9s

# Or use quick start script
./scripts/k9s-quickstart.sh
```

## First 5 Things to Do in K9s

### 1. View Pods
- Press `p` in k9s
- Use arrow keys to navigate
- Press `Enter` for details
- Press `q` to go back

### 2. View Logs
- Navigate to a pod
- Press `l` for logs
- Press `f` to follow logs
- See your API requests in real-time

### 3. View Services
- Press `s` for services
- See LoadBalancer endpoints
- Press `Enter` for endpoint details

### 4. Monitor Resources
- Press `d` for deployments
- See CPU/Memory usage
- Monitor replica status

### 5. Get Help
- Press `?` for keyboard shortcuts
- Press `h` for help menu
- Press `q` to quit

## Essential K9s Commands

| Key | Action |
|-----|--------|
| `p` | View pods |
| `s` | View services |
| `d` | View deployments |
| `Enter` | View details |
| `l` | View logs |
| `e` | Edit (YAML) |
| `d` | Describe |
| `Ctrl+D` | Delete |
| `r` | Restart |
| `?` | Help |
| `q` | Quit |

## Interactive Learning

### Monitor Your API in Real-Time

**Terminal 1 (k9s):**
```bash
k9s
# Press 'p' to view pods
# Press 'l' on a pod to view logs
```

**Terminal 2 (API Testing):**
```bash
# Get service URL
SERVICE_URL=$(minikube service get-items-service --url)

# Make requests
for i in {1..5}; do
  curl $SERVICE_URL/items
  sleep 1
done
```

Watch the requests appear in k9s logs in real-time!

### Scale Your Deployment

In k9s:
1. Press `d` for deployments
2. Navigate to `get-items`
3. Press `r` to scale
4. Enter `5` replicas
5. Press `p` to see 5 pods running

### Debug a Failing Pod

```bash
# Delete a pod to simulate failure
kubectl delete pod <pod-name>
```

In k9s:
1. Watch it restart automatically
2. Press `l` on the new pod
3. See initialization logs

## Testing Your API

```bash
# Get service URLs
GET_SERVICE=$(minikube service get-items-service --url)
CREATE_SERVICE=$(minikube service create-item-service --url)

# Test endpoints
curl $GET_SERVICE/items
curl -X POST $CREATE_SERVICE/items \
  -H "Content-Type: application/json" \
  -d '{"title":"K9s Test","content":"Testing from K8s","type":"note"}'
```

## What You'll Learn

✅ **Navigate k9s interface**  
✅ **Monitor Kubernetes resources**  
✅ **View logs in real-time**  
✅ **Scale deployments**  
✅ **Debug pod issues**  
✅ **Edit YAML on the fly**  
✅ **Use k9s shortcuts efficiently**

## Next Steps

1. Read `K9S_LEARNING_GUIDE.md` for comprehensive tutorial
2. Practice daily with k9s
3. Explore all k9s features
4. Customize k9s configuration

## Resources

- **k9s GitHub**: https://github.com/derailed/k9s
- **k9s Docs**: https://k9scli.io/
- **Kubernetes**: https://kubernetes.io/docs/

## Cleanup

```bash
# Delete all resources
kubectl delete -f kubernetes/

# Stop minikube
minikube stop

# Delete cluster
minikube delete
```

---

**Pro Tip**: Keep k9s open while you work for instant Kubernetes insights! 🚀

