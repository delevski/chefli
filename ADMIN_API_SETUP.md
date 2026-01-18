# InstantDB Admin HTTP API Setup

## ✅ What Changed

The Flutter app now supports **direct integration with InstantDB's Admin HTTP API**, eliminating the need for a backend proxy!

## 🎯 Benefits

- ✅ **No backend server needed** - Direct communication from Flutter
- ✅ **Simpler architecture** - One less component to manage
- ✅ **Faster development** - No need to deploy/maintain backend
- ✅ **Still supports backend proxy** - Can switch back if needed

## 📋 Setup Instructions

### Step 1: Get Your Admin Token

1. Go to [InstantDB Dashboard](https://www.instantdb.com/dash)
2. Select your app (App ID: `588227b6-6022-44a9-88f3-b1c2e2cce304`)
3. Navigate to **Settings** → **API Keys**
4. Copy your **Admin Token** (or create one if it doesn't exist)

### Step 2: Update Flutter Config

Open `chefli_flutter/lib/config/instantdb_config.dart` and:

1. Set `useBackendProxy = false`
2. Add your Admin Token:

```dart
static const bool useBackendProxy = false; // ✅ Changed to false
static const String adminToken = 'YOUR_ADMIN_TOKEN_HERE'; // ✅ Add your token
```

### Step 3: Test It!

1. Run your Flutter app: `flutter run`
2. Try signing in with Google
3. Check console logs - you should see:
   - `📤 Creating/updating user with Google sign-in via Admin HTTP API`
   - `✅ User created successfully`

4. Check InstantDB dashboard to verify user was created

## 🔍 How It Works

The app now uses InstantDB's Admin HTTP API endpoints:

- **`POST /admin/transact`** - For creating/updating users
- **`POST /admin/query`** - For querying users by email or Google ID

### Example API Call

```dart
// Creating a user
await _adminTransact([
  ['update', '$users', userId, {
    'id': userId,
    'email': email,
    'name': name,
    'googleId': googleId,
    'photoUrl': photoUrl,
    'createdAt': timestamp,
  }]
]);

// Querying a user
final result = await _adminQuery({
  'users': {
    '\$': {
      'where': {'email': email},
    },
  },
});
```

## ⚠️ Important Notes

### Security Considerations

1. **Admin Token is Powerful** - It has full access to your database
2. **Don't Commit Token** - Keep it in a secure place (consider using environment variables)
3. **For Production** - Consider:
   - Using user-specific tokens instead of admin token
   - Storing token securely (not hardcoded)
   - Using backend proxy for better security

### Token Storage Options

**Option 1: Environment Variables (Recommended)**
```dart
// Use flutter_dotenv package
static String get adminToken => dotenv.env['INSTANTDB_ADMIN_TOKEN'] ?? '';
```

**Option 2: Secure Storage**
```dart
// Use flutter_secure_storage package
final storage = FlutterSecureStorage();
final token = await storage.read(key: 'instantdb_admin_token');
```

**Option 3: Build-time Configuration**
- Use different config files for dev/prod
- Don't commit production tokens

## 🔄 Switching Back to Backend Proxy

If you want to use the backend proxy instead:

1. Set `useBackendProxy = true` in `instantdb_config.dart`
2. Start the backend server: `npm run backend`
3. Update `backendUrl` if needed

## 🐛 Troubleshooting

### Error: "InstantDB API error: 401"

**Problem**: Invalid or missing Admin Token
**Solution**: 
1. Verify token in InstantDB dashboard
2. Check token is correctly set in `instantdb_config.dart`
3. Ensure token hasn't expired

### Error: "InstantDB API error: 404"

**Problem**: Wrong API endpoint
**Solution**: 
- Verify you're using InstantDB's Admin HTTP API
- Check InstantDB documentation for latest endpoints
- Ensure your InstantDB plan supports Admin API

### Error: "Request timeout"

**Problem**: Network connectivity issue
**Solution**:
- Check internet connection
- Verify InstantDB API is accessible
- Try increasing timeout duration

### Users Not Appearing in Dashboard

**Problem**: Transaction succeeded but data not visible
**Solution**:
1. Check console logs for success messages
2. Refresh InstantDB dashboard
3. Verify app ID is correct
4. Check InstantDB dashboard filters/queries

## 📚 API Reference

### Admin Transact Endpoint

**URL**: `POST https://api.instantdb.com/admin/transact`

**Headers**:
```
Authorization: Bearer YOUR_ADMIN_TOKEN
App-Id: YOUR_APP_ID
Content-Type: application/json
```

**Body**:
```json
{
  "steps": [
    ["update", "$users", "userId123", {
      "id": "userId123",
      "email": "user@example.com",
      "name": "User Name",
      "googleId": "google123",
      "photoUrl": "https://...",
      "createdAt": 1234567890
    }]
  ]
}
```

### Admin Query Endpoint

**URL**: `POST https://api.instantdb.com/admin/query`

**Headers**: Same as transact

**Body**:
```json
{
  "users": {
    "$": {
      "where": {
        "email": "user@example.com"
      }
    }
  }
}
```

## ✅ Verification Checklist

- [ ] Admin Token obtained from InstantDB dashboard
- [ ] Token added to `instantdb_config.dart`
- [ ] `useBackendProxy` set to `false`
- [ ] Flutter app runs without errors
- [ ] Google sign-in works
- [ ] User appears in InstantDB dashboard
- [ ] Email/password sign-in works (if tested)
- [ ] Profile screen shows correct user data

## 🎉 Success!

If everything works, you now have:
- ✅ Direct Flutter → InstantDB integration
- ✅ No backend server needed
- ✅ Simpler architecture
- ✅ Google sign-in saving to InstantDB

Enjoy your streamlined setup! 🚀



