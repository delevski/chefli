import { useState, useEffect, useRef } from 'react';
import { X, Mail, Lock, Eye, EyeOff } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { handleGoogleCredential } from '../services/authService';
import '../styles/LoginPage.css';

const LoginPage = ({ onLoginSuccess, onClose }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [isPasswordVisible, setIsPasswordVisible] = useState(false);
  const [isCreateAccount, setIsCreateAccount] = useState(false);
  const [error, setError] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const googleButtonRef = useRef(null);
  
  const { login, register, loginWithGoogle } = useAuth();
  const { t, isRTL } = useLanguage();

  // Initialize Google Sign-In button
  useEffect(() => {
    const initGoogleSignIn = () => {
      const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
      if (!clientId) return;

      // Wait for Google Identity Services to load
      if (typeof window.google === 'undefined' || !window.google.accounts) {
        setTimeout(initGoogleSignIn, 100);
        return;
      }

      if (googleButtonRef.current) {
        window.google.accounts.id.initialize({
          client_id: clientId,
          callback: async (response) => {
            try {
              await handleGoogleSignIn(response.credential);
            } catch (err) {
              setError(err.message || 'Failed to sign in with Google');
            }
          },
        });

        window.google.accounts.id.renderButton(googleButtonRef.current, {
          theme: 'outline',
          size: 'large',
          width: '100%',
          text: 'signin_with',
        });
      }
    };

    initGoogleSignIn();
  }, []);

  const handleGoogleSignIn = async (credential) => {
    setIsLoading(true);
    setError(null);
    try {
      const user = await handleGoogleCredential(credential);
      // Update auth context by calling loginWithGoogle which reads from localStorage
      await loginWithGoogle();
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (err) {
      setError(err.message || 'Failed to sign in with Google');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      if (isCreateAccount) {
        await register(email, password, name || null);
      } else {
        await login(email, password);
      }
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (err) {
      setError(err.message || 'An error occurred');
    } finally {
      setIsLoading(false);
    }
  };

  const toggleMode = () => {
    setIsCreateAccount(!isCreateAccount);
    setError(null);
    setPassword('');
  };

  return (
    <div className="login-overlay" onClick={onClose}>
      <motion.div
        className="login-modal"
        onClick={(e) => e.stopPropagation()}
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.9 }}
        transition={{ duration: 0.2 }}
      >
        <button className="close-btn" onClick={onClose}>
          <X size={24} />
        </button>

        <div className="login-content">
          <motion.div
            className="login-header"
            initial={{ y: -20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
          >
            <h1>{isCreateAccount ? t('createAccount') : t('signIn')}</h1>
            <p>{isCreateAccount ? t('dontHaveAccount') : t('alreadyHaveAccount')}</p>
          </motion.div>

          <form onSubmit={handleSubmit} className="login-form" onClick={(e) => e.stopPropagation()}>
            {isCreateAccount && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
              >
                <div className="input-group">
                  <label>{t('name')}</label>
                  <div className="input-wrapper">
                    <input
                      type="text"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder={t('enterYourName')}
                      dir={isRTL ? 'rtl' : 'ltr'}
                    />
                  </div>
                </div>
              </motion.div>
            )}

            <div className="input-group">
              <label>{t('email')}</label>
              <div className="input-wrapper">
                <Mail size={20} className="input-icon" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder={t('enterYourEmail')}
                  required
                  dir={isRTL ? 'rtl' : 'ltr'}
                />
              </div>
            </div>

            <div className="input-group">
              <label>{t('password')}</label>
              <div className="input-wrapper">
                <Lock size={20} className="input-icon" />
                <input
                  type={isPasswordVisible ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder={t('enterYourPassword')}
                  required
                  minLength={6}
                  dir={isRTL ? 'rtl' : 'ltr'}
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setIsPasswordVisible(!isPasswordVisible)}
                >
                  {isPasswordVisible ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              </div>
              {password.length > 0 && password.length < 6 && (
                <p className="error-text">{t('passwordMinLength')}</p>
              )}
            </div>

            {error && (
              <motion.div
                className="error-message"
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
              >
                {error}
              </motion.div>
            )}

            <button
              type="submit"
              className="submit-btn"
              disabled={isLoading}
              onClick={(e) => e.stopPropagation()}
            >
              {isLoading ? t('loading') : (isCreateAccount ? t('createAccount') : t('signIn'))}
            </button>
          </form>

          {import.meta.env.VITE_GOOGLE_CLIENT_ID && (
            <div className="google-signin-section">
              <div className="divider">
                <span>{t('or')}</span>
              </div>
              <div ref={googleButtonRef} className="google-signin-button"></div>
            </div>
          )}

          <div className="login-footer">
            <button
              type="button"
              className="toggle-mode-btn"
              onClick={toggleMode}
            >
              {isCreateAccount ? t('alreadyHaveAccount') : t('dontHaveAccount')}
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  );
};

export default LoginPage;
