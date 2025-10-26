# 🎯 Start Here: K9s + Kubernetes Learning Path

Welcome! Here's your complete guide to learning k9s with your serverless app.

## 📚 What You Have

This project is now configured for **k9s learning**:

✅ **AWS Lambda Functions** - Deployed to AWS (Free Tier)  
✅ **Terraform Infrastructure** - IaC for AWS resources  
✅ **Kubernetes Manifests** - For local K8s deployment  
✅ **Docker Images** - Containerized Lambda functions  
✅ **K9s Learning Guides** - Comprehensive tutorials  

## 🚀 Quick Start (Choose Your Path)

### Path 1: Learn K9s Locally (Recommended)

```bash
# 1. Install minikube and k9s
# See K9S_QUICKSTART.md for installation

# 2. Run setup script
./scripts/setup-k9s.sh

# 3. Start k9s
k9s

# 4. Press 'p' to view pods and start exploring!
```

### Path 2: Use AWS + Learn Terraform

```bash
# Already deployed to AWS
# See QUICKSTART.md for managing AWS resources

# API URL: https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod/items
```

## 📖 Learning Guides

### 🌟 Start Here
1. **K9S_QUICKSTART.md** - Get started with k9s in 5 minutes
2. **K9S_LEARNING_GUIDE.md** - Complete k9s tutorial and exercises
3. **kubernetes/README.md** - Kubernetes deployment guide

### 📚 Project Documentation
4. **README.md** - Full project documentation
5. **QUICKSTART.md** - AWS deployment guide
6. **PROJECT_SUMMARY.md** - Architecture and concepts
7. **AWS_FREE_TIER.md** - Free Tier optimization

## 🎓 Learning Path

### Day 1: K9s Basics
- [ ] Read `K9S_QUICKSTART.md`
- [ ] Install minikube and k9s
- [ ] Run `./scripts/setup-k9s.sh`
- [ ] Explore k9s interface
- [ ] Practice navigation (`p`, `s`, `d`)

### Day 2: Monitoring
- [ ] View logs in k9s (`l`)
- [ ] Follow logs in real-time (`f`)
- [ ] Monitor resource usage
- [ ] Describe resources (`d`)

### Day 3: Pod Management
- [ ] Scale deployments (`r`)
- [ ] Delete pods and watch restart
- [ ] View events
- [ ] Debug failing pods

### Day 4: Services & Networking
- [ ] Understand Services
- [ ] Port forwarding
- [ ] Service discovery
- [ ] NodePort vs LoadBalancer

### Day 5: Advanced K9s
- [ ] Edit resources in k9s (`e`)
- [ ] Shell into pods (`s`)
- [ ] View YAML (`y`)
- [ ] Custom configurations

## 🛠️ Essential Commands

### Quick Reference

**k9s:**
```bash
k9s              # Start k9s
p                # View pods
s                # View services
d                # View deployments
Enter            # View details
l                # View logs
?                # Help
q                # Quit
```

**kubectl:**
```bash
kubectl get pods
kubectl get services
kubectl get deployments
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

**Minikube:**
```bash
minikube start
minikube status
minikube service <service-name> --url
minikube stop
```

## 🎯 Your First K9s Session

```bash
# 1. Setup (first time only)
./scripts/setup-k9s.sh

# 2. Open k9s
k9s

# 3. Explore
# Press 'p' to view pods
# Use arrow keys to navigate
# Press Enter on a pod for details
# Press 'l' to view logs
# Press 's' to view services
# Press 'd' for deployments
# Press '?' for help
# Press 'q' to quit

# 4. Test your API
minikube service get-items-service --url
curl $(minikube service get-items-service --url)/items
```

## 📊 Monitoring Your App

### In K9s
- View pods status and health
- Monitor CPU/Memory usage
- Watch logs in real-time
- Track deployment events

### Via kubectl
```bash
# Watch pods
kubectl get pods -w

# View logs
kubectl logs -f deployment/get-items

# Get service URL
minikube service list
```

## 🎉 Project Highlights

### What You Can Learn
- ✅ Kubernetes cluster management
- ✅ Pod lifecycle management
- ✅ Service discovery and load balancing
- ✅ Resource monitoring with k9s
- ✅ Debugging and troubleshooting
- ✅ Auto-scaling and high availability
- ✅ Container orchestration

### Technologies
- **k9s** - Terminal UI for K8s
- **Kubernetes** - Container orchestration
- **Docker** - Containerization
- **Minikube** - Local K8s cluster
- **AWS Lambda** - Serverless functions
- **Terraform** - Infrastructure as Code

## 🚦 Status

### AWS Deployment
- ✅ Lambda functions deployed
- ✅ API Gateway configured
- ✅ DynamoDB created
- ✅ Free Tier optimized
- **URL**: https://vzilkz4t52.execute-api.us-east-1.amazonaws.com/prod/items

### Kubernetes Deployment
- ✅ Manifests created
- ✅ Scripts ready
- ⏳ Pending: minikube/k9s setup (your next step!)

## 🆘 Need Help?

### Troubleshooting
- **k9s won't start** → Check if kubectl is configured (`kubectl get pods`)
- **Pods not running** → Check `kubectl describe pod <name>`
- **Can't access services** → Verify minikube tunnel
- **Images not found** → Run `./scripts/setup-k9s.sh`

### Resources
- [k9s GitHub](https://github.com/derailed/k9s)
- [k9s Docs](https://k9scli.io/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Minikube Guide](https://minikube.sigs.k8s.io/docs/)

## 🎓 Next Steps

1. **Read**: `K9S_QUICKSTART.md`
2. **Install**: minikube and k9s
3. **Deploy**: Run `./scripts/setup-k9s.sh`
4. **Explore**: Start k9s and practice
5. **Learn**: Work through exercises in `K9S_LEARNING_GUIDE.md`

---

**Ready to start?**  
```bash
# Install k9s and minikube, then:
./scripts/setup-k9s.sh
k9s
```

Press `p` and start exploring! 🚀

