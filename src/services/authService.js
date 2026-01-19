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

/**
 * Sign in with Google using Google Identity Services
 */
export const signInWithGoogle = async () => {
  return new Promise((resolve, reject) => {
    // Check if Google Identity Services is loaded
    if (typeof window.google === 'undefined' || !window.google.accounts) {
      reject(new Error('Google Identity Services not loaded. Please check your Google Client ID configuration.'));
      return;
    }

    const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
    if (!clientId) {
      reject(new Error('Google Client ID not configured. Please set VITE_GOOGLE_CLIENT_ID in your .env file.'));
      return;
    }

    // Initialize Google Identity Services
    window.google.accounts.id.initialize({
      client_id: clientId,
      callback: async (response) => {
        try {
          // Decode the credential to get user info
          const credential = response.credential;
          
          // Decode JWT token (basic decode, Google provides user info)
          // Note: In production, you should verify the token on the backend
          const base64Url = credential.split('.')[1];
          const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
          const jsonPayload = decodeURIComponent(
            atob(base64)
              .split('')
              .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
              .join('')
          );
          const userInfo = JSON.parse(jsonPayload);

          // Extract user data
          const email = userInfo.email;
          const name = userInfo.name;
          const googleId = userInfo.sub;
          const photoUrl = userInfo.picture;

          if (!email || !googleId) {
            reject(new Error('Failed to get user information from Google.'));
            return;
          }

          // Create or update user via backend proxy
          const createResponse = await axios.post(
            `${BACKEND_URL}/api/users/create-google`,
            {
              email: email.toLowerCase().trim(),
              googleId,
              name: name?.trim() || null,
              photoUrl: photoUrl || null,
            },
            {
              headers: {
                'Content-Type': 'application/json',
              },
            }
          );

          if (createResponse.data.success && createResponse.data.user) {
            // Store auth data in localStorage
            const user = {
              id: createResponse.data.user.id,
              email: createResponse.data.user.email,
              name: createResponse.data.user.name,
              photoUrl: createResponse.data.user.photoUrl || photoUrl || null,
            };
            localStorage.setItem('auth_user', JSON.stringify(user));
            localStorage.setItem('auth_token', createResponse.data.user.id);
            resolve(user);
          } else {
            reject(new Error(createResponse.data.error || 'Failed to sign in with Google.'));
          }
        } catch (error) {
          if (error.response?.data?.error) {
            reject(new Error(error.response.data.error));
          } else {
            reject(new Error(`Failed to sign in with Google: ${error.message}`));
          }
        }
      },
    });

    // Prompt user to sign in
    window.google.accounts.id.prompt((notification) => {
      if (notification.isNotDisplayed() || notification.isSkippedMoment()) {
        // Fallback: use one tap or button flow
        window.google.accounts.id.renderButton(
          document.getElementById('google-signin-button'),
          {
            theme: 'outline',
            size: 'large',
            width: '100%',
          }
        );
        reject(new Error('Please click the Google Sign-In button to continue.'));
      }
    });
  });
};

/**
 * Trigger Google Sign-In using credential from Google Identity Services
 * This is called when the user clicks the Google Sign-In button
 */
export const triggerGoogleSignIn = async () => {
  const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
  if (!clientId) {
    throw new Error('Google Client ID not configured. Please set VITE_GOOGLE_CLIENT_ID in your .env file.');
  }

  if (typeof window.google === 'undefined' || !window.google.accounts) {
    throw new Error('Google Identity Services not loaded. Please wait a moment and try again.');
  }

  // This function will be called by the Google Sign-In button callback
  // The actual sign-in is handled by the button's callback in LoginPage
  // This is a placeholder that will be replaced by the actual credential handling
  return new Promise((resolve, reject) => {
    // The actual implementation happens in LoginPage via the button callback
    // This function exists for compatibility with AuthContext
    reject(new Error('Google Sign-In should be triggered via the button.'));
  });
};

/**
 * Handle Google Sign-In with credential token
 */
export const handleGoogleCredential = async (credential) => {
  try {
    // Decode JWT token to get user info
    const base64Url = credential.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );
    const userInfo = JSON.parse(jsonPayload);

    const email = userInfo.email;
    const name = userInfo.name;
    const googleId = userInfo.sub;
    const photoUrl = userInfo.picture;

    if (!email || !googleId) {
      throw new Error('Failed to get user information from Google.');
    }

    // Create or update user via backend proxy
    const createResponse = await axios.post(
      `${BACKEND_URL}/api/users/create-google`,
      {
        email: email.toLowerCase().trim(),
        googleId,
        name: name?.trim() || null,
        photoUrl: photoUrl || null,
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    if (createResponse.data.success && createResponse.data.user) {
      const user = {
        id: createResponse.data.user.id,
        email: createResponse.data.user.email,
        name: createResponse.data.user.name,
        photoUrl: createResponse.data.user.photoUrl || photoUrl || null,
      };
      localStorage.setItem('auth_user', JSON.stringify(user));
      localStorage.setItem('auth_token', createResponse.data.user.id);
      return user;
    } else {
      throw new Error(createResponse.data.error || 'Failed to sign in with Google.');
    }
  } catch (error) {
    if (error.response?.data?.error) {
      throw new Error(error.response.data.error);
    }
    throw new Error(`Failed to sign in with Google: ${error.message}`);
  }
};
