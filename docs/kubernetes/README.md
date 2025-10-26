# Kubernetes Deployment for Serverless App

This directory contains Kubernetes manifests for deploying your Lambda functions as containers.

## Architecture

```
┌─────────────────┐
│   Deployment    │
│   get-items     │ ──┐
│   (2 replicas)  │   │
└─────────────────┘   │
                     ├──► Service (NodePort)
┌─────────────────┐   │
│   Deployment    │   │
│  create-item    │ ──┤
│   (2 replicas)  │   │
└─────────────────┘   │
                     │
┌─────────────────┐   │
│   Deployment    │   │
│  delete-item    │ ──┘
│   (2 replicas)  │
└─────────────────┘
```

## Files

- `get-items-deployment.yaml` - Deployment for get-items function
- `create-item-deployment.yaml` - Deployment for create-item function
- `delete-item-deployment.yaml` - Deployment for delete-item function
- `*-service.yaml` - Services for each function

## Deployment

### Setup (First Time)

```bash
# Run setup script
./scripts/setup-k9s.sh
```

This will:
1. Check minikube/k9s installation
2. Start minikube cluster
3. Build Docker images
4. Deploy to Kubernetes
5. Wait for pods to be ready

### Manual Deployment

```bash
# Build Docker images
cd docker
docker-compose build

# Deploy to Kubernetes
kubectl apply -f kubernetes/

# Check status
kubectl get pods
kubectl get services
```

## Management with K9s

### Start k9s

```bash
k9s
```

### Or use quick start

```bash
./scripts/k9s-quickstart.sh
```

### Key Commands in k9s

- `p` - View pods
- `s` - View services
- `d` - View deployments
- `Enter` - View details
- `l` - View logs
- `?` - Help
- `q` - Quit

## Testing

### Get Service URLs

```bash
# Get service URLs
minikube service get-items-service --url
minikube service create-item-service --url
minikube service delete-item-service --url

# Or get all services
minikube service list
```

### Test API

```bash
# Get all items
curl $(minikube service get-items-service --url)/items

# Create an item
curl -X POST $(minikube service create-item-service --url)/items \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"From K8s","type":"note"}'
```

## Monitoring

### View Pods

```bash
kubectl get pods -w  # Watch pods
kubectl get pods -o wide  # More details
```

### View Logs

```bash
# Get logs for a pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# All pods of a deployment
kubectl logs -l app=get-items
```

### Scaling

```bash
# Scale deployment
kubectl scale deployment get-items --replicas=3

# Or in k9s
# Press 'd', select deployment, press 'r', enter number
```

## Cleanup

### Delete Resources

```bash
kubectl delete -f kubernetes/

# Or in k9s
# Navigate to resource, press Ctrl+D
```

### Stop Minikube

```bash
minikube stop  # Pause cluster
minikube delete  # Delete cluster
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events

# View pod logs
kubectl logs <pod-name>
```

### Image Pull Errors

```bash
# Ensure images are built locally
docker images | grep pkb

# If using minikube
eval $(minikube docker-env)
docker images | grep pkb
```

### Port Already in Use

```bash
# Change NodePort in service YAML
kubectl edit svc get-items-service

# Or delete and redeploy
kubectl delete -f kubernetes/
kubectl apply -f kubernetes/
```

## Learning Resources

- Read `../K9S_LEARNING_GUIDE.md` for comprehensive k9s tutorial
- Read `../PROJECT_SUMMARY.md` for project overview
- Kubernetes docs: https://kubernetes.io/docs/

