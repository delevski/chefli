import React, { useState } from 'react';
import { Upload, Mic, Video, Image as ImageIcon } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { useRecipe } from '../context/RecipeContext';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import LoginPage from './LoginPage';
import ProcessingPage from './ProcessingPage';
import '../styles/LandingPage.css';

const TEMPLATES = [
    { label: '🇮🇹 Italian Night', text: 'pasta, tomatoes, fresh basil, garlic, olive oil, parmesan cheese' },
    { label: '🥗 Healthy Salad', text: 'lettuce, cucumber, cherry tomatoes, olive oil, lemon, feta cheese' },
    { label: '🍳 Breakfast Omelet', text: '3 eggs, milk, cheddar cheese, salt, pepper, butter' },
    { label: '🌮 Mexican Fiesta', text: 'ground beef, flour tortillas, cheese, lettuce, salsa, sour cream' }
];

const LandingPage = () => {
    const [inputText, setInputText] = useState('');
    const [showLogin, setShowLogin] = useState(false);
    const [showProcessing, setShowProcessing] = useState(false);
    const navigate = useNavigate();
    const { createRecipe, isLoading, error } = useRecipe();
    const { isLoggedIn } = useAuth();
    const { t, isRTL } = useLanguage();

    const handleCook = async () => {
        if (!inputText.trim()) {
            alert(t('pleaseEnterAtLeastOneIngredient'));
            return;
        }

        // Check if user is logged in
        if (!isLoggedIn) {
            setShowLogin(true);
            return;
        }

        // Show processing screen
        setShowProcessing(true);

        try {
            const recipe = await createRecipe(inputText);
            if (recipe) {
                // Small delay to ensure processing screen shows completion
                setTimeout(() => {
                    setShowProcessing(false);
                    navigate(`/recipe/${recipe.recipeId}`);
                }, 500);
            }
        } catch (err) {
            setShowProcessing(false);
            alert(`Error: ${err.message || 'Failed to generate recipe'}`);
        }
    };

    const handleLoginSuccess = () => {
        setShowLogin(false);
        // Retry recipe generation after login
        handleCook();
    };

    const handleTemplateClick = (text) => {
        setInputText(text);
    };

    return (
        <>
            <div className="landing-container">
                <div className="content-wrapper glass-panel">
                    <motion.h1
                        className="hero-title text-gradient"
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.6 }}
                        dir={isRTL ? 'rtl' : 'ltr'}
                    >
                        {t('whatAreWeCooking')}
                    </motion.h1>

                    <div className="input-section">
                        <textarea
                            className="main-input"
                            placeholder={t('ingredientPlaceholder')}
                            value={inputText}
                            onChange={(e) => setInputText(e.target.value)}
                            dir={isRTL ? 'rtl' : 'ltr'}
                        />

                        <div className="media-controls">
                            <MediaButton icon={<ImageIcon size={20} />} label="Photo" />
                            <MediaButton icon={<Upload size={20} />} label="Upload" />
                            <MediaButton icon={<Mic size={20} />} label="Audio" />
                            <MediaButton icon={<Video size={20} />} label="Video" />
                        </div>
                    </div>

                    <div className="templates-section">
                        {TEMPLATES.map((template, idx) => (
                            <motion.button
                                key={idx}
                                className="template-chip glass-panel"
                                onClick={() => handleTemplateClick(template.text)}
                                whileHover={{ scale: 1.05, backgroundColor: 'rgba(255, 255, 255, 0.15)' }}
                                whileTap={{ scale: 0.95 }}
                                initial={{ opacity: 0, y: 10 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: 0.1 * idx }}
                            >
                                {template.label}
                            </motion.button>
                        ))}
                    </div>

                    <motion.button
                        className="cook-button"
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                        onClick={handleCook}
                        disabled={isLoading || showProcessing}
                    >
                        {isLoading || showProcessing ? t('cooking') : t('cook')}
                    </motion.button>
                    {error && (
                        <div style={{ color: '#ff4444', marginTop: '1rem', fontSize: '0.9rem' }}>
                            {error}
                        </div>
                    )}
                </div>
            </div>
            <AnimatePresence>
                {showLogin && (
                    <LoginPage
                        onLoginSuccess={handleLoginSuccess}
                        onClose={() => setShowLogin(false)}
                    />
                )}
                {showProcessing && (
                    <ProcessingPage
                        onComplete={() => setShowProcessing(false)}
                    />
                )}
            </AnimatePresence>
        </>
    );
};

const MediaButton = ({ icon, label }) => (
    <motion.button
        className="media-btn"
        whileHover={{ scale: 1.05, backgroundColor: 'rgba(255,255,255,0.1)' }}
        whileTap={{ scale: 0.95 }}
    >
        {icon}
        <span>{label}</span>
    </motion.button>
);

export default LandingPage;
