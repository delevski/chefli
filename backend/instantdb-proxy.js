/**
 * InstantDB Backend Proxy Service
 * 
 * Since InstantDB doesn't have a Flutter SDK, this Node.js backend service
 * acts as a proxy between Flutter and InstantDB, handling transactions and queries.
 * 
 * This can be deployed as a serverless function (Vercel, Netlify, etc.) or Express server.
 */

import { init, id } from '@instantdb/admin';

const APP_ID = '588227b6-6022-44a9-88f3-b1c2e2cce304';
const ADMIN_TOKEN = process.env.INSTANTDB_ADMIN_TOKEN || '8dce07c0-bfa7-49b3-b158-dc9b08294aca';

// Validate admin token
if (!ADMIN_TOKEN || ADMIN_TOKEN.trim() === '') {
  console.error('❌ INSTANTDB_ADMIN_TOKEN is not set or empty!');
  throw new Error('INSTANTDB_ADMIN_TOKEN environment variable is required');
}

const db = init({
  appId: APP_ID,
  adminToken: ADMIN_TOKEN.trim(), // Ensure no extra whitespace
});

/**
 * Create user account
 */
export async function createUser(email, passwordHash, passwordSalt, name) {
  try {
    const userId = id();
    const createdAt = Date.now();
    
    const transaction = [
      db.tx.users[userId].update({
        id: userId,
        email: email.toLowerCase().trim(),
        passwordHash,
        passwordSalt,
        name: name?.trim() || null,
        createdAt,
      }),
    ];
    
    await db.transact(transaction);
    
    return { id: userId, email: email.toLowerCase().trim(), name: name?.trim() || null, createdAt };
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
    const data = await db.query({
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
    const data = await db.query({
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
    const recipeId = id();
    const createdAt = Date.now();
    
    const transaction = [
      db.tx.recipes[recipeId].update({
        id: recipeId,
        recipeId,
        userId,
        ...recipeData,
        createdAt,
      }),
    ];
    
    await db.transact(transaction);
    
    return { id: recipeId, ...recipeData, createdAt };
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
      const transaction = [
        ['update', '$users', user.id, {
          name: name || user.name,
          photoUrl: photoUrl || user.photoUrl,
        }],
      ];
      await db.transact(transaction);
      return { ...user, name: name || user.name, photoUrl: photoUrl || user.photoUrl };
    }
    
    // Check if user exists by email (might have signed up with email/password)
    user = await findUserByEmail(email);
    
    if (user) {
      // Update existing user with Google ID
      const transaction = [
        ['update', '$users', user.id, {
          googleId,
          name: name || user.name,
          photoUrl: photoUrl || user.photoUrl,
        }],
      ];
      await db.transact(transaction);
      return { ...user, googleId, name: name || user.name, photoUrl: photoUrl || user.photoUrl };
    }
    
    // Create new user
    const userId = id();
    const createdAt = Date.now();
    
    const transaction = [
      ['update', '$users', userId, {
        id: userId,
        email: email.toLowerCase().trim(),
        googleId,
        name: name?.trim() || null,
        photoUrl: photoUrl || null,
        createdAt,
      }],
    ];
    
    await db.transact(transaction);
    
    return { id: userId, email: email.toLowerCase().trim(), googleId, name: name?.trim() || null, photoUrl: photoUrl || null, createdAt };
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
    const transaction = [
      db.tx.users[userId].update(updates),
    ];
    
    await db.transact(transaction);
    
    // Fetch updated user
    const data = await db.query({
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
    const data = await db.query({
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

