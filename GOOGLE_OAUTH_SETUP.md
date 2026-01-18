# Google OAuth Setup Guide for Android

## 📋 Required Information

### Package Name
```
com.example.chefli_flutter
```

### SHA-1 Certificate Fingerprint

#### Debug Keystore (for development)
```
56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C
```

#### Release Keystore (for production)
You'll need to generate this when you create your release keystore. See instructions below.

## 🔧 Quick Setup Script

Run this script to get your configuration info:
```bash
bash scripts/get-google-auth-info.sh
```

## 📝 Step-by-Step Setup

### 1. Get Your SHA-1 Fingerprint

#### Option A: Using the Script (Easiest)
```bash
bash scripts/get-google-auth-info.sh
```

#### Option B: Using Gradle
```bash
cd chefli_flutter/android
./gradlew signingReport
```
Look for the SHA-1 value under "Variant: debug"

#### Option C: Using Keytool (Manual)
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Look for the "SHA1:" line

### 2. Configure Google Cloud Console

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com
   - Sign in with your Google account

2. **Create or Select Project**
   - Click "Select a project" → "New Project"
   - Name: "Chefli" (or your preferred name)
   - Click "Create"

3. **Enable Google Sign-In API**
   - Go to "APIs & Services" → "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

4. **Create OAuth 2.0 Credentials**
   - Go to "APIs & Services" → "Credentials"
   - Click "+ CREATE CREDENTIALS" → "OAuth client ID"
   - If prompted, configure OAuth consent screen first:
     - User Type: External (or Internal if using Google Workspace)
     - App name: "Chefli"
     - User support email: Your email
     - Developer contact: Your email
     - Click "Save and Continue" through the steps

5. **Create Android OAuth Client**
   - Application type: **Android**
   - Name: "Chefli Android" (or your preferred name)
   - **Package name**: `com.example.chefli_flutter`
   - **SHA-1 certificate fingerprint**: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
   - Click "Create"

6. **Copy the Client ID**
   - You'll see a popup with your Client ID
   - Copy it (it looks like: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)

### 3. Configure InstantDB Dashboard

1. **Go to InstantDB Dashboard**
   - Visit: https://www.instantdb.com/dash
   - Sign in with your account

2. **Select Your App**
   - App ID: `588227b6-6022-44a9-88f3-b1c2e2cce304`

3. **Configure Google OAuth**
   - Navigate to "Authentication" or "Settings"
   - Find "Google OAuth" section
   - Enable Google OAuth
   - Add your Google OAuth Client ID (from step 2.6)
   - Configure redirect URIs:
     - For development: `http://localhost:8080/auth/google/callback`
     - For production: Your production URL

### 4. Update Flutter Configuration

Edit `chefli_flutter/lib/config/instantdb_config.dart`:

```dart
class InstantDBConfig {
  // ... existing code ...
  
  // Google OAuth Configuration
  static const bool googleOAuthEnabled = true;
  static const String googleClientId = 'YOUR_CLIENT_ID_HERE'; // Paste from step 2.6
  static const String googleRedirectUri = 'http://localhost:8080/auth/google/callback';
}
```

### 5. Update Android Configuration

The `google-services.json` file should already be in place. Verify it's correct:

**File**: `chefli_flutter/android/app/google-services.json`

If you need to download a new one:
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project (or create new)
3. Add Android app with package name: `com.example.chefli_flutter`
4. Download `google-services.json`
5. Place it in `chefli_flutter/android/app/`

### 6. Test Google Sign-In

1. Run your Flutter app:
   ```bash
   cd chefli_flutter
   flutter run
   ```

2. Click "Sign in with Google"
3. You should see Google sign-in screen
4. After signing in, you should be authenticated

## 🔐 Production Setup (Release Keystore)

For production, you need to create a release keystore and get its SHA-1:

### 1. Create Release Keystore
```bash
cd chefli_flutter/android/app
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### 2. Get Release SHA-1
```bash
keytool -list -v -keystore key.jks -alias key
```

### 3. Add Release SHA-1 to Google Cloud Console
- Go to your OAuth 2.0 Client ID in Google Cloud Console
- Click "Edit"
- Add the release SHA-1 fingerprint
- Save

### 4. Update build.gradle.kts
```kotlin
signingConfigs {
    release {
        keyAlias = 'key'
        keyPassword = 'your-key-password'
        storeFile = file('key.jks')
        storePassword = 'your-store-password'
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## ✅ Verification Checklist

- [ ] Package name extracted: `com.example.chefli_flutter`
- [ ] SHA-1 fingerprint extracted: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`
- [ ] Google Cloud project created
- [ ] Google Sign-In API enabled
- [ ] OAuth consent screen configured
- [ ] Android OAuth client created with correct package name and SHA-1
- [ ] Client ID copied
- [ ] InstantDB dashboard configured with Google OAuth
- [ ] Flutter config updated with Client ID
- [ ] `google-services.json` in place
- [ ] Google Sign-In tested successfully

## 🐛 Troubleshooting

### "Sign in failed" Error
- Verify SHA-1 fingerprint matches exactly (no spaces, correct format)
- Check package name matches exactly
- Ensure Google Sign-In API is enabled
- Verify OAuth consent screen is configured

### "DEVELOPER_ERROR" on Android
- Double-check SHA-1 fingerprint
- Make sure package name is correct
- Verify `google-services.json` is in the right location
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

### Can't Get SHA-1
- Run: `bash scripts/get-google-auth-info.sh`
- Or: `cd chefli_flutter/android && ./gradlew signingReport`
- Or manually: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

## 📚 Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com)
- [InstantDB Dashboard](https://www.instantdb.com/dash)
- [Firebase Console](https://console.firebase.google.com)

## 📝 Quick Reference

**Package Name**: `com.example.chefli_flutter`

**SHA-1 (Debug)**: `56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C`

**App ID**: `588227b6-6022-44a9-88f3-b1c2e2cce304`

---

**Need help?** Run `bash scripts/get-google-auth-info.sh` to get your current configuration.



