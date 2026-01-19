import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mock_recipe.dart';
import '../config/instantdb_config.dart';
import 'instantdb_service.dart';

class RecipeService {
  final InstantDBService _instantDB = InstantDBService();

  /// Transform LangChain agent response to Recipe model format
  Map<String, dynamic> transformLangChainResponse(Map<String, dynamic> langChainData) {
    final recipeData = langChainData['recipe'] as Map<String, dynamic>? ?? {};
    // Extract image_url from LangChain response - this is the actual generated image
    final imageUrl = langChainData['image_url'] as String?;
    final nutrition = langChainData['nutrition'] as Map<String, dynamic>? ?? {};
    
    // Extract time from instructions or use default
    final instructions = recipeData['instructions'] as List<dynamic>? ?? [];
    int estimatedTime = 30; // Default 30 minutes
    for (var instruction in instructions) {
      final instructionText = instruction.toString().toLowerCase();
      // Try to extract time mentions like "15 minutes", "cook for 20 min"
      final timeMatch = RegExp(r'(\d+)\s*(?:min|minute|minutes|דקות|דקה)').firstMatch(instructionText);
      if (timeMatch != null) {
        final extractedTime = int.tryParse(timeMatch.group(1) ?? '');
        if (extractedTime != null && extractedTime > estimatedTime) {
          estimatedTime = extractedTime;
        }
      }
    }
    
    // Default difficulty to medium
    String difficulty = 'medium';
    
    return {
      'dishName': recipeData['dish_name'] ?? 'Generated Recipe',
      'name': recipeData['dish_name'] ?? 'Generated Recipe',
      'shortDescription': '',
      'description': '',
      // Use LangChain image_url if available, otherwise null (let UI handle fallback)
      'imageUrl': (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : null,
      'estimatedPreparationTime': '$estimatedTime minutes',
      'time': estimatedTime,
      'prepTimeMinutes': estimatedTime,
      'difficultyLevel': difficulty,
      'difficulty': difficulty,
      'ingredientsUsed': recipeData['ingredients'] as List<dynamic>? ?? [],
      'ingredients': recipeData['ingredients'] as List<dynamic>? ?? [],
      'preparationSteps': instructions.map((e) => e.toString()).toList(),
      'steps': instructions.map((e) => e.toString()).toList(),
      'estimatedCaloricValue': nutrition['calories']?.toDouble()?.round(),
      'calories': nutrition['calories']?.toDouble()?.round(),
      'protein': nutrition['protein']?.toDouble(),
      'carbohydrates': nutrition['carbohydrates']?.toDouble(),
      'fats': nutrition['fats']?.toDouble(), // If not provided, can be calculated
      'cookingMethods': [],
      'calorieAccuracyNote': null,
    };
  }

  Future<Recipe> generateRecipe(List<String> ingredients) async {
    try {
      // Support both array and comma-separated string formats
      // Convert array to comma-separated string for LangChain agent
      final menuString = ingredients.join(',');
      
      // Call LangChain agent endpoint
      final response = await http.post(
        Uri.parse(InstantDBConfig.langChainUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'menu': menuString,
        }),
      );

      if (response.statusCode == 200) {
        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        final decodedData = jsonDecode(responseBody) as Map<String, dynamic>;
        
        // Transform LangChain response to Recipe model format
        final transformedData = transformLangChainResponse(decodedData);
        
        final recipe = Recipe.fromJson(transformedData);

        // Save to InstantDB
        try {
          await _instantDB.saveRecipe(recipe);
        } catch (e) {
          // Log error but don't fail the request
          print('Warning: Failed to save to InstantDB: $e');
        }

        return recipe;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to generate recipe: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Error generating recipe: $e');
    }
  }

  Future<List<Recipe>> getSavedRecipes() async {
    try {
      final recipes = await _instantDB.getRecipes();
      return recipes.map((json) => Recipe.fromJson(json, id: json['id']?.toString())).toList();
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }
}

