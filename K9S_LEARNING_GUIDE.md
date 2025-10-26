# 🎯 K9s Learning Guide for Your Serverless App

Learn k9s (Kubernetes terminal UI) by managing your serverless API!

## What is K9s?

**k9s** is a terminal UI for interacting with Kubernetes clusters. It provides:
- ✅ A graphical terminal interface to browse Kubernetes resources
- ✅ Real-time resource monitoring
- ✅ Quick access to pods, services, deployments, logs
- ✅ Faster than typing `kubectl` commands repeatedly

## Installation

### Install k9s
```bash
# Linux (using curl)
wget https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/

# Or via package manager
# Ubuntu/Debian
sudo snap install k9s

# Verify installation
k9s version
```

### Install Kubernetes (Local Cluster)

**Option 1: Minikube** (Recommended for learning)
```bash
# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify
minikube version
```

**Option 2: Kind** (Lightweight alternative)
```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify
kind version
```

## Project Setup

### Step 1: Build Docker Images

Build Lambda function images for local testing:
```bash
cd docker

# Build all Lambda images
docker-compose build

# Or build individually
docker build -f Dockerfile.lambda -t pkb-get-items:latest ../lambda-functions/get-items/
docker build -f Dockerfile.lambda -t pkb-create-item:latest ../lambda-functions/create-item/
docker build -f Dockerfile.lambda -t pkb-delete-item:latest ../lambda-functions/delete-item/

# Verify images
docker images | grep pkb
```

### Step 2: Start Minikube

```bash
# Start minikube cluster
minikube start

# Enable addons (ingress for API Gateway simulation)
minikube addons enable ingress

# Check cluster status
minikube status

# View cluster info
kubectl cluster-info
```

### Step 3: Load Images into Minikube

```bash
# Load images into minikube (if not using minikube's built-in Docker)
eval $(minikube docker-env)
docker-compose build

# Or tag and push to local registry
docker images | grep pkb | awk '{print $1":"$2}' | xargs -I {} docker save {} -o /tmp/{}.tar
```

### Step 4: Deploy to Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/

# Check deployments
kubectl get deployments

# Check pods
kubectl get pods

# Check services
kubectl get services
```

## 🎓 Learning with K9s

### Starting k9s

```bash
# Start k9s (connects to current kubeconfig)
k9s

# Or specify namespace
k9s -n default
```

### Essential K9s Commands

#### Navigation
- `h` - Help menu
- `?` - Show keyboard shortcuts
- `Ctrl+C` or `q` - Quit k9s
- `:` - Command mode (like vim)

#### Resource Shortcuts
```
Pods:        p, po, pod
Services:    s, svc
Deployments: d, deploy
Jobs:        j, job
ConfigMaps:  cm
Secrets:     sec
Nodes:       no, node
Namespaces:  ns
```

#### Key Actions in K9s
- **View Details**: `d` - Describe resource
- **Logs**: `l` - View logs
- **Edit**: `e` - Edit resource (YAML)
- **Shell**: `s` - Execute shell in pod
- **Delete**: `Ctrl+D` - Delete resource
- **YAML**: `y` - View/edit YAML

### Learning Path

#### 1. Browse Pods
1. Start k9s: `k9s`
2. Press `p` to view pods
3. Use arrow keys to navigate
4. Press `Enter` to see details
5. Press `l` to view logs
6. Press `d` to describe pod

#### 2. View Services
1. Press `s` to view services
2. See LoadBalancer and ClusterIP
3. Press `Enter` for details

#### 3. Check Deployments
1. Press `d` for deployments
2. See replica count and status
3. Press `r` to scale replicas
4. Press `Enter` for details

#### 4. Watch Logs in Real-Time
1. Navigate to pods (`p`)
2. Select a pod
3. Press `l` for logs
4. Press `f` to follow (like `tail -f`)

#### 5. Edit Resources
1. Navigate to any resource
2. Press `e` to edit YAML
3. Make changes
4. Save to apply

#### 6. Execute Commands in Pods
1. Navigate to pods
2. Select a pod
3. Press `s` to exec into pod
4. Run commands inside

### K9s Dashboard Shortcuts

**When viewing pods:**
- Press `s` - Shell access
- Press `e` - Edit pod
- Press `d` - Describe pod
- Press `l` - Logs
- Press `Ctrl+K` - Kill pod

**When viewing services:**
- Press `Enter` - Show endpoints
- Press `Backspace` - Go back

**Command Mode** (`:` in k9s):
- `:pods` - List pods
- `:services` - List services
- `:deploy` - List deployments
- `:scale deploy <name> --replicas=3` - Scale deployment

## Practical Exercises

### Exercise 1: Monitor Your API

```bash
# Terminal 1: Start k9s
k9s

