/**
 * InstantDB Backend Proxy Service
 * 
 * Since InstantDB doesn't have a Flutter SDK, this Node.js backend service
 * acts as a proxy between Flutter and InstantDB, handling transactions and queries.
 * 
 * This can be deployed as a serverless function (Vercel, Netlify, etc.) or Express server.
 */

import { init, i, id } from '@instantdb/react';
import rules from '../rules.js';

const APP_ID = '588227b6-6022-44a9-88f3-b1c2e2cce304';

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
      ingredients: i.json(),
      steps: i.json(),
      cookingMethods: i.json().optional(),
      calorieAccuracyNote: i.string().optional(),
      sourceConfidence: i.string(),
      createdAt: i.number().indexed(),
    }),
  },
});

const db = init({
  appId: APP_ID,
  schema,
  rules,
});

/**
 * Create user account
 */
export async function createUser(email, passwordHash, passwordSalt, name) {
  try {
    const tx = db.tx;
    const userId = id();
    
    const transaction = [
      tx.users[userId].update({
        id: userId,
        email: email.toLowerCase().trim(),
        passwordHash,
        passwordSalt,
        name: name?.trim(),
        createdAt: Date.now(),
      }),
    ];
    
    db.transact(transaction);
    
    // Wait for transaction to complete
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return { id: userId, email, name, createdAt: Date.now() };
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}

/**
 * Find user by email
 */
export async function findUserByEmail(email) {
  try {
    // Use InstantDB query
    const { data } = await db.query({
      users: {
        $: {
          where: { email: email.toLowerCase().trim() },
        },
      },
    });
    
    return data?.users?.[0] || null;
  } catch (error) {
    console.error('Error finding user:', error);
    throw error;
  }
}

/**
 * Find user by Google ID
 */
export async function findUserByGoogleId(googleId) {
  try {
    const { data } = await db.query({
      users: {
        $: {
          where: { googleId },
        },
      },
    });
    
    return data?.users?.[0] || null;
  } catch (error) {
    console.error('Error finding user by Google ID:', error);
    throw error;
  }
}

/**
 * Save recipe
 */
export async function saveRecipe(recipeData, userId) {
  try {
    const tx = db.tx;
    const recipeId = id();
    
    const transaction = [
      tx.recipes[recipeId].update({
        id: recipeId,
        recipeId,
        userId,
        ...recipeData,
        createdAt: Date.now(),
      }),
    ];
    
    db.transact(transaction);
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return { id: recipeId, ...recipeData };
  } catch (error) {
    console.error('Error saving recipe:', error);
    throw error;
  }
}

/**
 * Create or update user with Google sign-in
 */
export async function createOrUpdateGoogleUser(email, googleId, name, photoUrl) {
  try {
    // First check if user exists by Google ID
    let user = await findUserByGoogleId(googleId);
    
    if (user) {
      // User exists, update if needed
      const tx = db.tx;
      const transaction = [
        tx.users[user.id].update({
          name: name || user.name,
          photoUrl: photoUrl || user.photoUrl,
        }),
      ];
      db.transact(transaction);
      await new Promise(resolve => setTimeout(resolve, 1000));
      return { ...user, name: name || user.name, photoUrl: photoUrl || user.photoUrl };
    }
    
    // Check if user exists by email (might have signed up with email/password)
    user = await findUserByEmail(email);
    
    if (user) {
      // Update existing user with Google ID
      const tx = db.tx;
      const transaction = [
        tx.users[user.id].update({
          googleId,
          name: name || user.name,
          photoUrl: photoUrl || user.photoUrl,
        }),
      ];
      db.transact(transaction);
      await new Promise(resolve => setTimeout(resolve, 1000));
      return { ...user, googleId, name: name || user.name, photoUrl: photoUrl || user.photoUrl };
    }
    
    // Create new user
    const tx = db.tx;
    const userId = id();
    const createdAt = Date.now();
    
    const transaction = [
      tx.users[userId].update({
        id: userId,
        email: email.toLowerCase().trim(),
        googleId,
        name: name?.trim(),
        photoUrl,
        createdAt,
      }),
    ];
    
    db.transact(transaction);
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return { id: userId, email: email.toLowerCase().trim(), googleId, name, photoUrl, createdAt };
  } catch (error) {
    console.error('Error creating/updating Google user:', error);
    throw error;
  }
}

/**
 * Update user
 */
export async function updateUser(userId, updates) {
  try {
    const tx = db.tx;
    const transaction = [
      tx.users[userId].update(updates),
    ];
    
    db.transact(transaction);
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Fetch updated user
    const { data } = await db.query({
      users: {
        $: {
          where: { id: userId },
        },
      },
    });
    
    return data?.users?.[0] || null;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}

/**
 * Get user recipes
 */
export async function getUserRecipes(userId) {
  try {
    const { data } = await db.query({
      recipes: {
        $: {
          where: { userId },
        },
      },
    });
    
    return data?.recipes || [];
  } catch (error) {
    console.error('Error getting recipes:', error);
    throw error;
  }
}

// Express.js example endpoint
export function setupExpressRoutes(app) {
  app.post('/api/users/create', async (req, res) => {
    try {
      const { email, passwordHash, passwordSalt, name } = req.body;
      const user = await createUser(email, passwordHash, passwordSalt, name);
      res.json({ success: true, user });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/api/users/find', async (req, res) => {
    try {
      const { email } = req.body;
      const user = await findUserByEmail(email);
      res.json({ success: true, user });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/api/recipes/save', async (req, res) => {
    try {
      const { recipeData, userId } = req.body;
      const recipe = await saveRecipe(recipeData, userId);
      res.json({ success: true, recipe });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/api/recipes/get', async (req, res) => {
    try {
      const { userId } = req.body;
      const recipes = await getUserRecipes(userId);
      res.json({ success: true, recipes });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/api/users/find-google', async (req, res) => {
    try {
      const { googleId } = req.body;
      const user = await findUserByGoogleId(googleId);
      res.json({ success: true, user });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/api/users/create-google', async (req, res) => {
    try {
      const { email, googleId, name, photoUrl } = req.body;
      const user = await createOrUpdateGoogleUser(email, googleId, name, photoUrl);
      res.json({ success: true, user });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.put('/api/users/update/:userId', async (req, res) => {
    try {
      const { userId } = req.params;
      const updates = req.body;
      const user = await updateUser(userId, updates);
      res.json({ success: true, user });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });
}

