import 'package:flutter/foundation.dart';
import '../models/mock_recipe.dart';
import '../services/instantdb_service.dart';

class RecipeProvider extends ChangeNotifier {
  Recipe? _currentRecipe;
  final Map<String, Recipe> _recipes = {};
  final InstantDBService _instantDB = InstantDBService();
  bool _isLoading = false;

  Recipe? get currentRecipe => _currentRecipe;
  bool get isLoading => _isLoading;
  List<Recipe> get allRecipes => _recipes.values.toList();

  RecipeProvider() {
    _loadSavedRecipes();
  }

  Recipe? getRecipe(String id) {
    return _recipes[id];
  }

  /// Load saved recipes from local storage
  Future<void> _loadSavedRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipesJson = await _instantDB.getRecipes();
      for (var json in recipesJson) {
        try {
          final recipe = Recipe.fromJson(json, id: json['id']?.toString() ?? json['recipeId']?.toString());
          _recipes[recipe.id] = recipe;
        } catch (e) {
          print('Error loading recipe: $e');
        }
      }
      print('✅ Loaded ${_recipes.length} recipes from storage');
    } catch (e) {
      print('❌ Error loading saved recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentRecipe(Recipe recipe) {
    _currentRecipe = recipe;
    _recipes[recipe.id] = recipe;
    // Save to local storage
    _instantDB.saveRecipe(recipe).then((_) {
      print('✅ Recipe saved: ${recipe.name}');
    }).catchError((e) {
      print('❌ Error saving recipe: $e');
    });
    notifyListeners();
  }

  void clearCurrentRecipe() {
    _currentRecipe = null;
    notifyListeners();
  }

  /// Refresh recipes from storage
  Future<void> refreshRecipes() async {
    await _loadSavedRecipes();
  }
}

