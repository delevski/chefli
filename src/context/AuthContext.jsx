import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { createAccount, signInWithEmail, signOut, getCurrentUser, isLoggedIn as checkIsLoggedIn } from '../services/authService';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  // Initialize auth state from localStorage
  useEffect(() => {
    const initAuth = async () => {
      try {
        const currentUser = getCurrentUser();
        if (currentUser) {
          setUser(currentUser);
        }
      } catch (err) {
        console.error('Error initializing auth:', err);
      } finally {
        setIsLoading(false);
      }
    };
    initAuth();
  }, []);

  // Create account
  const register = useCallback(async (email, password, name = null) => {
    setIsLoading(true);
    setError(null);
    try {
      const newUser = await createAccount(email, password, name);
      setUser(newUser);
      return newUser;
    } catch (err) {
      const errorMessage = err.message || 'Failed to create account';
      setError(errorMessage);
      throw new Error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Sign in
  const login = useCallback(async (email, password) => {
    setIsLoading(true);
    setError(null);
    try {
      const loggedInUser = await signInWithEmail(email, password);
      setUser(loggedInUser);
      return loggedInUser;
    } catch (err) {
      const errorMessage = err.message || 'Failed to sign in';
      setError(errorMessage);
      throw new Error(errorMessage);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Sign out
  const logout = useCallback(() => {
    signOut();
    setUser(null);
    setError(null);
  }, []);

  const value = {
    user,
    isLoading,
    error,
    isLoggedIn: !!user,
    register,
    login,
    logout,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
