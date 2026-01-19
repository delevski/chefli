import axios from 'axios';
import CryptoJS from 'crypto-js';

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3000';

// Generate salt for password hashing (matching Flutter app)
const generateSalt = () => {
  const random = Date.now().toString();
  return CryptoJS.SHA256(random).toString();
};

// Hash password with salt (matching Flutter app)
const hashPassword = (password, salt) => {
  const bytes = CryptoJS.enc.Utf8.parse(password + salt);
  return CryptoJS.SHA256(bytes).toString();
};

// Validate email format
const isValidEmail = (email) => {
  return /^[^@]+@[^@]+\.[^@]+/.test(email);
};

// Validate password strength
const validatePassword = (password) => {
  if (password.length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
};

/**
 * Create account with email and password
 */
export const createAccount = async (email, password, name = null) => {
  try {
    // Validate email
    if (!isValidEmail(email)) {
      throw new Error('Invalid email address.');
    }

    // Validate password
    const passwordError = validatePassword(password);
    if (passwordError) {
      throw new Error(passwordError);
    }

    // Generate salt and hash password
    const salt = generateSalt();
    const passwordHash = hashPassword(password, salt);

    // Create user via backend proxy
    const response = await axios.post(
      `${BACKEND_URL}/api/users/create`,
      {
        email: email.toLowerCase().trim(),
        passwordHash,
        passwordSalt: salt,
        name: name?.trim() || null,
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    if (response.data.success && response.data.user) {
      // Store auth data in localStorage
      const user = {
        id: response.data.user.id,
        email: response.data.user.email,
        name: response.data.user.name,
      };
      localStorage.setItem('auth_user', JSON.stringify(user));
      localStorage.setItem('auth_token', response.data.user.id); // Use user ID as token
      return user;
    } else {
      throw new Error(response.data.error || 'Failed to create account');
    }
  } catch (error) {
    if (error.response?.data?.error) {
      throw new Error(error.response.data.error);
    }
    if (error.message.includes('already exists') || error.message.includes('duplicate')) {
      throw new Error('An account already exists with this email.');
    }
    throw error;
  }
};

/**
 * Sign in with email and password
 */
export const signInWithEmail = async (email, password) => {
  try {
    // Validate email
    if (!isValidEmail(email)) {
      throw new Error('Invalid email address.');
    }

    // Find user by email via backend proxy
    const findResponse = await axios.post(
      `${BACKEND_URL}/api/users/find`,
      {
        email: email.toLowerCase().trim(),
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    if (!findResponse.data.success || !findResponse.data.user) {
      throw new Error('Invalid email or password.');
    }

    const user = findResponse.data.user;

    // Verify password
    if (!user.passwordHash || !user.passwordSalt) {
      throw new Error('Invalid email or password.');
    }

    const passwordHash = hashPassword(password, user.passwordSalt);
    if (passwordHash !== user.passwordHash) {
      throw new Error('Invalid email or password.');
    }

    // Store auth data in localStorage
    const userData = {
      id: user.id,
      email: user.email,
      name: user.name,
    };
    localStorage.setItem('auth_user', JSON.stringify(userData));
    localStorage.setItem('auth_token', user.id); // Use user ID as token
    return userData;
  } catch (error) {
    if (error.response?.data?.error) {
      throw new Error(error.response.data.error);
    }
    if (error.message.includes('Invalid email or password')) {
      throw error;
    }
    throw new Error('Invalid email or password.');
  }
};

/**
 * Sign out
 */
export const signOut = () => {
  localStorage.removeItem('auth_user');
  localStorage.removeItem('auth_token');
};

/**
 * Get current user from localStorage
 */
export const getCurrentUser = () => {
  try {
    const userStr = localStorage.getItem('auth_user');
    if (!userStr) return null;
    return JSON.parse(userStr);
  } catch (error) {
    return null;
  }
};

/**
 * Check if user is logged in
 */
export const isLoggedIn = () => {
  return getCurrentUser() !== null;
};
