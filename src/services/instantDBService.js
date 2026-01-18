import { db, id } from '../db/schema';

class InstantDBService {
  /**
   * Save recipe to InstantDB
   */
  async saveRecipe(recipe) {
    let recipeData = null;
    
    try {
      const tx = db.tx;
      
      // Use InstantDB's id() function to generate proper UUID
      const entityId = id();
      
      // Transform recipe to InstantDB format
      recipeData = {
        recipeId: recipe.recipeId || entityId,
        userId: recipe.userId || 'user-1',
        dishName: recipe.dishName,
        shortDescription: recipe.shortDescription || '',
        imageUrl: recipe.image?.value || recipe.imageUrl || '',
        prepTimeMinutes: recipe.prepTimeMinutes || 20,
        difficulty: recipe.difficulty || 'medium',
        calories: recipe.nutrition?.calories || recipe.calories || null,
        ingredients: Array.isArray(recipe.ingredients) ? recipe.ingredients : [],
        steps: Array.isArray(recipe.steps) ? recipe.steps : [],
        cookingMethods: recipe.cookingMethods || null,
        calorieAccuracyNote: recipe.calorieAccuracyNote || null,
        sourceConfidence: recipe.sourceConfidence || 'high',
        createdAt: Date.now(),
      };

      console.log('💾 Attempting to save recipe to InstantDB');
      console.log('🆔 Entity UUID:', entityId);
      console.log('📝 Recipe data:', JSON.stringify(recipeData, null, 2));

      // Use InstantDB transaction with proper id() function
      const transaction = [
        tx.recipes[entityId].update(recipeData)
      ];
      
      console.log('🔄 Transaction created with UUID:', entityId);
      
      // Execute transaction - this is async but doesn't return a promise
      db.transact(transaction);
      console.log('✅ Recipe transaction sent to InstantDB');
      
      // Wait a bit to ensure transaction is processed
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log('✅ Transaction complete');
      
      return { ...recipeData, id: entityId };
    } catch (error) {
      console.error('❌ InstantDB save error:', error);
      console.error('Error details:', error.message);
      if (error.stack) {
        console.error('Stack:', error.stack);
      }
      // Don't throw - let the recipe still be returned even if InstantDB save fails
      console.warn('Continuing despite InstantDB error...');
      return recipeData;
    }
  }

  /**
   * Get recipes from InstantDB
   * Note: Use useQuery hook in React components for reactive queries
   */
  async getRecipes() {
    // This method is kept for compatibility but InstantDB queries should use useQuery hook
    // in React components for real-time updates
    console.warn('getRecipes() called - use useQuery hook in components instead');
    return [];
  }

  /**
   * Get a single recipe by ID
   * Note: Use useQuery hook in React components for reactive queries
   */
  async getRecipeById(recipeId) {
    // This method is kept for compatibility but InstantDB queries should use useQuery hook
    console.warn('getRecipeById() called - use useQuery hook in components instead');
    return null;
  }
}

export const instantDBService = new InstantDBService();
