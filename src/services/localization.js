// Localization service matching Flutter app's AppLocalizations

const translations = {
  en: {
    // Common
    settings: 'Settings',
    profile: 'Profile',
    home: 'Home',
    explore: 'Explore',
    recipes: 'Recipes',
    saved: 'Saved',
    cancel: 'Cancel',
    save: 'Save',
    delete: 'Delete',
    edit: 'Edit',
    close: 'Close',
    back: 'Back',
    next: 'Next',
    done: 'Done',
    loading: 'Loading...',
    error: 'Error',
    success: 'Success',
    name: 'Name',
    email: 'Email',
    password: 'Password',
    enterYourName: 'Enter your name',
    enterYourEmail: 'Enter your email',
    enterYourPassword: 'Enter your password',
    
    // Landing Screen
    whatAreWeCooking: 'What ingredients do you have to cook?',
    ingredientPlaceholder: 'e.g., 2 eggs, some tomatoes, and pasta...',
    cook: 'Chef It Up!',
    cooking: 'Chefing...',
    pleaseEnterAtLeastOneIngredient: 'Please enter at least one ingredient',
    
    // Recipe Screen
    ingredients: 'Ingredients',
    servings: 'servings',
    instructions: 'Instructions',
    nutritionFacts: 'Nutrition Facts',
    protein: 'Protein',
    carbs: 'Carbs',
    fats: 'Fats',
    fiber: 'Fiber',
    startCooking: 'START COOKING',
    minutes: 'min',
    kcal: 'kcal',
    
    // Login Screen
    signIn: 'Sign In',
    createAccount: 'Create Account',
    alreadyHaveAccount: 'Already have an account?',
    dontHaveAccount: "Don't have an account?",
    passwordMinLength: 'Password must be at least 6 characters',
    pleaseEnterEmailFirst: 'Please enter your email address first',
    
    // Processing Screen
    chefliCraftingMasterpiece: 'Chefli is crafting your\nmasterpiece...',
    analyzingIngredients: 'Analyzing ingredients...',
    matchingFlavorProfiles: 'Matching flavor profiles...',
    calculatingNutrition: 'Calculating nutrition...',
    generatingRecipe: 'Generating recipe...',
    addingFinalTouches: 'Adding final touches...',
    processing: 'PROCESSING',
    efficiencyEngine: 'EFFICIENCY ENGINE',
    aiEngineGpt4: 'AI engine: GPT-4o Optimized',
    quote1: '"Great cooking is about the journey, and ours is almost complete."',
    quote2: '"The secret ingredient is always love... and a bit of AI magic."',
    quote3: '"Good food is the foundation of genuine happiness."',
    quote4: '"Cooking is like love, it should be entered into with abandon."',
    quote5: '"Food is our common ground, a universal experience."',
  },
  he: {
    // Common
    settings: 'הגדרות',
    profile: 'פרופיל',
    home: 'בית',
    explore: 'גלה',
    recipes: 'מתכונים',
    saved: 'שמורים',
    cancel: 'ביטול',
    save: 'שמור',
    delete: 'מחק',
    edit: 'ערוך',
    close: 'סגור',
    back: 'חזור',
    next: 'הבא',
    done: 'סיום',
    loading: 'טוען...',
    error: 'שגיאה',
    success: 'הצלחה',
    name: 'שם',
    email: 'אימייל',
    password: 'סיסמה',
    enterYourName: 'הזן את שמך',
    enterYourEmail: 'הזן את האימייל שלך',
    enterYourPassword: 'הזן את הסיסמה שלך',
    
    // Landing Screen
    whatAreWeCooking: 'מה המרכיבים שיש לך לבשל?',
    ingredientPlaceholder: 'למשל, 2 ביצים, כמה עגבניות ופסטה...',
    cook: 'בשל!',
    cooking: 'מבשל...',
    pleaseEnterAtLeastOneIngredient: 'אנא הזן לפחות מרכיב אחד',
    
    // Recipe Screen
    ingredients: 'מרכיבים',
    servings: 'מנות',
    instructions: 'הוראות הכנה',
    nutritionFacts: 'עובדות תזונה',
    protein: 'חלבון',
    carbs: 'פחמימות',
    fats: 'שומנים',
    fiber: 'סיבים',
    startCooking: 'התחל לבשל',
    minutes: 'דקות',
    kcal: 'קלוריות',
    
    // Login Screen
    signIn: 'התחבר',
    createAccount: 'צור חשבון',
    alreadyHaveAccount: 'כבר יש לך חשבון?',
    dontHaveAccount: 'אין לך חשבון?',
    passwordMinLength: 'הסיסמה חייבת להכיל לפחות 6 תווים',
    pleaseEnterEmailFirst: 'אנא הזן את כתובת האימייל שלך תחילה',
    
    // Processing Screen
    chefliCraftingMasterpiece: 'Chefli יוצר את\nיצירת המופת שלך...',
    analyzingIngredients: 'מנתח מרכיבים...',
    matchingFlavorProfiles: 'מתאים פרופילי טעמים...',
    calculatingNutrition: 'מחשב תזונה...',
    generatingRecipe: 'יוצר מתכון...',
    addingFinalTouches: 'מוסיף מגעים אחרונים...',
    processing: 'מעבד',
    efficiencyEngine: 'מנוע יעילות',
    aiEngineGpt4: 'מנוע AI: GPT-4o מותאם',
    quote1: '"בישול מעולה הוא על המסע, והמסע שלנו כמעט הושלם."',
    quote2: '"המרכיב הסודי הוא תמיד אהבה... וקצת קסם AI."',
    quote3: '"אוכל טוב הוא הבסיס לאושר אמיתי."',
    quote4: '"בישול הוא כמו אהבה, צריך להיכנס אליו בהתלהבות."',
    quote5: '"אוכל הוא הקרקע המשותפת שלנו, חוויה אוניברסלית."',
  },
};

