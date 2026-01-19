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
    
    // Settings
    darkMode: 'Dark Mode',
    lightMode: 'Light Mode',
    theme: 'Theme',
    language: 'Language',
    english: 'English',
    hebrew: 'Hebrew',
    privacyPolicy: 'Privacy Policy',
    termsAndConditions: 'Terms & Conditions',
    version: 'Version',
    webAppVersion: 'Web App Version',
    appVersion: 'App Version',
    logout: 'Logout',
    or: 'or',
    continueWithGoogle: 'Continue with Google',
    savedRecipes: 'Saved Recipes',
    noRecipesYet: 'No recipes yet',
    startCookingToSave: 'Start cooking to save your favorite recipes here!',
    legal: 'Legal',
    viewAll: 'View All',
    lastUpdated: 'Last Updated',
    informationWeCollect: 'Information We Collect',
    howWeUseYourInformation: 'How We Use Your Information',
    dataSecurity: 'Data Security',
    yourRights: 'Your Rights',
    contactUs: 'Contact Us',
    acceptanceOfTerms: 'Acceptance of Terms',
    useOfService: 'Use of Service',
    userAccounts: 'User Accounts',
    intellectualProperty: 'Intellectual Property',
    limitationOfLiability: 'Limitation of Liability',
    changesToTerms: 'Changes to Terms',
    privacyInfo1: 'We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support. This may include your name, email address, and recipe preferences.',
    privacyInfo2: 'We use the information we collect to provide, maintain, and improve our services, process your requests, and communicate with you about our services.',
    privacyInfo3: 'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
    privacyInfo4: 'You have the right to access, update, or delete your personal information at any time through your account settings or by contacting us.',
    privacyInfo5: 'If you have any questions about this Privacy Policy, please contact us at privacy@chefli.com.',
    termsInfo1: 'By accessing or using Chefli, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use our service.',
    termsInfo2: 'You agree to use Chefli only for lawful purposes and in accordance with these Terms. You may not use the service in any way that could damage, disable, or impair the service.',
    termsInfo3: 'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
    termsInfo4: 'All content, features, and functionality of Chefli are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
    termsInfo5: 'Chefli is provided "as is" without warranties of any kind. We shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.',
    termsInfo6: 'We reserve the right to modify these Terms at any time. Your continued use of the service after any changes constitutes acceptance of the new Terms.',
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
    
    // Settings
    darkMode: 'מצב כהה',
    lightMode: 'מצב בהיר',
    theme: 'ערכת נושא',
    language: 'שפה',
    english: 'אנגלית',
    hebrew: 'עברית',
    privacyPolicy: 'מדיניות פרטיות',
    termsAndConditions: 'תנאים והגבלות',
    version: 'גרסה',
    webAppVersion: 'גרסת אפליקציית אינטרנט',
    appVersion: 'גרסת אפליקציה',
    logout: 'התנתק',
    or: 'או',
    continueWithGoogle: 'המשך עם Google',
    savedRecipes: 'מתכונים שמורים',
    noRecipesYet: 'אין עדיין מתכונים',
    startCookingToSave: 'התחל לבשל כדי לשמור את המתכונים האהובים עליך כאן!',
    legal: 'משפטי',
    viewAll: 'הצג הכל',
    lastUpdated: 'עודכן לאחרונה',
    informationWeCollect: 'מידע שאנו אוספים',
    howWeUseYourInformation: 'איך אנו משתמשים במידע שלך',
    dataSecurity: 'אבטחת נתונים',
    yourRights: 'הזכויות שלך',
    contactUs: 'צור קשר',
    acceptanceOfTerms: 'קבלת התנאים',
    useOfService: 'שימוש בשירות',
    userAccounts: 'חשבונות משתמשים',
    intellectualProperty: 'קניין רוחני',
    limitationOfLiability: 'הגבלת אחריות',
    changesToTerms: 'שינויים בתנאים',
    privacyInfo1: 'אנו אוספים מידע שאתה מספק לנו ישירות, כגון בעת יצירת חשבון, שימוש בשירותים שלנו או פנייה אלינו לתמיכה. זה עשוי לכלול את שמך, כתובת האימייל והעדפות המתכונים שלך.',
    privacyInfo2: 'אנו משתמשים במידע שאנו אוספים כדי לספק, לתחזק ולשפר את השירותים שלנו, לעבד את הבקשות שלך ולתקשר איתך לגבי השירותים שלנו.',
    privacyInfo3: 'אנו מיישמים אמצעים טכניים וארגוניים מתאימים כדי להגן על המידע האישי שלך מפני גישה לא מורשית, שינוי, חשיפה או הרס.',
    privacyInfo4: 'יש לך זכות לגשת, לעדכן או למחוק את המידע האישי שלך בכל עת באמצעות הגדרות החשבון שלך או על ידי יצירת קשר איתנו.',
    privacyInfo5: 'אם יש לך שאלות כלשהן לגבי מדיניות הפרטיות הזו, אנא צור איתנו קשר בכתובת privacy@chefli.com.',
    termsInfo1: 'על ידי גישה לשימוש ב-Chefli, אתה מסכים להיות כפוף לתנאים וההגבלות הללו. אם אינך מסכים, אנא אל תשתמש בשירות שלנו.',
    termsInfo2: 'אתה מסכים להשתמש ב-Chefli רק למטרות חוקיות ובהתאם לתנאים הללו. אינך רשאי להשתמש בשירות בכל דרך שעלולה לפגוע, להשבית או להפריע לשירות.',
    termsInfo3: 'אתה אחראי לשמירה על סודיות פרטי הכניסה לחשבון שלך ולכל הפעילויות המתרחשות תחת החשבון שלך.',
    termsInfo4: 'כל התוכן, התכונות והפונקציונליות של Chefli בבעלותנו ומוגנים על ידי חוקי זכויות יוצרים, סימני מסחר וקניין רוחני אחרים בינלאומיים.',
    termsInfo5: 'Chefli מסופק "כפי שהוא" ללא אחריות מכל סוג שהוא. לא נהיה אחראים לכל נזקים עקיפים, מקריים, מיוחדים או תוצאתיים הנובעים משימוש שלך בשירות.',
    termsInfo6: 'אנו שומרים לעצמנו את הזכות לשנות את התנאים הללו בכל עת. המשך השימוש שלך בשירות לאחר כל שינוי מהווה קבלה של התנאים החדשים.',
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
