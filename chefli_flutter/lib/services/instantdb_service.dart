import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mock_recipe.dart';
import 'instantdb_auth_service.dart';

/// InstantDB Service for Flutter
/// Uses InstantDB REST API to store and retrieve recipes
class InstantDBService {
  static const String _baseUrl = 'https://api.instantdb.com';
  static const String appId = '588227b6-6022-44a9-88f3-b1c2e2cce304';
  static const String _authTokenKey = 'instantdb_auth_token';

  final InstantDBAuthService _authService = InstantDBAuthService();

  /// Get auth token from local storage
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Get current user ID
  Future<String?> _getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  /// Save recipe to InstantDB
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User must be logged in to save recipes');
      }

      final authToken = await _getAuthToken();
      
      // Prepare recipe data
      final recipeData = {
        'id': recipe.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'recipeId': recipe.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'dishName': recipe.name,
        'shortDescription': recipe.description ?? '',
        'imageUrl': recipe.imageUrl ?? '',
        'prepTimeMinutes': recipe.time,
        'difficulty': recipe.difficulty,
        'calories': recipe.calories,
        'ingredients': recipe.ingredients.map((i) => {
          'name': i.name,
          'quantity': i.quantity,
        }).toList(),
        'steps': recipe.steps,
        'sourceConfidence': 'high',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to InstantDB using REST API
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/apps/$appId/entities/recipes'),
        headers: headers,
        body: jsonEncode(recipeData),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorMsg = errorBody.isNotEmpty 
            ? errorBody 
            : 'Failed to save recipe (${response.statusCode})';
        throw Exception(errorMsg);
      }

      print('✅ Recipe saved to InstantDB: ${recipe.name} (ID: ${recipe.id})');
    } catch (e) {
      print('❌ Error saving recipe to InstantDB: $e');
      rethrow;
    }
  }

  /// Get all saved recipes from InstantDB
  Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return [];
      }

      final authToken = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      // Query recipes for current user
      final response = await http.get(
        Uri.parse('$_baseUrl/apps/$appId/entities/recipes?userId=$userId'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⚠️ Request timeout while fetching recipes');
          return http.Response('', 408);
        },
      );

      if (response.statusCode != 200) {
        final errorBody = utf8.decode(response.bodyBytes);
        print('⚠️ Failed to fetch recipes: ${response.statusCode} - $errorBody');
        return [];
      }

      // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      List<dynamic> recipes = [];
      
      // Handle different response formats
      if (data is Map && data.containsKey('data')) {
        recipes = data['data'] as List<dynamic>;
      } else if (data is List) {
        recipes = data;
      }

      print('📖 Loaded ${recipes.length} recipes from InstantDB');
      return recipes.map((r) => r as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error loading recipes from InstantDB: $e');
      return [];
    }
  }

  /// Get a single recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final authToken = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/apps/$appId/entities/recipes/$id'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⚠️ Request timeout while fetching recipe');
          return http.Response('', 408);
        },
      );

      if (response.statusCode != 200) {
        final errorBody = utf8.decode(response.bodyBytes);
        print('⚠️ Failed to fetch recipe: ${response.statusCode} - $errorBody');
        return null;
      }

      // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      Map<String, dynamic> recipeJson;
      
      if (data is Map) {
        recipeJson = Map<String, dynamic>.from(data);
      } else {
        return null;
      }

      // Convert InstantDB format to Recipe model
      return Recipe.fromJson({
        'id': recipeJson['id'] ?? recipeJson['recipeId'],
        'dishName': recipeJson['dishName'],
        'shortDescription': recipeJson['shortDescription'],
        'imageUrl': recipeJson['imageUrl'],
        'estimatedPreparationTime': recipeJson['prepTimeMinutes']?.toString() ?? '${recipeJson['prepTimeMinutes'] ?? 20} minutes',
        'difficultyLevel': recipeJson['difficulty'],
        'estimatedCaloricValue': recipeJson['calories'],
        'ingredientsUsed': recipeJson['ingredients'],
        'preparationSteps': recipeJson['steps'],
      }, id: id);
    } catch (e) {
      print('❌ Error loading recipe by ID: $e');
      return null;
    }
  }

  /// Delete a recipe by ID
  Future<void> deleteRecipe(String id) async {
    try {
      final authToken = await _getAuthToken();
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/apps/$appId/entities/recipes/$id'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorMsg = errorBody.isNotEmpty 
            ? errorBody 
            : 'Failed to delete recipe (${response.statusCode})';
        throw Exception(errorMsg);
      }

      print('🗑️ Recipe deleted from InstantDB: $id');
    } catch (e) {
      print('❌ Error deleting recipe: $e');
      rethrow;
    }
  }

  /// Clear all recipes (delete all recipes for current user)
  Future<void> clearAllRecipes() async {
    try {
      final recipes = await getRecipes();
      for (final recipe in recipes) {
        final id = recipe['id'] ?? recipe['recipeId'];
        if (id != null) {
          await deleteRecipe(id.toString());
        }
      }
      print('🗑️ All recipes cleared from InstantDB');
    } catch (e) {
      print('❌ Error clearing recipes: $e');
      rethrow;
    }
  }
}
