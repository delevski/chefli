# Google Sign-In Fix - Backend Proxy Setup

## Problem
Google sign-in data was not being saved to InstantDB because InstantDB uses WebSocket transactions, not REST API endpoints. The Flutter app was trying to call REST API endpoints that don't exist.

## Solution
A backend proxy service has been created to bridge Flutter's HTTP requests with InstantDB's WebSocket transactions.

## ✅ Changes Made

### 1. Backend Proxy (`backend/instantdb-proxy.js`)
- ✅ Added `photoUrl` field to schema
- ✅ Added `createOrUpdateGoogleUser()` function
- ✅ Added `updateUser()` function
- ✅ Added Express routes:
  - `POST /api/users/create-google` - Create/update user with Google sign-in
  - `POST /api/users/find-google` - Find user by Google ID
  - `PUT /api/users/update/:userId` - Update user

### 2. Flutter Service (`chefli_flutter/lib/services/instantdb_auth_service.dart`)
- ✅ Updated to use backend proxy when `useBackendProxy = true`
- ✅ Updated `_findUserByEmail()` to use backend proxy
- ✅ Updated `_findUserByGoogleId()` to use backend proxy
- ✅ Updated `createAccount()` to use backend proxy
- ✅ Updated `signInWithGoogle()` to use backend proxy's `create-google` endpoint

### 3. Server File (`backend/server.js`)
- ✅ Created Express server to run the backend proxy
- ✅ Added CORS support
- ✅ Added health check endpoint

### 4. Package.json
- ✅ Added `express` and `cors` dependencies
- ✅ Added `backend` and `backend:dev` scripts

## 🚀 Setup Instructions

### Step 1: Install Dependencies

```bash
npm install
```

This will install `express` and `cors` packages needed for the backend proxy.

### Step 2: Start the Backend Proxy Server

In a terminal, run:

```bash
npm run backend
```

Or for development with auto-reload:

```bash
npm run backend:dev
```

The server will start on `http://localhost:3000`

### Step 3: Verify Backend is Running

Open your browser and go to:
```
http://localhost:3000/health
```

You should see:
```json
{
  "status": "ok",
  "message": "InstantDB Backend Proxy is running"
}
```

### Step 4: Update Flutter Config (if needed)

If your backend is running on a different URL or port, update:
```dart
// chefli_flutter/lib/config/instantdb_config.dart
static const String backendUrl = 'http://localhost:3000'; // Change if needed
```

### Step 5: Test Google Sign-In

1. Make sure the backend proxy is running
2. Run your Flutter app: `flutter run`
3. Sign in with Google
4. Check the console logs - you should see:
   - `📤 Creating/updating user with Google sign-in via backend proxy`
   - `📥 Backend Proxy Response`
   - `✅ User saved successfully to InstantDB`

5. Check InstantDB dashboard to verify the user was created

## 🔍 Troubleshooting

### Backend Proxy Not Starting

**Error**: `Cannot find module 'express'`
**Solution**: Run `npm install` to install dependencies

### Flutter Can't Connect to Backend

**Error**: `Request timeout` or connection refused
**Solution**: 
1. Make sure backend is running (`npm run backend`)
2. Check the backend URL in `instantdb_config.dart`
3. For mobile/emulator, use `http://10.0.2.2:3000` (Android emulator) or your computer's IP address

### User Still Not Saving to InstantDB

**Check**:
1. Backend proxy logs - look for errors
2. Flutter console logs - check for API errors
3. InstantDB dashboard - verify app ID is correct
4. Network connectivity - ensure backend can reach InstantDB

### CORS Errors

If you see CORS errors, make sure `cors` package is installed and the server is using it (already configured in `server.js`).

## 📝 API Endpoints

The backend proxy provides these endpoints:

- `POST /api/users/create` - Create email/password user
- `POST /api/users/find` - Find user by email
- `POST /api/users/find-google` - Find user by Google ID
- `POST /api/users/create-google` - Create/update user with Google sign-in
- `PUT /api/users/update/:userId` - Update user
- `POST /api/recipes/save` - Save recipe
- `POST /api/recipes/get` - Get user recipes

## 🎯 Next Steps

1. **Deploy Backend Proxy** (for production):
   - Deploy to Vercel, Netlify, or any Node.js hosting
   - Update `backendUrl` in Flutter config to production URL

2. **Test Email/Password Sign-In**:
   - Should also work now with backend proxy

3. **Monitor Logs**:
   - Check backend logs for any InstantDB errors
   - Check Flutter logs for API call status

## ✅ Verification Checklist

- [ ] Backend proxy server is running
- [ ] Health check endpoint returns OK
- [ ] Google sign-in works in Flutter app
- [ ] User data appears in InstantDB dashboard
- [ ] Profile screen shows correct user data
- [ ] Photo URL is saved (if available from Google)

All fixes are complete! The Google sign-in should now save data to InstantDB correctly.



