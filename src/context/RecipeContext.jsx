import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { generateRecipe } from '../services/recipeService';
import { db } from '../db/schema';

const RecipeContext = createContext();

export const useRecipe = () => {
  const context = useContext(RecipeContext);
  if (!context) {
    throw new Error('useRecipe must be used within RecipeProvider');
  }
  return context;
};

export const RecipeProvider = ({ children }) => {
  const [currentRecipe, setCurrentRecipe] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  // Use InstantDB's useQuery hook for reactive recipes
  const { data, isLoading: dbLoading } = db.useQuery({
    recipes: {
      $: {
        order: { createdAt: 'desc' }
      }
    }
  });

  // Debug logging for InstantDB query
  React.useEffect(() => {
    console.log('🔍 InstantDB Query Status:', { 
      isLoading: dbLoading, 
      hasData: !!data,
      recipesCount: data?.recipes ? Object.keys(data.recipes).length : 0
    });
    if (data?.recipes) {
      console.log('📦 Recipes from InstantDB:', Object.keys(data.recipes));
      console.log('📦 Recipe Data:', data.recipes);
    }
  }, [data, dbLoading]);

  // Transform InstantDB recipes to app format
  const recipes = React.useMemo(() => {
    if (!data?.recipes) {
      console.log('⚠️ No recipes found in InstantDB data');
      return {};
    }
    const recipesMap = {};
    Object.values(data.recipes).forEach(recipe => {
      recipesMap[recipe.recipeId] = {
        ...recipe,
        ingredients: Array.isArray(recipe.ingredients) ? recipe.ingredients : [],
        steps: Array.isArray(recipe.steps) ? recipe.steps : [],
        image: {
          type: 'url',
          value: recipe.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'
        },
        nutrition: recipe.calories ? { calories: recipe.calories } : null,
      };
    });
    console.log('✅ Transformed recipes:', Object.keys(recipesMap));
    return recipesMap;
  }, [data]);

  /**
   * Generate a new recipe from ingredients
   */
  const createRecipe = useCallback(async (ingredients) => {
    setIsLoading(true);
    setError(null);
    
    try {
      const recipe = await generateRecipe(ingredients);
      setCurrentRecipe(recipe);
      // Recipe will be automatically added to recipes via InstantDB useQuery
      return recipe;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, []);

  /**
   * Get recipe by ID
   */
  const getRecipe = useCallback((recipeId) => {
    return recipes[recipeId] || currentRecipe;
  }, [recipes, currentRecipe]);

  // Recipes are automatically loaded from InstantDB via useQuery
  const loadSavedRecipes = useCallback(async () => {
    // Recipes are already loaded via useQuery hook
    return Object.values(recipes);
  }, [recipes]);

  /**
   * Clear current recipe
   */
  const clearCurrentRecipe = useCallback(() => {
    setCurrentRecipe(null);
  }, []);

  const value = {
    currentRecipe,
    recipes,
    isLoading: isLoading || dbLoading,
    error,
    createRecipe,
    getRecipe,
    loadSavedRecipes,
    clearCurrentRecipe,
  };

  return (
    <RecipeContext.Provider value={value}>
      {children}
    </RecipeContext.Provider>
  );
};

