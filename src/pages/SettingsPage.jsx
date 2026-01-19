import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Moon, Sun, Globe, FileText, Shield, LogOut, ChevronLeft, Info } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { useLanguage } from '../context/LanguageContext';
import { useAuth } from '../context/AuthContext';
import '../styles/SettingsPage.css';

const SettingsPage = () => {
  const navigate = useNavigate();
  const { isDarkMode, toggleTheme } = useTheme();
  const { language, changeLanguage, t, isRTL } = useLanguage();
  const { logout, isLoggedIn } = useAuth();
  const [showPrivacy, setShowPrivacy] = useState(false);
  const [showTerms, setShowTerms] = useState(false);

  const webAppVersion = '0.0.0'; // From package.json
  const appVersion = '1.0.0';

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const handleLanguageChange = (lang) => {
    changeLanguage(lang);
  };

  return (
    <div className="settings-container container">
      <div className="settings-header">
        <button className="back-btn glass-panel" onClick={() => navigate(-1)}>
          <ChevronLeft size={24} />
        </button>
        <h1 className="text-gradient">{t('settings')}</h1>
      </div>

      <div className="settings-content">
        {/* Theme Section */}
        <motion.div
          className="settings-section glass-panel"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <div className="section-header">
            <div className="section-icon">
              {isDarkMode ? <Moon size={20} /> : <Sun size={20} />}
            </div>
            <h2>{t('theme')}</h2>
          </div>
          <div className="setting-item">
            <div className="setting-info">
              <span className="setting-label">{isDarkMode ? t('darkMode') : t('lightMode')}</span>
              <span className="setting-description">
                {isDarkMode ? t('darkMode') : t('lightMode')}
              </span>
            </div>
            <label className="toggle-switch">
              <input
                type="checkbox"
                checked={isDarkMode}
                onChange={toggleTheme}
              />
              <span className="slider"></span>
            </label>
          </div>
        </motion.div>

        {/* Language Section */}
        <motion.div
          className="settings-section glass-panel"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <div className="section-header">
            <div className="section-icon">
              <Globe size={20} />
            </div>
            <h2>{t('language')}</h2>
          </div>
          <div className="setting-item">
            <div className="setting-info">
              <span className="setting-label">{t('language')}</span>
              <span className="setting-description">
                {language === 'en' ? t('english') : t('hebrew')}
              </span>
            </div>
            <select
              className="language-select"
              value={language}
              onChange={(e) => handleLanguageChange(e.target.value)}
            >
              <option value="en">{t('english')}</option>
              <option value="he">{t('hebrew')}</option>
            </select>
          </div>
        </motion.div>

        {/* Legal Section */}
        <motion.div
          className="settings-section glass-panel"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <div className="section-header">
            <div className="section-icon">
              <FileText size={20} />
            </div>
            <h2>{t('legal')}</h2>
          </div>
          <div className="setting-item clickable" onClick={() => navigate('/privacy')}>
            <div className="setting-info">
              <Shield size={18} />
              <span className="setting-label">{t('privacyPolicy')}</span>
            </div>
            <ChevronLeft size={20} className="chevron" style={{ transform: isRTL ? 'rotate(180deg)' : 'none' }} />
          </div>
          <div className="setting-item clickable" onClick={() => navigate('/terms')}>
            <div className="setting-info">
              <FileText size={18} />
              <span className="setting-label">{t('termsAndConditions')}</span>
            </div>
            <ChevronLeft size={20} className="chevron" style={{ transform: isRTL ? 'rotate(180deg)' : 'none' }} />
          </div>
        </motion.div>

        {/* Version Section */}
        <motion.div
          className="settings-section glass-panel"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <div className="section-header">
            <div className="section-icon">
              <Info size={20} />
            </div>
            <h2>{t('version')}</h2>
          </div>
          <div className="setting-item">
            <span className="setting-label">{t('webAppVersion')}</span>
            <span className="version-value">v{webAppVersion}</span>
          </div>
          <div className="setting-item">
            <span className="setting-label">{t('appVersion')}</span>
            <span className="version-value">v{appVersion}</span>
          </div>
        </motion.div>

        {/* Logout Section */}
        {isLoggedIn && (
          <motion.div
            className="settings-section glass-panel"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
          >
            <button className="logout-button" onClick={handleLogout}>
              <LogOut size={20} />
              <span>{t('logout')}</span>
            </button>
          </motion.div>
        )}
      </div>
    </div>
  );
};

export default SettingsPage;
