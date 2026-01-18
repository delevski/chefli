# Playwright Testing Setup - Complete

## What Was Created

### 1. Playwright Configuration
- **File**: `playwright.config.js`
- Configured to test Flutter web app on `http://localhost:8080`
- Automatically starts Flutter web server before tests
- Tests run on Chromium, Firefox, and WebKit

### 2. Test Files

#### Authentication Tests (`tests/auth.spec.js`)
- ✅ Login screen display test
- ✅ Email validation test
- ✅ Account creation flow test
- ✅ Login with email/password test
- ✅ Google sign-in button test
- ✅ Session persistence test

#### API Endpoint Tests (`tests/api-endpoints.spec.js`)
- ✅ Base URL accessibility check
- ✅ Users endpoint verification
- ✅ Recipes endpoint verification
- ✅ JSON content type acceptance
- ✅ Authentication endpoint discovery

### 3. Backend Proxy Service
- **File**: `backend/instantdb-proxy.js`
- Node.js service to bridge Flutter and InstantDB
- Handles user creation, lookup, and recipe operations
- Can be deployed as serverless function or Express server

## How to Run Tests

### 1. Start Flutter Web App (Manual)
```bash
cd chefli_flutter
flutter run -d web-server --web-port=8080
```

### 2. Run Playwright Tests (in another terminal)
```bash
# Run all tests
npm run test:e2e

# Run with UI mode (interactive)
npm run test:e2e:ui

# Run in debug mode
npm run test:e2e:debug
```

### 3. Automatic Mode (Recommended)
The Playwright config automatically starts the Flutter server, so you can just run:
```bash
npm run test:e2e
```

## What the Tests Verify

### Authentication Flow Tests
1. **Login Screen**: Verifies login UI elements are present
2. **Validation**: Checks email format validation works
3. **Account Creation**: Tests the full account creation flow
4. **Login**: Tests email/password login functionality
5. **Google Sign-In**: Verifies Google OAuth button is present
6. **Session Persistence**: Checks if login state persists after reload

### API Endpoint Tests
1. **Base URL**: Verifies InstantDB API is accessible
2. **Endpoints**: Checks if users and recipes endpoints exist
3. **Content Type**: Verifies API accepts JSON
4. **Structure**: Explores authentication endpoint structure

## Important Notes

### InstantDB API Limitation
InstantDB uses WebSocket connections and transactions, not standard REST API. The current Flutter implementation uses REST endpoints which may not work directly.

### Solution: Backend Proxy
A backend proxy service (`backend/instantdb-proxy.js`) is provided to:
- Handle InstantDB transactions properly
- Bridge Flutter app with InstantDB
- Can be deployed as serverless function (Vercel/Netlify) or Express server

### Next Steps
1. **Deploy Backend Proxy** (see `BACKEND_SETUP.md`)
2. **Update Flutter App** to use backend URL instead of direct InstantDB API
3. **Run Tests** to verify everything works
4. **Configure Google OAuth** in InstantDB dashboard

## Test Results

After running tests, you'll see:
- ✅ Which tests pass
- ❌ Which tests fail (and why)
- 📊 Test coverage report
- 🖼️ Screenshots of failures

## Debugging Failed Tests

1. **Check Flutter App**: Make sure it's running and accessible
2. **Check Selectors**: Update test selectors if UI changed
3. **Check API**: Verify InstantDB endpoints are correct
4. **View Screenshots**: Check `test-results/` folder for failure screenshots
5. **Run in UI Mode**: Use `npm run test:e2e:ui` for interactive debugging

## Continuous Integration

To run tests in CI:
```yaml
# Example GitHub Actions
- name: Install Playwright
  run: npx playwright install --with-deps

- name: Run tests
  run: npm run test:e2e
```

## Files Created

- ✅ `playwright.config.js` - Playwright configuration
- ✅ `tests/auth.spec.js` - Authentication flow tests
- ✅ `tests/api-endpoints.spec.js` - API endpoint tests
- ✅ `backend/instantdb-proxy.js` - Backend proxy service
- ✅ `BACKEND_SETUP.md` - Backend deployment guide
- ✅ `PLAYWRIGHT_SETUP.md` - This file

Everything is ready! Run `npm run test:e2e` to start testing.



