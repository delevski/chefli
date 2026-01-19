# Development Setup Guide

This guide explains how to set up and run the Chefli web application for development.

## Prerequisites

- Node.js 20+ installed
- npm 9+ installed

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Run Both Backend and Webapp Together

```bash
npm run dev:all
```

This starts:
- Backend server on `http://localhost:3000`
- Webapp on `http://localhost:5173`

The webapp is configured to proxy `/api/*` requests to the backend automatically.

### 3. Open in Browser

Navigate to `http://localhost:5173` to see the webapp.

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Run webapp only (Vite dev server) |
| `npm run dev:webapp` | Run webapp only (alias) |
| `npm run dev:backend` | Run backend only |
| `npm run dev:all` | Run both backend and webapp |
| `npm run build` | Build webapp for production |
| `npm run preview` | Preview production build |
| `npm run verify:config` | Verify backend/webapp configuration |
| `npm run backend:dev` | Run backend with auto-reload |

## Project Structure

```
chefli/
├── backend/
│   ├── server.js           # Express server entry point
│   └── instantdb-proxy.js  # InstantDB API proxy
├── src/
│   ├── components/         # React components
│   ├── context/            # React context providers
│   ├── pages/              # Page components
│   ├── services/           # API services
│   └── styles/             # CSS styles
├── dist/                   # Production build output
├── .env.development        # Development environment variables
├── .env.production         # Production environment variables
├── vite.config.js          # Vite configuration
└── package.json            # Project dependencies and scripts
```

## Environment Variables

### Development (`.env.development`)

```bash
VITE_BACKEND_URL=http://localhost:3000
VITE_GOOGLE_CLIENT_ID=your-dev-google-client-id
VITE_INSTANTDB_APP_ID=588227b6-6022-44a9-88f3-b1c2e2cce304
```

### Backend Variables

Set these in your shell or `.env.local`:

```bash
INSTANTDB_ADMIN_TOKEN=your-admin-token
LANGCHAIN_URL=https://ordi1985.pythonanywhere.com/generate-recipe
ASSEMBLYAI_API_KEY=your-assemblyai-key  # Optional, for audio transcription
```

## Development Workflow

### Using Vite Proxy (Recommended)

During development, the Vite dev server proxies `/api/*` requests to the backend. This means:

1. Frontend code uses relative URLs: `/api/users/find`
2. Vite forwards these to `http://localhost:3000/api/users/find`
3. No CORS issues during development

### Running Services Separately

If you prefer to run services separately:

**Terminal 1 - Backend:**
```bash
npm run dev:backend
```

**Terminal 2 - Webapp:**
```bash
npm run dev:webapp
```

## Verifying Configuration

Run the verification script to check if everything is configured correctly:

```bash
npm run verify:config
```

This checks:
- Backend accessibility
- API endpoints
- Environment variables
- Package scripts
- Vite proxy configuration

## Troubleshooting

### Backend Not Starting

1. Check if port 3000 is available: `lsof -i :3000`
2. Kill any existing process: `kill -9 <PID>`
3. Try running again: `npm run dev:backend`

### Webapp Can't Connect to Backend

1. Make sure backend is running: `npm run dev:backend`
2. Check Vite proxy configuration in `vite.config.js`
3. Verify `VITE_BACKEND_URL` in `.env.development`

### CORS Errors

- In development: Use the Vite proxy (enabled by default)
- In production: CORS is handled by the backend

### Environment Variables Not Loading

1. Restart the dev server after changing `.env` files
2. Make sure variables are prefixed with `VITE_` for frontend use
3. Check file names: `.env.development` for dev, `.env.production` for build

## Testing

### End-to-End Tests

```bash
npm run test:e2e
```

### Interactive Test UI

```bash
npm run test:e2e:ui
```

### Debug Tests

```bash
npm run test:e2e:debug
```

## Next Steps

- See [DEPLOYMENT.md](DEPLOYMENT.md) for deployment options
- See [ENV_SETUP.md](ENV_SETUP.md) for environment configuration details
