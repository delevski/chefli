import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, BookOpen } from 'lucide-react';
import { useRecipe } from '../context/RecipeContext';
import { useLanguage } from '../context/LanguageContext';
import PresetCard from '../components/features/PresetCard';
import '../styles/SavedRecipesPage.css';

const SavedRecipesPage = () => {
  const navigate = useNavigate();
  const { recipes, isLoading } = useRecipe();
  const { t, isRTL, getDifficultyText } = useLanguage();

  const recipesList = Object.values(recipes || {});

  return (
    <div className="saved-recipes-container container">
      <div className="saved-recipes-header">
        <button className="back-btn glass-panel" onClick={() => navigate(-1)}>
          <ChevronLeft size={24} />
        </button>
        <div className="header-content">
          <BookOpen size={32} className="header-icon" />
          <h1 className="text-gradient">{t('savedRecipes')}</h1>
        </div>
      </div>

      {isLoading ? (
        <div className="loading-state">
          <p>{t('loading')}</p>
        </div>
      ) : recipesList.length === 0 ? (
        <motion.div
          className="empty-state glass-panel"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
        >
          <div className="empty-icon">🍳</div>
          <h2>{t('noRecipesYet')}</h2>
          <p>{t('startCookingToSave')}</p>
          <button className="start-cooking-btn" onClick={() => navigate('/')}>
            {t('cook')}
          </button>
        </motion.div>
      ) : (
        <motion.div
          className="recipes-grid"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4 }}
        >
          {recipesList.map((recipe, index) => (
            <motion.div
              key={recipe.recipeId || index}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
            >
              <PresetCard
                id={recipe.recipeId}
                title={recipe.dishName}
                image={recipe.imageUrl || recipe.image?.value}
                time={`${recipe.prepTimeMinutes || 20} ${t('minutes')}`}
                difficulty={getDifficultyText(recipe.difficulty || 'medium')}
              />
            </motion.div>
          ))}
        </motion.div>
      )}
    </div>
  );
};

export default SavedRecipesPage;
