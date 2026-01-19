import { init, i, id } from '@instantdb/react';
import rules from '../../rules';

const schema = i.schema({
  entities: {
    users: i.entity({
      email: i.string().indexed(),
      passwordHash: i.string().optional(),
      passwordSalt: i.string().optional(),
      name: i.string().optional(),
      createdAt: i.number().indexed(),
      googleId: i.string().optional().indexed(),
      photoUrl: i.string().optional(),
    }),
    recipes: i.entity({
      recipeId: i.string().indexed(),
      userId: i.string().indexed(),
      dishName: i.string().indexed(),
      shortDescription: i.string(),
      imageUrl: i.string(),
      prepTimeMinutes: i.number().indexed(),
      difficulty: i.string().indexed(),
      calories: i.number().optional(),
      protein: i.number().optional(),
      carbohydrates: i.number().optional(),
      fats: i.number().optional(),
      ingredients: i.json(),
      steps: i.json(),
      cookingMethods: i.json().optional(),
      calorieAccuracyNote: i.string().optional(),
      sourceConfidence: i.string(),
      createdAt: i.number().indexed(),
    }),
  },
});

const APP_ID = '588227b6-6022-44a9-88f3-b1c2e2cce304';

export const db = init({ 
  appId: APP_ID,
  schema,
  rules // Add rules here
});

// Export id function for generating UUIDs
export { id };

export default schema;

