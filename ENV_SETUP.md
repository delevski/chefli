# Environment Variables Setup Guide

This project uses environment-specific configuration files for different deployment environments.

## Environment Files

- `.env.development` - Automatically loaded when running `npm run dev` (development mode)
- `.env.production` - Automatically loaded when running `npm run build` (production mode)
- `.env.local` - Local overrides (ignored by git, use for personal settings)
- `.env.example` - Template file showing all available variables

## Quick Setup

### For Development

1. The `.env.development` file is already configured with `http://localhost:3000`
2. If you need to override, create `.env.local` with your custom values
3. Run `npm run dev` - it will automatically use `.env.development`

### For Production

1. **IMPORTANT**: Before deploying, update `.env.production` with your production URLs:

```bash
# Edit .env.production
VITE_BACKEND_URL=https://api.yourdomain.com
VITE_GOOGLE_CLIENT_ID=your-production-google-client-id
```

2. Build for production:
```bash
npm run build
```

The build process will automatically use `.env.production` and embed the values into the production bundle.

## Environment Variables

### Web App Variables (VITE_ prefix required)

All variables used in the web app must be prefixed with `VITE_` to be accessible in the browser.

- `VITE_BACKEND_URL` - Backend API URL
  - Development: `http://localhost:3000`
  - Production: `https://api.yourdomain.com` (update before deploying!)

- `VITE_GOOGLE_CLIENT_ID` - Google OAuth Client ID for web
  - Get from [Google Cloud Console](https://console.cloud.google.com)
  - Create separate OAuth clients for development and production

- `VITE_INSTANTDB_APP_ID` - InstantDB App ID
  - Get from [InstantDB Dashboard](https://www.instantdb.com/dash)

### Backend Server Variables

These are used by the backend server (not the web app):

- `BACKEND_URL` - Backend server URL
- `GOOGLE_CLIENT_ID` - Google OAuth Client ID for backend
- `GOOGLE_CLIENT_SECRET` - Google OAuth Client Secret
- `INSTANTDB_ADMIN_TOKEN` - InstantDB Admin Token

## How Vite Loads Environment Files

Vite automatically loads environment files in this order (later files override earlier ones):

1. `.env` - Default (all environments)
2. `.env.[mode]` - Mode-specific (e.g., `.env.development`, `.env.production`)
3. `.env.local` - Local overrides (ignored by git)
4. `.env.[mode].local` - Mode-specific local overrides

## Production Deployment Checklist

- [ ] Update `VITE_BACKEND_URL` in `.env.production` with your production backend URL
- [ ] Add `VITE_GOOGLE_CLIENT_ID` in `.env.production` with your production Google Client ID
- [ ] Configure Google Cloud Console with production authorized origins
- [ ] Run `npm run build` to create production build
- [ ] Verify the built files in `dist/` contain the correct production URLs
- [ ] Deploy the `dist/` folder to your hosting service

## Troubleshooting

### Web app still using localhost in production?

1. Make sure you updated `.env.production` (not `.env.development`)
2. Delete `dist/` folder and rebuild: `rm -rf dist && npm run build`
3. Check that `VITE_BACKEND_URL` is set correctly in `.env.production`
4. Verify the build output doesn't contain `localhost:3000` (search in `dist/` files)

### Environment variables not working?

1. Make sure variables are prefixed with `VITE_` for web app usage
2. Restart the dev server after changing `.env` files
3. Rebuild for production after changing `.env.production`

## Example: Setting Up Production

```bash
# 1. Edit .env.production
cat > .env.production << EOF
VITE_BACKEND_URL=https://api.chefli.app
VITE_GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com
VITE_INSTANTDB_APP_ID=588227b6-6022-44a9-88f3-b1c2e2cce304
EOF

# 2. Build for production
npm run build

# 3. Verify the build
grep -r "api.chefli.app" dist/

# 4. Deploy dist/ folder
```
