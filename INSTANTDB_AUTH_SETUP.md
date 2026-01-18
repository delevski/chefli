# InstantDB Authentication Setup Guide

## What Was Implemented

### 1. Schema Updates
- Added `users` entity to InstantDB schema (`src/db/schema.js`)
- Users table includes: email, passwordHash, name, createdAt, googleId

### 2. Flutter Authentication Implementation
- **New Files:**
  - `chefli_flutter/lib/models/user.dart` - InstantDBUser model
  - `chefli_flutter/lib/services/instantdb_auth_service.dart` - Core auth service

- **Updated Files:**
  - `chefli_flutter/lib/services/auth_service.dart` - Now uses InstantDB instead of Firebase
  - `chefli_flutter/lib/providers/auth_provider.dart` - Updated to use InstantDBUser
  - `chefli_flutter/lib/services/instantdb_service.dart` - Now uses REST API instead of local storage
  - `chefli_flutter/pubspec.yaml` - Added crypto package for password hashing

### 3. Rules Updates
- Updated `rules.js` and `rules.ts` with user permissions
- Users can only read/write their own data
- Recipes are public to read, but users can only write their own recipes

## What You Need to Configure

### 1. InstantDB REST API Endpoints
The implementation uses REST API endpoints that may need to be adjusted based on your InstantDB documentation. The current endpoints are:
- `POST /apps/{appId}/entities/users` - Create user
- `GET /apps/{appId}/entities/users?email={email}` - Query user by email
- `GET /apps/{appId}/entities/users?googleId={googleId}` - Query user by Google ID
- `POST /apps/{appId}/entities/recipes` - Create recipe
- `GET /apps/{appId}/entities/recipes?userId={userId}` - Get user's recipes
- `DELETE /apps/{appId}/entities/recipes/{id}` - Delete recipe

**Action Required:** Verify these endpoints match your InstantDB API documentation and update `instantdb_auth_service.dart` and `instantdb_service.dart` if needed.

### 2. Google OAuth Setup
For Google Sign-In to work with InstantDB:

1. **Configure Google OAuth in InstantDB Dashboard:**
   - Go to your InstantDB dashboard
   - Navigate to Authentication settings
   - Enable Google OAuth
   - Add your Google OAuth Client ID and Secret

2. **Configure Google Sign-In in Flutter:**
   - The `google_sign_in` package is already included
   - For Android: Ensure your `google-services.json` is configured
   - For iOS: Configure OAuth in Xcode project settings
   - Add your Google OAuth Client ID to both platforms

**Action Required:** 
- Set up Google OAuth in InstantDB dashboard
- Configure Google Sign-In credentials for Android/iOS
- Update OAuth redirect URIs if needed

### 3. Password Hashing (Important Security Note)
Currently, password hashing is done client-side using SHA-256 with a salt. **This is not ideal for production.**

**Recommended:** Set up a backend endpoint or serverless function to handle password hashing server-side. You can:
- Use InstantDB Admin SDK in a serverless function
- Create a simple backend API endpoint
- Or use InstantDB's Magic Code authentication (passwordless) instead

**Current Implementation:**
- Passwords are hashed with SHA-256 + salt
- Salt is stored locally (not secure for production)
- For production, move password hashing to server-side

### 4. Authentication Token Management
The current implementation uses a simple token system stored in SharedPreferences. For production:
- Consider using InstantDB's built-in auth token system
- Implement token refresh logic
- Add token expiration handling

### 5. Testing
Test the following flows:
1. **Email/Password Registration:**
   - Create account with email and password
   - Verify user is created in InstantDB
   - Check that password is hashed

2. **Email/Password Login:**
   - Sign in with created credentials
   - Verify authentication works
   - Check that user data is retrieved

3. **Google Sign-In:**
   - Click "Sign in with Google"
   - Complete OAuth flow
   - Verify user is created/updated in InstantDB
   - Check that googleId is stored

4. **Recipe Saving:**
   - After login, save a recipe
   - Verify recipe is saved to InstantDB with correct userId
   - Check that recipes are retrieved correctly

## API Endpoint Adjustments

If your InstantDB API uses different endpoints or requires different authentication headers, update:

1. **`instantdb_auth_service.dart`:**
   - Update `_baseUrl` if needed
   - Adjust endpoint paths
   - Update request/response handling

2. **`instantdb_service.dart`:**
   - Update endpoint paths for recipes
   - Adjust authentication headers if needed
   - Update response parsing

## Dependencies Added

- `crypto: ^3.0.5` - For password hashing (already added to pubspec.yaml)

## Next Steps

1. Run `flutter pub get` to install the crypto package
2. Verify InstantDB API endpoints match your documentation
3. Configure Google OAuth in InstantDB dashboard
4. Test authentication flows
5. Consider implementing server-side password hashing for production

## Notes

- The login screen UI (`login_screen.dart`) should work without changes as it uses the same AuthProvider interface
- User data is stored in InstantDB's `users` table
- Recipes are linked to users via `userId` field
- All authentication state is managed through `AuthProvider`



