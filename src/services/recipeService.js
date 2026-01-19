import axios from 'axios';
import { instantDBService } from './instantDBService';

// Use backend proxy to avoid CORS issues
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3000';
const LANGCHAIN_URL = `${BACKEND_URL}/api/recipes/generate`;

/**
 * Parse time string like "15–25 minutes" or "15-25 minutes" to number
 */
const parseTime = (timeStr) => {
  if (!timeStr) return 20;
  const match = timeStr.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : 20;
};

/**
 * Parse calories from various formats
 */
const parseCalories = (caloriesValue) => {
  if (caloriesValue === null || caloriesValue === undefined) return null;
  if (typeof caloriesValue === 'number') return caloriesValue;
  if (typeof caloriesValue === 'string') {
    const match = caloriesValue.match(/(\d+)/);
    return match ? parseInt(match[1], 10) : null;
  }
  return null;
};

/**
 * Transform API response to app recipe format
 */
const transformRecipe = (apiResponse, id = null) => {
  const recipeId = id || Date.now().toString();

  // Build nutrition object with all available fields
  const nutrition = {};
  if (apiResponse.estimatedCaloricValue !== null && apiResponse.estimatedCaloricValue !== undefined) {
    nutrition.calories = parseCalories(apiResponse.estimatedCaloricValue);
  } else if (apiResponse.calories !== null && apiResponse.calories !== undefined) {
    nutrition.calories = parseCalories(apiResponse.calories);
  }
  if (apiResponse.protein !== null && apiResponse.protein !== undefined) {
    nutrition.protein = typeof apiResponse.protein === 'number' ? apiResponse.protein : parseFloat(apiResponse.protein);
  }
  if (apiResponse.carbohydrates !== null && apiResponse.carbohydrates !== undefined) {
    nutrition.carbohydrates = typeof apiResponse.carbohydrates === 'number' ? apiResponse.carbohydrates : parseFloat(apiResponse.carbohydrates);
  }
  if (apiResponse.fats !== null && apiResponse.fats !== undefined) {
    nutrition.fats = typeof apiResponse.fats === 'number' ? apiResponse.fats : parseFloat(apiResponse.fats);
  }

  return {
    recipeId,
    userId: 'user-1', // You can get this from auth context
    dishName: apiResponse.dishName || apiResponse.name || 'Generated Recipe',
    shortDescription: apiResponse.shortDescription || apiResponse.description || '',
    image: {
      type: 'url',
      // Use imageUrl if available, otherwise fallback to default
      value: apiResponse.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'
    },
    imageUrl: apiResponse.imageUrl, // Also include imageUrl directly for compatibility
    prepTimeMinutes: parseTime(apiResponse.estimatedPreparationTime || apiResponse.time),
    difficulty: (apiResponse.difficultyLevel || apiResponse.difficulty || 'medium').toLowerCase(),
    ingredients: (apiResponse.ingredientsUsed || apiResponse.ingredients || []).map(ing => ({
      name: typeof ing === 'string' ? ing : (ing.name || ''),
      quantity: typeof ing === 'string' ? 'unknown' : (ing.quantity || 'unknown')
    })),
    steps: apiResponse.preparationSteps || apiResponse.steps || [],
    cookingMethods: apiResponse.cookingMethods || [],
    nutrition: Object.keys(nutrition).length > 0 ? nutrition : null,
    calorieAccuracyNote: apiResponse.calorieAccuracyNote,
    sourceConfidence: 'high'
  };
};

/**
 * Transform LangChain agent response to app recipe format
 */