export const getTranslation = (language, key) => {
  const lang = language === 'he' ? 'he' : 'en';
  return translations[lang][key] || key;
};

export const getProcessingPhases = (language) => {
  const lang = language === 'he' ? 'he' : 'en';
  if (lang === 'he') {
    return [
      'מנתח מרכיבים...',
      'מתאים פרופילי טעמים...',
      'מחשב תזונה...',
      'יוצר מתכון...',
      'מוסיף מגעים אחרונים...',
    ];
  }
  return [
    'Analyzing ingredients...',
    'Matching flavor profiles...',
    'Calculating nutrition...',
    'Generating recipe...',
    'Adding final touches...',
  ];
};

export const getQuotes = (language) => {
  const lang = language === 'he' ? 'he' : 'en';
  if (lang === 'he') {
    return [
      '"בישול מעולה הוא על המסע, והמסע שלנו כמעט הושלם."',
      '"המרכיב הסודי הוא תמיד אהבה... וקצת קסם AI."',
      '"אוכל טוב הוא הבסיס לאושר אמיתי."',
      '"בישול הוא כמו אהבה, צריך להיכנס אליו בהתלהבות."',
      '"אוכל הוא הקרקע המשותפת שלנו, חוויה אוניברסלית."',
    ];
  }
  return [
    '"Great cooking is about the journey, and ours is almost complete."',
    '"The secret ingredient is always love... and a bit of AI magic."',
    '"Good food is the foundation of genuine happiness."',
    '"Cooking is like love, it should be entered into with abandon."',
    '"Food is our common ground, a universal experience."',
  ];
};

export const getDifficulty = (language, difficulty) => {
  const lower = difficulty.toLowerCase();
  const lang = language === 'he' ? 'he' : 'en';
  
  if (lower === 'easy') {
    return lang === 'he' ? 'קל' : 'Easy';
  } else if (lower === 'medium' || lower === 'med') {
    return lang === 'he' ? 'בינוני' : 'Medium';
  } else if (lower === 'hard' || lower === 'difficult') {
    return lang === 'he' ? 'קשה' : 'Hard';
  }
  return difficulty;
};
