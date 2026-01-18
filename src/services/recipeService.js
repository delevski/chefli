import axios from 'axios';
import { instantDBService } from './instantDBService';

const WEBHOOK_URL = 'https://hook.eu1.make.com/qvf4cgumvfdrsgo7yq61ddhtbzu5mxon';

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

  return {
    recipeId,
    userId: 'user-1', // You can get this from auth context
    dishName: apiResponse.dishName || apiResponse.name || 'Generated Recipe',
    shortDescription: apiResponse.shortDescription || apiResponse.description || '',
    image: {
      type: 'url',
      value: apiResponse.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'
    },
    prepTimeMinutes: parseTime(apiResponse.estimatedPreparationTime || apiResponse.time),
    difficulty: (apiResponse.difficultyLevel || apiResponse.difficulty || 'medium').toLowerCase(),
    ingredients: (apiResponse.ingredientsUsed || apiResponse.ingredients || []).map(ing => ({
      name: typeof ing === 'string' ? ing : ing.name || '',
      quantity: typeof ing === 'string' ? 'unknown' : ing.quantity || 'unknown'
    })),
    steps: apiResponse.preparationSteps || apiResponse.steps || [],
    cookingMethods: apiResponse.cookingMethods || [],
    nutrition: apiResponse.estimatedCaloricValue !== null && apiResponse.estimatedCaloricValue !== undefined
      ? { calories: parseCalories(apiResponse.estimatedCaloricValue) }
      : null,
    calorieAccuracyNote: apiResponse.calorieAccuracyNote,
    sourceConfidence: 'high'
  };
};

/**
 * Parse plain text response from Make.com webhook
 */
const parsePlainTextResponse = (text) => {
  const lines = text.split('\n').map(line => line.trim());

  const result = {
    dishName: '',
    shortDescription: '',
    ingredientsUsed: [],
    preparationSteps: [],
    cookingMethods: [],
    estimatedPreparationTime: '',
    difficultyLevel: '',
    estimatedCaloricValue: null,
    calorieAccuracyNote: ''
  };

  let currentSection = '';
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Skip empty lines
    if (!line) {
      i++;
      continue;
    }

    if (line.includes('Dish Name')) {
      // Get next non-empty line
      i++;
      while (i < lines.length && !lines[i]) i++;
      if (i < lines.length) {
        result.dishName = lines[i];
      }
    } else if (line.includes('Short Description')) {
      // Get description (may span multiple lines)
      i++;
      const descLines = [];
      while (i < lines.length && lines[i] && !lines[i].includes('Ingredients Used') && !lines[i].includes('Preparation Steps') && !lines[i].includes('Cooking Method')) {
        descLines.push(lines[i]);
        i++;
      }
      result.shortDescription = descLines.join(' ').trim();
      continue; // Don't increment i again
    } else if (line.includes('Ingredients Used')) {
      currentSection = 'ingredients';
    } else if (line.includes('Preparation Steps')) {
      currentSection = 'steps';
    } else if (line.includes('Cooking Method')) {
      currentSection = 'cookingMethods';
    } else if (line.includes('Estimated Preparation Time')) {
      i++;
      while (i < lines.length && !lines[i]) i++;
      if (i < lines.length) {
        result.estimatedPreparationTime = lines[i];
      }
    } else if (line.includes('Difficulty Level')) {
      i++;
      while (i < lines.length && !lines[i]) i++;
      if (i < lines.length) {
        result.difficultyLevel = lines[i];
      }
    } else if (line.includes('Estimated Caloric Value')) {
      i++;
      while (i < lines.length && !lines[i]) i++;
      if (i < lines.length) {
        const calLine = lines[i];
        if (calLine.toLowerCase().includes('cannot') || calLine.toLowerCase().includes('unknown')) {
          result.estimatedCaloricValue = null;
        } else {
          const match = calLine.match(/(\d+)/);
          result.estimatedCaloricValue = match ? parseInt(match[1], 10) : null;
        }
      }
    } else if (line.includes('Calorie Accuracy Note')) {
      i++;
      while (i < lines.length && !lines[i]) i++;
      if (i < lines.length) {
        result.calorieAccuracyNote = lines[i];
      }
    } else if (currentSection === 'ingredients' && line.startsWith('-')) {
      const ingName = line.substring(1).trim();
      result.ingredientsUsed.push({ name: ingName, quantity: 'unknown' });
    } else if (currentSection === 'steps' && /^\d+\./.test(line)) {
      result.preparationSteps.push(line.replace(/^\d+\.\s*/, ''));
    } else if (currentSection === 'cookingMethods' && line.trim() && !line.includes('Preparation Steps')) {
      result.cookingMethods.push(line.trim());
    }

    i++;
  }

  return result;
};

/**
 * Generate recipe from ingredients using Make.com webhook
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

    // Call Make.com webhook - handle both JSON and plain text responses
    const response = await axios.post(
      WEBHOOK_URL,
      { ingredients: ingredientsList },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        responseType: 'text', // Force text response to handle plain text
      }
    );

    if (response.status === 200 && response.data) {
      let responseData;

      // Try to parse as JSON first
      try {
        responseData = JSON.parse(response.data);
      } catch (e) {
        // If not JSON, parse as plain text
        responseData = parsePlainTextResponse(response.data);
      }

      // Handle array response (if API returns multiple options)
      if (Array.isArray(responseData) && responseData.length > 0) {
        responseData = responseData[0];
      }

      const recipe = transformRecipe(responseData);

      // Save to InstantDB (non-blocking)
      try {
        await instantDBService.saveRecipe(recipe);
      } catch (error) {
        console.warn('Failed to save to InstantDB:', error);
        // Don't fail the request if InstantDB save fails
      }

      return recipe;
    } else {
      throw new Error('Invalid response from recipe service');
    }
  } catch (error) {
    console.error('Recipe generation error:', error);
    if (error.response) {
      // Try to parse error response
      let errorMessage = `API Error: ${error.response.status}`;
      if (error.response.data) {
        if (typeof error.response.data === 'string') {
          errorMessage += ` - ${error.response.data.substring(0, 100)}`;
        } else {
          errorMessage += ` - ${JSON.stringify(error.response.data).substring(0, 100)}`;
        }
      }
      throw new Error(errorMessage);
    } else if (error.request) {
      throw new Error('Network error: Could not reach recipe service');
    } else {
      throw new Error(`Error: ${error.message}`);
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

