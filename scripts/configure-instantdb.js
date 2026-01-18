#!/usr/bin/env node

/**
 * InstantDB Configuration Script
 * 
 * This script helps configure InstantDB for the Chefli app.
 * Run with: node scripts/configure-instantdb.js
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const APP_ID = '588227b6-6022-44a9-88f3-b1c2e2cce304';

console.log('🔧 InstantDB Configuration Helper\n');

// Create Flutter config directory
const flutterConfigDir = path.join(__dirname, '../chefli_flutter/lib/config');
if (!fs.existsSync(flutterConfigDir)) {
  fs.mkdirSync(flutterConfigDir, { recursive: true });
  console.log('✅ Created Flutter config directory');
}

// Create InstantDB config for Flutter
const flutterConfig = `// InstantDB Configuration
// Generated automatically - update values as needed

class InstantDBConfig {
  // InstantDB App ID (from your dashboard)
  static const String appId = '${APP_ID}';
  
  // Base URL for InstantDB API
  // Note: InstantDB uses WebSocket transactions, not REST API
  // For Flutter, use a backend proxy or InstantDB Admin HTTP API
  static const String baseUrl = 'https://api.instantdb.com';
  
  // Backend Proxy Configuration
  // Set to true if using the backend proxy service
  static const bool useBackendProxy = true;
  static const String backendUrl = 'http://localhost:3000'; // Update with your backend URL
  
  // Auth Configuration
  static const bool emailPasswordEnabled = true;
  static const bool hashPasswordOnServer = true; // Recommended: hash passwords server-side
  
  // Google OAuth Configuration
  static const bool googleOAuthEnabled = true;
  // Get these from Google Cloud Console and InstantDB dashboard
  static const String googleClientId = ''; // Add your Google Client ID
  static const String googleRedirectUri = ''; // Add your redirect URI
  
  // Backend API Endpoints (if using backend proxy)
  static const String createUserEndpoint = '/api/users/create';
  static const String findUserEndpoint = '/api/users/find';
  static const String findUserByGoogleIdEndpoint = '/api/users/find-google';
  static const String saveRecipeEndpoint = '/api/recipes/save';
  static const String getRecipesEndpoint = '/api/recipes/get';
  static const String deleteRecipeEndpoint = '/api/recipes/delete';
}

`;

fs.writeFileSync(
  path.join(flutterConfigDir, 'instantdb_config.dart'),
  flutterConfig
);
console.log('✅ Created Flutter configuration file');

// Create .env.example
const envExample = `# InstantDB Configuration
# Copy this file to .env and fill in your values

# InstantDB App ID (from dashboard: https://www.instantdb.com/dash)
INSTANTDB_APP_ID=${APP_ID}

# Backend Proxy URL (if using backend proxy)
# Deploy backend/instantdb-proxy.js as serverless function or Express server
BACKEND_URL=http://localhost:3000

# Google OAuth Configuration
# Get these from Google Cloud Console: https://console.cloud.google.com
GOOGLE_CLIENT_ID=your-google-client-id-here
GOOGLE_CLIENT_SECRET=your-google-client-secret-here
GOOGLE_REDIRECT_URI=http://localhost:8080/auth/google/callback

# InstantDB Admin Token (for backend proxy)
# Get from InstantDB dashboard: https://www.instantdb.com/dash
INSTANTDB_ADMIN_TOKEN=your-admin-token-here

# Flutter Web Port
FLUTTER_WEB_PORT=8080
`;

fs.writeFileSync(
  path.join(__dirname, '../.env.example'),
  envExample
);
console.log('✅ Created .env.example file');

// Create configuration summary
const summary = `# InstantDB Configuration Summary

## ✅ Configuration Files Created

1. **Flutter Config**: \`chefli_flutter/lib/config/instantdb_config.dart\`
   - Contains all InstantDB configuration for Flutter app
   - Update \`backendUrl\` with your deployed backend URL
   - Add Google OAuth credentials

2. **Environment Template**: \`.env.example\`
   - Template for environment variables
   - Copy to \`.env\` and fill in your values

## 📋 Next Steps

### 1. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - \`http://localhost:8080/auth/google/callback\` (for local dev)
   - Your production URL (for production)
6. Copy Client ID and Secret to \`.env\`

### 2. Configure InstantDB Dashboard

1. Go to [InstantDB Dashboard](https://www.instantdb.com/dash)
2. Select your app (App ID: ${APP_ID})
3. Navigate to Authentication settings
4. Enable Google OAuth
5. Add your Google OAuth Client ID
6. Configure redirect URIs

### 3. Deploy Backend Proxy

Since InstantDB doesn't have a Flutter SDK, you need a backend proxy:

**Option A: Deploy as Serverless Function (Recommended)**
- Vercel: Create \`api/instantdb.js\` and deploy
- Netlify: Create \`netlify/functions/instantdb.js\` and deploy

**Option B: Run Express Server**
\`\`\`bash
cd backend
npm install express @instantdb/react
node server.js
\`\`\`

### 4. Update Flutter App

Update \`instantdb_auth_service.dart\` to use backend URL:

\`\`\`dart
import '../config/instantdb_config.dart';

// Change API calls to use backend
final response = await http.post(
  Uri.parse('\${InstantDBConfig.backendUrl}\${InstantDBConfig.createUserEndpoint}'),
  ...
);
\`\`\`

### 5. Test Configuration

Run Playwright tests to verify:
\`\`\`bash
npm run test:e2e
\`\`\`

## 🔍 Verification Checklist

- [ ] Google OAuth configured in Google Cloud Console
- [ ] Google OAuth configured in InstantDB dashboard
- [ ] Backend proxy deployed and accessible
- [ ] Backend URL updated in Flutter config
- [ ] Environment variables set in \`.env\`
- [ ] Flutter app updated to use backend
- [ ] Tests passing

## 📚 Resources

- [InstantDB Docs](https://www.instantdb.com/docs)
- [InstantDB Auth Docs](https://www.instantdb.com/docs/auth)
- [Google OAuth Setup](https://developers.google.com/identity/protocols/oauth2)
- [Backend Setup Guide](./BACKEND_SETUP.md)
`;

fs.writeFileSync(
  path.join(__dirname, '../CONFIGURATION_GUIDE.md'),
  summary
);
console.log('✅ Created configuration guide');

console.log('\n✨ Configuration files created successfully!');
console.log('\n📖 Next steps:');
console.log('1. Review CONFIGURATION_GUIDE.md');
console.log('2. Configure Google OAuth');
console.log('3. Deploy backend proxy');
console.log('4. Update Flutter app to use backend');
console.log('5. Run tests: npm run test:e2e\n');

