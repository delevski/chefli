# Deployment Guide

This guide covers various deployment options for the Chefli web application.

## Deployment Options

1. **Unified Express Server** - Single deployment serving both API and webapp
2. **Docker** - Containerized deployment
3. **Vercel** - Serverless deployment
4. **Netlify** - Static + Functions deployment

## Option 1: Unified Express Server (Recommended)

The simplest approach - the backend serves both API endpoints and the webapp.

### Build and Deploy

```bash
# 1. Update production environment
# Edit .env.production with your production URLs

# 2. Build the webapp
npm run build

# 3. Start in production mode
NODE_ENV=production node backend/server.js
```

### Using PM2 (Recommended for Production)

```bash
# Install PM2 globally
npm install -g pm2

# Start with PM2
NODE_ENV=production pm2 start backend/server.js --name chefli

# View logs
pm2 logs chefli

# Restart
pm2 restart chefli

# Stop
pm2 stop chefli
```

### Deploy to Any Node.js Hosting

Works with:
- Railway
- Render
- DigitalOcean App Platform
- Heroku
- AWS Elastic Beanstalk

## Option 2: Docker Deployment

### Build and Run

```bash
# Build image
docker build -t chefli .

# Run container
docker run -d \
  -p 3000:3000 \
  -e INSTANTDB_ADMIN_TOKEN=your-token \
  -e LANGCHAIN_URL=https://ordi1985.pythonanywhere.com/generate-recipe \
  --name chefli \
  chefli
```

### Using Docker Compose

```bash
# Production
docker-compose up -d

# Development (with hot reload)
docker-compose --profile dev up
```

### Environment Variables for Docker

Create a `.env` file:

```bash
INSTANTDB_ADMIN_TOKEN=your-admin-token
LANGCHAIN_URL=https://ordi1985.pythonanywhere.com/generate-recipe
ASSEMBLYAI_API_KEY=your-key  # Optional
```

## Option 3: Vercel Deployment

### Prerequisites

1. Install Vercel CLI: `npm i -g vercel`
2. Login: `vercel login`

### Deploy

```bash
# Deploy to Vercel
vercel

# Deploy to production
vercel --prod
```

### Set Environment Variables

In Vercel Dashboard or CLI:

```bash
vercel env add INSTANTDB_ADMIN_TOKEN
vercel env add LANGCHAIN_URL
vercel env add ASSEMBLYAI_API_KEY
```

### Configuration

The `vercel.json` file is already configured to:
- Serve the backend as serverless functions
- Serve the webapp as static files
- Route `/api/*` to the backend

## Option 4: Netlify Deployment

### Prerequisites

1. Install Netlify CLI: `npm i -g netlify-cli`
2. Login: `netlify login`

### Create Serverless Functions

Create `netlify/functions/api.js`:

```javascript
import { setupExpressRoutes } from '../../backend/instantdb-proxy.js';
import express from 'express';
import serverless from 'serverless-http';

const app = express();
app.use(express.json());
setupExpressRoutes(app);

export const handler = serverless(app);
```

### Deploy

```bash
# Build and deploy
netlify deploy --prod
```

### Set Environment Variables

In Netlify Dashboard:
- INSTANTDB_ADMIN_TOKEN
- LANGCHAIN_URL
- ASSEMBLYAI_API_KEY

## Production Checklist

### Before Deployment

- [ ] Update `.env.production` with production URLs
- [ ] Set `VITE_BACKEND_URL` to your production backend URL
- [ ] Set `VITE_GOOGLE_CLIENT_ID` for production (if using Google auth)
- [ ] Configure Google Cloud Console with production domains
- [ ] Test locally with production build: `npm run build && npm run preview`

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `INSTANTDB_ADMIN_TOKEN` | Yes | InstantDB admin API token |
| `LANGCHAIN_URL` | No | Recipe generation API URL |
| `ASSEMBLYAI_API_KEY` | No | Audio transcription API key |
| `NODE_ENV` | Yes | Set to `production` |
| `PORT` | No | Server port (default: 3000) |

### Security

- [ ] Never commit `.env` files with real credentials
- [ ] Use environment variables for all secrets
- [ ] Enable HTTPS in production
- [ ] Configure proper CORS origins

## Health Check

All deployment options expose a health check endpoint:

```bash
curl https://your-domain.com/health
```

Response:
```json
{
  "status": "ok",
  "message": "InstantDB Backend Proxy is running"
}
```

## Monitoring

### Logs

- **PM2**: `pm2 logs chefli`
- **Docker**: `docker logs chefli`
- **Vercel**: Vercel Dashboard > Deployments > Logs
- **Netlify**: Netlify Dashboard > Functions > Logs

### Performance

Consider adding monitoring tools:
- Sentry (error tracking)
- LogRocket (session replay)
- DataDog or New Relic (APM)

## Scaling

### Horizontal Scaling

For high traffic:

1. **Docker**: Use Docker Swarm or Kubernetes
2. **Vercel/Netlify**: Auto-scales automatically
3. **Traditional**: Use load balancer with multiple instances

### Database

InstantDB handles scaling automatically. No additional configuration needed.

## Troubleshooting

### 502 Bad Gateway

- Check if backend is running
- Verify environment variables are set
- Check logs for errors

### CORS Errors

- Verify `VITE_BACKEND_URL` matches your production domain
- Check CORS configuration in `backend/server.js`

### API Endpoints Return 404

- Ensure backend routes are properly configured
- Check if using correct API paths (`/api/...`)

### Static Files Not Loading

- Verify `dist/` folder was created during build
- Check if `NODE_ENV=production` is set
