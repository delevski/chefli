import React, { createContext, useContext, useState, useEffect } from 'react';
import { getTranslation, getProcessingPhases, getQuotes, getDifficulty } from '../services/localization';

const LanguageContext = createContext();

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within LanguageProvider');
  }
  return context;
};

export const LanguageProvider = ({ children }) => {
  const [language, setLanguage] = useState(() => {
    // Get from localStorage or default to English
    const saved = localStorage.getItem('app_language');
    return saved === 'he' ? 'he' : 'en';
  });

  const [textDirection, setTextDirection] = useState(language === 'he' ? 'rtl' : 'ltr');

  useEffect(() => {
    // Update text direction when language changes
    setTextDirection(language === 'he' ? 'rtl' : 'ltr');
    
    // Update document direction
    document.documentElement.setAttribute('dir', textDirection);
    
    // Save to localStorage
    localStorage.setItem('app_language', language);
  }, [language, textDirection]);

  const changeLanguage = (lang) => {
    setLanguage(lang);
  };

  const t = (key) => getTranslation(language, key);
  const processingPhases = getProcessingPhases(language);
  const quotes = getQuotes(language);
  const getDifficultyText = (difficulty) => getDifficulty(language, difficulty);
  const isRTL = textDirection === 'rtl';

  const value = {
    language,
    textDirection,
    isRTL,
    changeLanguage,
    t,
    processingPhases,
    quotes,
    getDifficultyText,
  };

  return (
    <LanguageContext.Provider value={value}>
      {children}
    </LanguageContext.Provider>
  );
};
