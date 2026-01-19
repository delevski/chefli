import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mock_recipe.dart';
import '../services/instantdb_service.dart';

class RecipeProvider extends ChangeNotifier {
  Recipe? _currentRecipe;
  final Map<String, Recipe> _recipes = {};
  final Set<String> _favoriteIds = {}; // Track favorite recipe IDs
  final InstantDBService _instantDB = InstantDBService();
  bool _isLoading = false;

  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  List<Recipe> get allRecipes => _recipes.values.toList();
  bool isFavorite(String recipeId) => _favoriteIds.contains(recipeId);

  RecipeProvider() {
    _loadSavedRecipes();
    _loadFavorites();
  }

  Recipe? getRecipe(String id) {
    return _recipes[id];
  }

  /// Load saved recipes from local storage
  Future<void> _loadSavedRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First, try to load from InstantDB
      try {
        final recipesJson = await _instantDB.getRecipes();
        for (var json in recipesJson) {
          try {
            final recipe = Recipe.fromJson(json, id: json['id']?.toString() ?? json['recipeId']?.toString());
            _recipes[recipe.id] = recipe;
          } catch (e) {
            print('Error loading recipe from InstantDB: $e');
          }
        }
        print('✅ Loaded ${_recipes.length} recipes from InstantDB');
      } catch (e) {
        print('⚠️ Could not load from InstantDB: $e');
      }
      
      // Also load from local SharedPreferences as backup
      try {
        final prefs = await SharedPreferences.getInstance();
        final recipesJson = prefs.getStringList('local_recipes') ?? [];
        for (var recipeStr in recipesJson) {
          try {
            final json = jsonDecode(recipeStr) as Map<String, dynamic>;
            final recipe = Recipe.fromJson(json, id: json['id']?.toString());
            // Only add if not already loaded from InstantDB
            if (!_recipes.containsKey(recipe.id)) {
              _recipes[recipe.id] = recipe;
            }
          } catch (e) {
            print('Error loading local recipe: $e');
          }
        }
        print('✅ Loaded ${recipesJson.length} recipes from local storage');
      } catch (e) {
        print('⚠️ Could not load local recipes: $e');
      }
      
      print('✅ Total loaded: ${_recipes.length} recipes');
    } catch (e) {
      print('❌ Error loading saved recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentRecipe(Recipe recipe) async {
    _currentRecipe = recipe;
    _recipes[recipe.id] = recipe;
    
    // Save to local SharedPreferences as backup
    await _saveRecipeLocally(recipe);
    
    // Save to InstantDB (may fail if user not logged in, but that's OK)
    try {
      await _instantDB.saveRecipe(recipe);
      print('✅ Recipe saved to InstantDB: ${recipe.name}');
    } catch (e) {
      print('⚠️ Recipe not saved to InstantDB (may need login): $e');
      // Continue anyway - recipe is saved locally
    }
    
    notifyListeners();
  }

  /// Save recipe to local SharedPreferences as backup
  Future<void> _saveRecipeLocally(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getStringList('local_recipes') ?? [];
      
      // Convert recipe to JSON
      final recipeJson = jsonEncode({
        'id': recipe.id,
        'name': recipe.name,
        'description': recipe.description,
        'imageUrl': recipe.imageUrl,
        'time': recipe.time,
        'difficulty': recipe.difficulty,
        'calories': recipe.calories,
        'protein': recipe.protein,
        'carbohydrates': recipe.carbohydrates,
        'fats': recipe.fats,
        'ingredients': recipe.ingredients.map((i) => {
          'name': i.name,
          'quantity': i.quantity,
        }).toList(),
        'steps': recipe.steps,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Remove existing recipe with same ID if present
      recipesJson.removeWhere((r) {
        try {
          final rJson = jsonDecode(r);
          return rJson['id'] == recipe.id;
        } catch (_) {
          return false;
        }
      });
      
      // Add new recipe
      recipesJson.add(recipeJson);
      
      // Save back to SharedPreferences
      await prefs.setStringList('local_recipes', recipesJson);
      print('✅ Recipe saved locally: ${recipe.name}');
    } catch (e) {
      print('❌ Error saving recipe locally: $e');
    }
  }

  void clearCurrentRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  /// Refresh recipes from storage
  Future<void> refreshRecipes() async {
    await _loadSavedRecipes();
  }

  /// Toggle favorite status for a recipe
  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }
    // Save favorites to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_recipe_ids', _favoriteIds.toList());
    notifyListeners();
  }

  /// Load favorites from storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_recipe_ids') ?? [];
      _favoriteIds.addAll(favoriteIds);
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }
}

