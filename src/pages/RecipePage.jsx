import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Clock, TrendingUp, ChevronLeft, CheckCircle, Info, Flame } from 'lucide-react';
import { motion } from 'framer-motion';
import { useRecipe } from '../context/RecipeContext';
import { useLanguage } from '../context/LanguageContext';
import '../styles/RecipePage.css';

// Fallback Mock Data
const MOCK_RECIPE = {
    recipeId: "demo-123",
    userId: "user-1",
    dishName: "Creamy Tomato Basil Pasta",
    image: { type: "url", value: "https://images.unsplash.com/photo-1626844131082-256783844137?auto=format&fit=crop&w=1000&q=80" },
    prepTimeMinutes: 25,
    difficulty: "medium",
    ingredients: [
        { name: "Pasta (Penne or Fusilli)", quantity: "400g" },
        { name: "Fresh Basil", quantity: "1 bunch" },
        { name: "Cherry Tomatoes", quantity: "200g" },
        { name: "Heavy Cream", quantity: "150ml" },
        { name: "Garlic", quantity: "2 cloves" },
        { name: "Parmesan Cheese", quantity: "50g" }
    ],
    steps: [
        "Boil a large pot of salted water. Add pasta and cook until al dente.",
        "While pasta cooks, heat olive oil in a pan. Sauté minced garlic until fragrant (1 min).",
        "Add cherry tomatoes to the pan and cook until soft and blistering (5 mins).",
        "Pour in heavy cream and simmer gently for 3 minutes. Season with salt and pepper.",
        "Drain pasta (reserve some water) and toss into the sauce.",
        "Stir in fresh basil and parmesan cheese. Serve hot."
    ],
    tips: [
        "Save a cup of pasta water to adjust sauce consistency.",
        "Use fresh basil for the best aroma, add it at the very end."
    ],
    nutrition: {
        calories: 650,
        protein_g: 18,
        carbs_g: 85,
        fat_g: 24
    },
    sourceConfidence: "high"
};

const RecipePage = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const { getRecipe, currentRecipe } = useRecipe();
    const { t, isRTL, getDifficultyText } = useLanguage();
    const [recipe, setRecipe] = useState(null);

    useEffect(() => {
        // Try to get recipe from context first
        const contextRecipe = getRecipe(id) || currentRecipe;
        if (contextRecipe) {
            setRecipe(contextRecipe);
        } else {
            // Fallback to mock data if not found
            setRecipe(MOCK_RECIPE);
        }
    }, [id, getRecipe, currentRecipe]);

    if (!recipe) return <div className="loading-state">Loading Recipe...</div>;

    return (
        <div className="recipe-page">
            <div className="hero-section" style={{ backgroundImage: `url(${recipe.image.value})` }}>
                <div className="overlay" />
                <button className="back-btn glass-panel" onClick={() => navigate(-1)}>
                    <ChevronLeft size={24} />
                </button>
                <div className="hero-content container">
                    <motion.h1
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                    >
                        {recipe.dishName}
                    </motion.h1>
                    {recipe.shortDescription && (
                        <motion.p
                            initial={{ y: 20, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            transition={{ delay: 0.1 }}
                            style={{ marginTop: '0.5rem', opacity: 0.9 }}
                        >
                            {recipe.shortDescription}
                        </motion.p>
                    )}
                    <div className="meta-badges">
                        <span className="badge glass-panel"><Clock size={16} /> {recipe.prepTimeMinutes} {t('minutes')}</span>
                        <span className="badge glass-panel"><TrendingUp size={16} /> {getDifficultyText(recipe.difficulty)}</span>
                        {recipe.nutrition && recipe.nutrition.calories && (
                            <span className="badge glass-panel"><Flame size={16} /> {recipe.nutrition.calories} {t('kcal')}</span>
                        )}
                    </div>
                </div>
            </div>

            <div className="content-container container">
                <div className="grid-layout">
                    {/* Left Column: Ingredients */}
                    <motion.div
                        className="ingredients-panel glass-panel"
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.2 }}
                    >
                        <h2>Ingredients</h2>
                        <ul className="ingredients-list">
                            {recipe.ingredients.map((ing, idx) => (
                                <li key={idx} className="ingredient-item">
                                    <div className="checkbox" />
                                    <span className="name">{ing.name}</span>
                                    <span className="qty">{ing.quantity}</span>
                                </li>
                            ))}
                        </ul>

                        {recipe.nutrition && (
                            <div className="nutrition-box">
                                <h3>{t('nutritionFacts')}</h3>
                                <div className="nutrition-grid">
                                    <div className="nutrition-card primary">
                                        <div className="nutrition-label">{t('protein')}</div>
                                        <div className="nutrition-value">
                                            {recipe.nutrition.protein ? `${Math.round(recipe.nutrition.protein)}g` : '-'}
                                        </div>
                                    </div>
                                    <div className="nutrition-card">
                                        <div className="nutrition-label">{t('carbs')}</div>
                                        <div className="nutrition-value">
                                            {recipe.nutrition.carbohydrates ? `${Math.round(recipe.nutrition.carbohydrates)}g` : '-'}
                                        </div>
                                    </div>
                                    <div className="nutrition-card">
                                        <div className="nutrition-label">{t('fats')}</div>
                                        <div className="nutrition-value">
                                            {recipe.nutrition.fats ? `${Math.round(recipe.nutrition.fats)}g` : '-'}
                                        </div>
                                    </div>
                                    <div className="nutrition-card">
                                        <div className="nutrition-label">{t('fiber')}</div>
                                        <div className="nutrition-value">
                                            {recipe.nutrition.carbohydrates && recipe.nutrition.carbohydrates > 0
                                                ? `${Math.round(recipe.nutrition.carbohydrates * 0.1)}g`
                                                : '-'}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </motion.div>

                    {/* Right Column: Steps */}
                    <motion.div
                        className="steps-panel"
                        initial={{ x: 20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.3 }}
                    >
                        <h2 dir={isRTL ? 'rtl' : 'ltr'}>{t('instructions')}</h2>
                        <div className="steps-list">
                            {recipe.steps.map((step, idx) => (
                                <div key={idx} className="step-card glass-panel">
                                    <div className="step-number">{idx + 1}</div>
                                    <p>{step}</p>
                                </div>
                            ))}
                        </div>

                        {recipe.tips && recipe.tips.length > 0 && (
                            <div className="tips-section glass-panel">
                                <h3><Info size={18} /> Chef's Tips</h3>
                                <ul>
                                    {recipe.tips.map((tip, idx) => (
                                        <li key={idx}>{tip}</li>
                                    ))}
                                </ul>
                            </div>
                        )}
                    </motion.div>
                </div>
            </div>
        </div>
    );
};

export default RecipePage;
