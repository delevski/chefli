# Google OAuth Redirect Origins & URIs Guide

## 📋 What Are Redirect Origins?

**Redirect Origins** (also called "Authorized JavaScript origins") are the domains from which your app can make OAuth requests. They're used for **Web** applications.

**Redirect URIs** are the specific URLs where Google redirects users after authentication. They're used for both **Web** and **iOS** applications.

**Note**: For **Android** apps, you don't need redirect origins/URIs - you use the **Package Name** and **SHA-1** fingerprint instead.

## 🔧 Required Redirect Origins & URIs

### For Android (No Redirect Origins Needed)
- ✅ **Package Name**: `com.example.chefli_flutter`
- ✅ **SHA-1**: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
- ❌ **No redirect origins/URIs needed** for Android

### For Web Application (Flutter Web)

#### Authorized JavaScript Origins
These are the domains where your app runs:

**Development:**
```
http://localhost:8080
```

**Production:**
```
https://your-production-domain.com
```
(Replace with your actual production domain)

#### Authorized Redirect URIs
These are the callback URLs where Google redirects after authentication:

**Development:**
```
http://localhost:8080/auth/google/callback
```

**Production:**
```
https://your-production-domain.com/auth/google/callback
```
(Replace with your actual production domain)

### For iOS (if applicable)

**Authorized Redirect URIs:**
```
com.example.chefli_flutter:/oauth/callback
```

Or if using a custom URL scheme:
```
chefli://oauth/callback
```

## 📝 How to Configure in Google Cloud Console

### Step 1: Create Web OAuth Client

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to **APIs & Services** → **Credentials**
3. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
4. Select **Web application** as the application type
5. Configure:

   **Name**: `Chefli Web` (or your preferred name)

   **Authorized JavaScript origins** (add these):
   ```
   http://localhost:8080
   https://your-production-domain.com
   ```

   **Authorized redirect URIs** (add these):
   ```
   http://localhost:8080/auth/google/callback
   https://your-production-domain.com/auth/google/callback
   ```

6. Click **Create**
7. Copy the **Client ID** (you'll need this for your Flutter config)

### Step 2: Create Android OAuth Client (Separate)

1. Still in **Credentials** page
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select **Android** as the application type
4. Configure:
   - **Name**: `Chefli Android`
   - **Package name**: `com.example.chefli_flutter`
   - **SHA-1 certificate fingerprint**: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
5. Click **Create**
6. Copy the **Client ID** (you can use the same one or different)

## 🎯 Quick Reference

### Development (Local)
- **JavaScript Origin**: `http://localhost:8080`
- **Redirect URI**: `http://localhost:8080/auth/google/callback`

### Production
- **JavaScript Origin**: `https://your-domain.com` (replace with your domain)
- **Redirect URI**: `https://your-domain.com/auth/google/callback` (replace with your domain)

### Android
- **Package Name**: `com.example.chefli_flutter`
- **SHA-1**: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
- **No redirect origins/URIs needed**

## ⚠️ Important Notes

1. **Different Clients for Different Platforms**
   - Create **separate OAuth clients** for Android and Web
   - They can share the same Client ID or use different ones
   - Each platform has different requirements

2. **Localhost vs Production**
   - Always add **both** localhost (for development) and production URLs
   - Google allows multiple origins/URIs per client

3. **Protocol Matters**
   - Use `http://` for localhost (development)
   - Use `https://` for production (required)
   - Don't mix protocols

4. **No Trailing Slashes**
   - ✅ Correct: `http://localhost:8080`
   - ❌ Wrong: `http://localhost:8080/`

5. **Exact Match Required**
   - Origins and URIs must match **exactly** (including port numbers)
   - Case-sensitive for domains

## 🔍 Verification Checklist

### Web OAuth Client
- [ ] Created Web OAuth client in Google Cloud Console
- [ ] Added `http://localhost:8080` as JavaScript origin
- [ ] Added `http://localhost:8080/auth/google/callback` as redirect URI
- [ ] Added production domain (if applicable)
- [ ] Copied Client ID

### Android OAuth Client
- [ ] Created Android OAuth client in Google Cloud Console
- [ ] Entered package name: `com.example.chefli_flutter`
- [ ] Entered SHA-1: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
- [ ] Copied Client ID

### InstantDB Configuration
- [ ] Added Web Client ID to InstantDB dashboard
- [ ] Added Android Client ID to InstantDB dashboard (if different)
- [ ] Configured redirect URIs in InstantDB dashboard

## 📚 Example Configuration

### Google Cloud Console Setup

**Web Client:**
```
Application type: Web application
Name: Chefli Web
Authorized JavaScript origins:
  - http://localhost:8080
  - https://chefli.app (your production domain)

Authorized redirect URIs:
  - http://localhost:8080/auth/google/callback
  - https://chefli.app/auth/google/callback
```

**Android Client:**
```
Application type: Android
Name: Chefli Android
Package name: com.example.chefli_flutter
SHA-1: 56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C
```

### Flutter Config (`instantdb_config.dart`)

```dart
class InstantDBConfig {
  // For Web - use Web Client ID
  static const String googleClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  
  // For Android - can use same or different Client ID
  // The google_sign_in package will use the one from google-services.json
  
  static const String googleRedirectUri = 'http://localhost:8080/auth/google/callback';
}
```

## 🐛 Troubleshooting

### "redirect_uri_mismatch" Error
- ✅ Check redirect URI matches exactly (including `http://` vs `https://`)
- ✅ Verify port number is correct (`:8080`)
- ✅ Ensure no trailing slashes
- ✅ Check both development and production URIs are added

### "origin_mismatch" Error
- ✅ Verify JavaScript origin matches your app's URL exactly
- ✅ Check protocol (`http://` for localhost, `https://` for production)
- ✅ Ensure port number is included for localhost

### Android Sign-In Not Working
- ✅ Verify package name matches exactly
- ✅ Check SHA-1 fingerprint is correct
- ✅ Ensure Android OAuth client is created (not just Web client)

## 📞 Need Help?

- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com)

---

**Summary**: For **Android**, you only need Package Name + SHA-1. For **Web**, you need JavaScript Origins + Redirect URIs.



