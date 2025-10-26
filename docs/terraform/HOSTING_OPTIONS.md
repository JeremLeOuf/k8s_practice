# Static Site Hosting Options

You have several options for hosting your static frontend. Here's a comparison and setup guide.

## Comparison Table

| Option | Cost | HTTPS | Custom Domain | Deploy Speed | Best For |
|--------|------|-------|---------------|--------------|----------|
| **GitHub Pages** | Free | ✅ Yes | ✅ Yes | ⚡ Instant | Public demos |
| **CloudFront** | Pay per GB | ✅ Yes | ✅ Yes | 🐌 10-15 min | Production |
| **S3 Website** | Free | ❌ No | ❌ No | ⚡ ~1 min | Development |
| **Netlify** | Free tier | ✅ Yes | ✅ Yes | ⚡ Instant | Best features |
| **Vercel** | Free tier | ✅ Yes | ✅ Yes | ⚡ Instant | Developer friendly |

## Option 1: GitHub Pages (Recommended for Demo) ⭐

### Pros
- ✅ **100% Free**
- ✅ **HTTPS by default** (e.g., `https://username.github.io/repo`)
- ✅ **Custom domain support** (free)
- ✅ **Instant deployment** via git push
- ✅ **No AWS costs**
- ✅ **Easy to set up** (5 minutes)

### Cons
- ❌ Only for **public repositories** (private repos need GitHub Pro)
- ❌ **Static content only** (no server-side processing)

### Setup Guide

#### 1. Enable GitHub Pages

1. Go to your GitHub repository
2. Click **Settings** → **Pages**
3. Under "Source", select **"Deploy from a branch"**
4. Choose branch: `main` or `fast_deploy`
5. Select folder: `/frontend` or `/` (root)
6. Click **Save**

**Your site will be live at:**
```
https://JeremLeOuf.github.io/k8s_practice/
```

#### 2. Create GitHub Actions Workflow

Create `.github/workflows/github-pages.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main, fast_deploy ]
    paths:
      - 'frontend/**'

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Pages
        uses: actions/configure-pages@v2
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: 'frontend'
      
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```

#### 3. Deploy

```bash
# After pushing, your site is live automatically
git push origin main

# Access at: https://JeremLeOuf.github.io/k8s_practice/
```

#### 4. Update API URLs for GitHub Pages

Since GitHub Pages uses HTTPS, update your frontend files:

```bash
# Update API URLs in HTML files
cd frontend
sed -i 's|{{API_GATEWAY_URL}}|https://gsb6x7ntmb.execute-api.us-east-1.amazonaws.com/prod|g' *.html

# Commit and push
git add frontend/
git commit -m "Update API URLs for GitHub Pages"
git push
```

### Custom Domain (Optional)

1. Buy a domain (e.g., `mydomain.com`)
2. In GitHub Pages settings, add your custom domain
3. Add DNS records:
   ```
   Type: A
   Name: @
   Value: 185.199.108.153
   
   Type: A
   Name: @
   Value: 185.199.109.153
   
   Type: A
   Name: @
   Value: 185.199.110.153
   
   Type: A
   Name: @
   Value: 185.199.111.153
   ```

---

## Option 2: AWS CloudFront (Current Setup)

### Enable CloudFront

```bash
cd infrastructure
terraform apply -var="enable_cloudfront=true"
terraform output frontend_url
# Output: https://d1234567890abc.cloudfront.net
```

### Pros
- ✅ **HTTPS** with AWS certificate
- ✅ **Global CDN** (fast worldwide)
- ✅ **Custom domain** support
- ✅ **Integrates with AWS**

### Cons
- ❌ **Costs money** (~$1-5/month for low traffic)
- ❌ **Slow deployment** (10-15 minutes)
- ❌ More complex setup

---

## Option 3: Netlify (Best Features) ⭐⭐

### Setup (5 minutes)

1. **Sign up** at https://netlify.com (free)
2. **Connect GitHub** repository
3. **Settings:**
   - Build command: (leave empty)
   - Publish directory: `frontend`
4. **Deploy!**

### Pros
- ✅ **Free tier** (generous)
- ✅ **HTTPS** automatically
- ✅ **Custom domain** free
- ✅ **Instant deploys**
- ✅ **Branch previews**
- ✅ **Forms & functions**
- ✅ **Analytics** (optional)

### Intent
- Perfect for static sites
- Very developer-friendly
- Great for learning

---

## Option 4: Vercel (Developer Friendly)

### Setup

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel

# Follow prompts
```

### Pros
- ✅ **Free tier**
- ✅ **HTTPS**
- ✅ **Global CDN**
- ✅ **Instant deploys**
- ✅ **Developer-friendly**

### Cons
- ❌ Primarily for JS frameworks
- ❌ Less AWS integration

---

## Recommendation

### For Learning / Demo Projects

**Use GitHub Pages** because:
1. ✅ Free
2. ✅ HTTPS by default
3. ✅ Easy to set up
4. ✅ Integrates with your existing repo
5. ✅ Good for sharing with others

### For Production

**Use CloudFront** because:
1. ✅ AWS native
2. ✅ Better integration with AWS services
3. ✅ Custom domain support
4. ✅ Professional setup

### For Best Developer Experience

**Use Netlify** because:
1. ✅ Free tier
2. ✅ Best features
3. ✅ Easiest to use
4. ✅ Instant deploys

---

## Quick GitHub Pages Setup Script

I can create a script to automatically deploy to GitHub Pages. Want me to set that up?

```bash
# This would create a GitHub Actions workflow
# and update your deployment pipeline
```

---

## Comparison Summary

| Your Need | Best Option |
|-----------|-------------|
| **Free + Fast** | GitHub Pages |
| **Best Features** | Netlify |
| **AWS Integration** | CloudFront |
| **Local Development** | S3 Website (current fast mode) |

**Want me to set up GitHub Pages or Netlify for you?**

