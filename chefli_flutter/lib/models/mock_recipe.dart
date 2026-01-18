class Recipe {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int time;
  final String difficulty;
  final int? calories;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String>? cookingMethods;
  final String? calorieAccuracyNote;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.time,
    required this.difficulty,
    this.calories,
    required this.ingredients,
    required this.steps,
    this.cookingMethods,
    this.calorieAccuracyNote,
  });

  // Factory constructor from JSON (API response)
  factory Recipe.fromJson(Map<String, dynamic> json, {String? id}) {
    // Parse time from string like "15–25 minutes" or "15-25 minutes"
    int parseTime(String? timeStr) {
      if (timeStr == null) return 20;
      final match = RegExp(r'(\d+)').firstMatch(timeStr);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '20') ?? 20;
      }
      return 20;
    }

    // Parse calories
    int? parseCalories(dynamic caloriesValue) {
      if (caloriesValue == null) return null;
      if (caloriesValue is int) return caloriesValue;
      if (caloriesValue is String) {
        final match = RegExp(r'(\d+)').firstMatch(caloriesValue);
        if (match != null) {
          return int.tryParse(match.group(1) ?? '');
        }
      }
      return null;
    }

    return Recipe(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['dishName'] ?? json['name'] ?? 'Generated Recipe',
      description: json['shortDescription'] ?? json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      time: parseTime(json['estimatedPreparationTime'] ?? json['time']?.toString()),
      difficulty: (json['difficultyLevel'] ?? json['difficulty'] ?? 'medium').toString().toLowerCase(),
      calories: parseCalories(json['estimatedCaloricValue'] ?? json['calories']),
      ingredients: (json['ingredientsUsed'] ?? json['ingredients'] ?? []).map<Ingredient>((ing) {
        if (ing is Map) {
          return Ingredient(ing['name'] ?? '', ing['quantity'] ?? 'unknown');
        }
        return Ingredient(ing.toString(), 'unknown');
      }).toList(),
      steps: List<String>.from(json['preparationSteps'] ?? json['steps'] ?? []),
      cookingMethods: json['cookingMethods'] != null 
          ? List<String>.from(json['cookingMethods'])
          : null,
      calorieAccuracyNote: json['calorieAccuracyNote'],
    );
  }

  // Convert to JSON for InstantDB
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeId': id, // Also include recipeId for compatibility
      'dishName': name,
      'name': name, // Include both for compatibility
      'shortDescription': description,
      'description': description, // Include both for compatibility
      'imageUrl': imageUrl,
      'estimatedPreparationTime': '$time minutes',
      'prepTimeMinutes': time, // Include numeric version
      'time': time, // Include simple version
      'difficultyLevel': difficulty,
      'difficulty': difficulty, // Include both for compatibility
      'estimatedCaloricValue': calories,
      'calories': calories, // Include both for compatibility
      'ingredientsUsed': ingredients.map((ing) => {
        'name': ing.name,
        'quantity': ing.quantity,
      }).toList(),
      'ingredients': ingredients.map((ing) => {
        'name': ing.name,
        'quantity': ing.quantity,
      }).toList(), // Include both for compatibility
      'preparationSteps': steps,
      'steps': steps, // Include both for compatibility
      'cookingMethods': cookingMethods ?? [],
      'calorieAccuracyNote': calorieAccuracyNote,
    };
  }
}

class Ingredient {
  final String name;
  final String quantity;

  Ingredient(this.name, this.quantity);
}

// Mock Data
final mockRecipe = Recipe(
  id: "demo-123",
  name: "Creamy Tomato Basil Pasta",
  description: "A delicious creamy pasta dish with fresh tomatoes and basil.",
  imageUrl: "https://images.unsplash.com/photo-1626844131082-256783844137?auto=format&fit=crop&w=1000&q=80",
  time: 25,
  difficulty: "Medium",
  calories: 650,
  ingredients: [
    Ingredient("Pasta", "400g"),
    Ingredient("Fresh Basil", "1 bunch"),
    Ingredient("Cherry Tomatoes", "200g"),
    Ingredient("Heavy Cream", "150ml"),
    Ingredient("Garlic", "2 cloves"),
    Ingredient("Parmesan", "50g"),
  ],
  steps: [
    "Boil a large pot of salted water. Add pasta and cook until al dente.",
    "While pasta cooks, heat olive oil in a pan. Sauté minced garlic until fragrant (1 min).",
    "Add cherry tomatoes to the pan and cook until soft and blistering (5 mins).",
    "Pour in heavy cream and simmer gently for 3 minutes. Season with salt and pepper.",
    "Drain pasta (reserve some water) and toss into the sauce.",
    "Stir in fresh basil and parmesan cheese. Serve hot.",
  ],
);
