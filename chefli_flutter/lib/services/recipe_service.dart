import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mock_recipe.dart';
import 'instantdb_service.dart';

class RecipeService {
  static const String webhookUrl = 'https://hook.eu1.make.com/qvf4cgumvfdrsgo7yq61ddhtbzu5mxon';
  final InstantDBService _instantDB = InstantDBService();

  Future<Recipe> generateRecipe(List<String> ingredients) async {
    try {
      // Call Make.com webhook
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 200) {
        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        final decodedData = jsonDecode(responseBody);
        
        // Handle different response formats
        Map<String, dynamic> jsonData;
        
        if (decodedData is Map<String, dynamic>) {
          // Check if response has "alternatives" array
          if (decodedData.containsKey('alternatives') && decodedData['alternatives'] is List) {
            final alternatives = decodedData['alternatives'] as List;
            if (alternatives.isNotEmpty) {
              // Take the first recipe from the alternatives array
              jsonData = alternatives[0] as Map<String, dynamic>;
            } else {
              throw Exception('No recipes found in alternatives array');
            }
          } else {
            // Single recipe object (direct Map)
            jsonData = decodedData;
          }
        } else if (decodedData is List && decodedData.isNotEmpty) {
          // Direct array of recipes - take the first one
          jsonData = decodedData[0] as Map<String, dynamic>;
        } else {
          throw Exception('Invalid response format from recipe service');
        }
        
        final recipe = Recipe.fromJson(jsonData);

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