# Terminal 2: Test API
curl http://<minikube-ip>:<nodeport>/items
```

In k9s:
1. Press `p` to view pods
2. Watch CPU/Memory usage
3. Press `l` on a pod to see logs
4. See your API requests in real-time

### Exercise 2: Scale Your Deployment

In k9s:
1. Press `d` for deployments
2. Select `pkb-api`
3. Press `r` to scale
4. Enter `3` replicas
5. Press `p` to see 3 pods running

### Exercise 3: Debug a Pod

```bash
# Create some load
for i in {1..10}; do curl http://<minikube-ip>:<nodeport>/items; done
```

In k9s:
1. Press `p` to view pods
2. Find a failing pod (Status = CrashLoopBackOff)
3. Press `l` to view logs
4. Press `d` to describe pod
5. See error messages

### Exercise 4: Delete and Redeploy

In k9s:
1. Press `p` for pods
2. Navigate to a pod
3. Press `Ctrl+D` to delete
4. Watch it automatically restart (deployment recreates it)

### Exercise 5: Port Forward

```bash
# Terminal: Port forward to access API
kubectl port-forward svc/pkb-api-service 8080:9001

# Test locally
curl http://localhost:8080/items
```

In k9s:
1. View your API metrics in real-time
2. Check requests hitting the service
3. Monitor pod health

## K9s Advanced Features

### 1. Multiple Clusters
```bash
# View clusters
k9s -c  # List contexts

# Switch cluster
k9s --context <cluster-name>
```

### 2. Custom Aliases
Create `.k9s/config.yaml`:
```yaml
k9s:
  refreshRate: 2
  maxConnRetry: 5
  readOnly: false
  ui:
    enableMouse: true
```

### 3. Plugins (Advanced)
Configure plugins in k9s for custom actions.

### 4. Custom Views
- `:alias <name>` - Create view aliases
- `:quit` - Quit k9s
- `:q` - Quit

## Troubleshooting with K9s

### View Logs of All Pods
1. Start k9s: `k9s`
2. Press `p` for pods
3. Press `Enter` on a pod
4. Press `l` for logs
5. Press `f` to follow logs

### Check Resource Limits
1. Navigate to pods
2. See CPU/MEM columns
3. Press `Enter` on a pod
4. See resource requests/limits

### Monitor Events
1. In k9s, press `:` to enter command mode
2. Type `:events` or `:ev`
3. See recent Kubernetes events

### Check Service Endpoints
1. Press `s` for services
2. Press `Enter` on service
3. See which pods are serving traffic

## K9s vs kubectl Comparison

| Task | kubectl | k9s |
|------|---------|-----|
| List pods | `kubectl get pods` | `p` |
| Pod logs | `kubectl logs pod-name` | Navigate + `l` |
| Describe | `kubectl describe pod` | Navigate + `d` |
| Scale | `kubectl scale deploy` | Navigate + `r` |
| Delete | `kubectl delete pod` | Navigate + `Ctrl+D` |
| Exec | `kubectl exec -it pod -- sh` | Navigate + `s` |

## Quick Reference Card

### Navigation
```
?           Show keyboard shortcuts
/           Search/filter
h           Help
q           Quit
Ctrl+C      Exit

Arrow Keys  Navigate up/down
Enter       View resource details
Backspace   Go back
```

### Resource Shortcuts
```
:pods       po, p
:services   svc, s
:deploys    deploy, d
:nodes      no, node
```

### Actions
```
d           Describe
e           Edit (YAML)
l           Logs
s           Shell
y           YAML
Ctrl+D     Delete
Ctrl+K     Kill
r           Restart
```

## Learning Path Completion

✅ After completing this guide, you will know:
- [ ] How to navigate k9s interface
- [ ] View and understand pods
- [ ] Monitor resource usage
- [ ] View logs in real-time
- [ ] Scale deployments
- [ ] Debug failing pods
- [ ] Use k9s shortcuts efficiently

## Next Steps

1. **Practice**: Use k9s daily for Kubernetes management
2. **Explore**: Try all shortcuts and features
3. **Customize**: Configure k9s for your workflow
4. **Learn**: Kubernetes patterns and best practices

## Resources

- [k9s GitHub](https://github.com/derailed/k9s)
- [k9s Documentation](https://k9scli.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Guide](https://minikube.sigs.k8s.io/docs/)

---

**Pro Tip**: Keep k9s open in one terminal while running commands in another for an interactive learning experience! 🚀