const transformLangChainResponse = (langChainData) => {
  const recipeData = langChainData.recipe || {};
  const imageUrl = langChainData.image_url;
  const nutrition = langChainData.nutrition || {};
  
  // Extract time from instructions or use default
  const instructions = recipeData.instructions || [];
  let estimatedTime = 30; // Default 30 minutes
  for (const instruction of instructions) {
    const instructionText = String(instruction).toLowerCase();
    // Try to extract time mentions like "15 minutes", "cook for 20 min"
    const timeMatch = instructionText.match(/(\d+)\s*(?:min|minute|minutes|דקות|דקה)/);
    if (timeMatch) {
      const extractedTime = parseInt(timeMatch[1], 10);
      if (extractedTime && extractedTime > estimatedTime) {
        estimatedTime = extractedTime;
      }
    }
  }
  
  // Default difficulty to medium
  const difficulty = 'medium';
  
  return {
    dishName: recipeData.dish_name || 'Generated Recipe',
    name: recipeData.dish_name || 'Generated Recipe',
    shortDescription: '',
    description: '',
    // Use LangChain image_url if available, otherwise null (let UI handle fallback)
    imageUrl: (imageUrl && imageUrl.trim() !== '') ? imageUrl : null,
    estimatedPreparationTime: `${estimatedTime} minutes`,
    time: estimatedTime,
    prepTimeMinutes: estimatedTime,
    difficultyLevel: difficulty,
    difficulty: difficulty,
    ingredientsUsed: recipeData.ingredients || [],
    ingredients: recipeData.ingredients || [],
    preparationSteps: instructions.map(e => String(e)),
    steps: instructions.map(e => String(e)),
    estimatedCaloricValue: nutrition.calories ? Math.round(nutrition.calories) : null,
    calories: nutrition.calories ? Math.round(nutrition.calories) : null,
    // Extract protein, carbohydrates, and fats from nutrition object
    protein: nutrition.protein ? parseFloat(nutrition.protein) : null,
    carbohydrates: nutrition.carbohydrates ? parseFloat(nutrition.carbohydrates) : null,
    fats: nutrition.fats ? parseFloat(nutrition.fats) : null,
    cookingMethods: [],
    calorieAccuracyNote: null,
  };
};

/**
 * Generate recipe from ingredients using LangChain agent
 */
export const generateRecipe = async (ingredients) => {
  try {
    // Parse ingredients from string or array
    const ingredientsList = Array.isArray(ingredients)
      ? ingredients
      : ingredients.split(',').map(ing => ing.trim()).filter(ing => ing.length > 0);

    if (ingredientsList.length === 0) {
      throw new Error('Please provide at least one ingredient');
    }

    // Support both request formats: convert array to comma-separated string for LangChain
    const menuString = ingredientsList.join(',');

    // Call backend proxy endpoint (which forwards to LangChain agent to avoid CORS)
    const response = await axios.post(
      LANGCHAIN_URL,
      { menu: menuString },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    if (response.status === 200 && response.data) {
      // Transform LangChain response to Recipe model format
      const transformedData = transformLangChainResponse(response.data);
      const recipe = transformRecipe(transformedData);

      // Save to InstantDB (non-blocking)
      try {
        await instantDBService.saveRecipe(recipe);
      } catch (error) {
        console.warn('Warning: Failed to save to InstantDB:', error);
        // Don't fail the request if InstantDB save fails
      }

      return recipe;
    } else {
      const errorBody = response.data ? JSON.stringify(response.data) : 'Unknown error';
      throw new Error(`Failed to generate recipe: ${response.status} - ${errorBody}`);
    }
  } catch (error) {
    console.error('Recipe generation error:', error);
    if (error.response) {
      // Try to parse error response - axios handles UTF-8 automatically
      let errorMessage = `Failed to generate recipe: ${error.response.status}`;
      if (error.response.data) {
        if (typeof error.response.data === 'string') {
          errorMessage += ` - ${error.response.data.substring(0, 200)}`;
        } else {
          errorMessage += ` - ${JSON.stringify(error.response.data).substring(0, 200)}`;
        }
      }
      throw new Error(errorMessage);
    } else if (error.request) {
      throw new Error('Network error: Could not reach recipe service');
    } else {
      throw new Error(`Error generating recipe: ${error.message}`);
    }
  }
};

/**
 * Get saved recipes from InstantDB
 */
export const getSavedRecipes = async () => {
  try {
    const recipes = await instantDBService.getRecipes();
    return recipes.map(recipe => transformRecipe(recipe, recipe.recipeId || recipe.id));
  } catch (error) {
    console.error('Error fetching saved recipes:', error);
    return [];
  }
};

