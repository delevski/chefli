// InstantDB Configuration
// Generated automatically - update values as needed

class InstantDBConfig {
  // InstantDB App ID (from your dashboard)
  static const String appId = '588227b6-6022-44a9-88f3-b1c2e2cce304';
  
  // Base URL for InstantDB API
  // Note: InstantDB uses WebSocket transactions, not REST API
  // For Flutter, use a backend proxy or InstantDB Admin HTTP API
  static const String baseUrl = 'https://api.instantdb.com';
  
  // Backend Proxy Configuration
  // Set to true if using the backend proxy service
  // Set to false to use InstantDB Admin HTTP API directly
  static const bool useBackendProxy = false;
  static const String backendUrl = 'http://localhost:3000'; // Update with your backend URL
  
  // InstantDB Admin HTTP API Configuration
  // Get ADMIN_TOKEN from InstantDB Dashboard: https://www.instantdb.com/dash
  // Go to your app -> Settings -> API Keys
  static const String adminToken = '8dce07c0-bfa7-49b3-b158-dc9b08294aca';
  
  // Auth Configuration
  static const bool emailPasswordEnabled = true;
  static const bool hashPasswordOnServer = true; // Recommended: hash passwords server-side
  
  // Google OAuth Configuration
  static const bool googleOAuthEnabled = true;
  // Get these from Google Cloud Console and InstantDB dashboard
  // Package Name: com.example.chefli_flutter
  // SHA-1 (Debug): 56:2B:F0:B5:DB:B6:6F:F0:41:6B:55:40:2F:8C:A3:5C:F0:1C:7C:6C
  // See GOOGLE_OAUTH_SETUP.md for complete setup instructions
  static const String googleClientId = ''; // Add your Google Client ID from Google Cloud Console
  static const String googleRedirectUri = 'http://localhost:8080/auth/google/callback';
  
  // Backend API Endpoints (if using backend proxy)
  static const String createUserEndpoint = '/api/users/create';
  static const String findUserEndpoint = '/api/users/find';
  static const String findUserByGoogleIdEndpoint = '/api/users/find-google';
  static const String saveRecipeEndpoint = '/api/recipes/save';
  static const String getRecipesEndpoint = '/api/recipes/get';
  static const String deleteRecipeEndpoint = '/api/recipes/delete';
  
  // LangChain Agent Configuration
  // LangChain agent endpoint for recipe generation
  static const String langChainUrl = 'https://ordi1985.pythonanywhere.com/generate-recipe';
}

