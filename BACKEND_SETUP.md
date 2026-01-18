# Backend Proxy Setup for InstantDB

## Overview

Since InstantDB doesn't have a Flutter SDK, you need a backend proxy service to handle InstantDB transactions. The Flutter app will call this backend, which then communicates with InstantDB.

## Option 1: Use the Provided Backend Proxy

A Node.js backend proxy is provided in `backend/instantdb-proxy.js`. This can be deployed as:

### Deploy as Serverless Function (Recommended)

#### Vercel
1. Create `api/instantdb.js` in your project root
2. Copy the proxy functions
3. Deploy to Vercel

#### Netlify Functions
1. Create `netlify/functions/instantdb.js`
2. Copy the proxy functions
3. Deploy to Netlify

### Deploy as Express Server

1. Install dependencies:
```bash
npm install express @instantdb/react
```

2. Create `server.js`:
```javascript
import express from 'express';
import { setupExpressRoutes } from './backend/instantdb-proxy.js';

const app = express();
app.use(express.json());

setupExpressRoutes(app);

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

3. Run: `node server.js`

## Option 2: Update Flutter to Use Backend API

Update `instantdb_auth_service.dart` to call your backend instead of InstantDB directly:

```dart
// Change from:
final response = await http.post(
  Uri.parse('$_baseUrl/apps/$_appId/entities/users'),
  ...
);

// To:
final response = await http.post(
  Uri.parse('https://your-backend-url.com/api/users/create'),
  body: jsonEncode({
    'email': email,
    'passwordHash': passwordHash,
    'passwordSalt': salt,
    'name': name,
  }),
);
```

## Option 3: Use InstantDB Admin HTTP API

InstantDB has an Admin HTTP API that can be used directly. Update the Flutter code to use the correct Admin API endpoints with proper authentication.

## Testing with Playwright

Run the Playwright tests to verify endpoints:

```bash
npx playwright test
```

This will:
1. Test the Flutter web app authentication flows
2. Verify API endpoints are accessible
3. Check if authentication works correctly

## Next Steps

1. **Choose deployment option** (Serverless recommended)
2. **Deploy backend proxy**
3. **Update Flutter app** to use backend URL
4. **Run Playwright tests** to verify everything works
5. **Configure Google OAuth** in InstantDB dashboard



