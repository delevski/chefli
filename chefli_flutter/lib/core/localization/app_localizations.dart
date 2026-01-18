import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  static AppLocalizations of(BuildContext context) {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      return AppLocalizations(settingsProvider.language);
    } catch (e) {
      return AppLocalizations(AppLanguage.english);
    }
  }

  // Common
  String get settings => language == AppLanguage.hebrew ? 'הגדרות' : 'Settings';
  String get profile => language == AppLanguage.hebrew ? 'פרופיל' : 'Profile';
  String get home => language == AppLanguage.hebrew ? 'בית' : 'Home';
  String get explore => language == AppLanguage.hebrew ? 'גלה' : 'Explore';
  String get recipes => language == AppLanguage.hebrew ? 'מתכונים' : 'Recipes';
  String get saved => language == AppLanguage.hebrew ? 'שמורים' : 'Saved';
  String get cancel => language == AppLanguage.hebrew ? 'ביטול' : 'Cancel';
  String get save => language == AppLanguage.hebrew ? 'שמור' : 'Save';
  String get delete => language == AppLanguage.hebrew ? 'מחק' : 'Delete';
  String get edit => language == AppLanguage.hebrew ? 'ערוך' : 'Edit';
  String get close => language == AppLanguage.hebrew ? 'סגור' : 'Close';
  String get back => language == AppLanguage.hebrew ? 'חזור' : 'Back';
  String get next => language == AppLanguage.hebrew ? 'הבא' : 'Next';
  String get done => language == AppLanguage.hebrew ? 'סיום' : 'Done';
  String get loading => language == AppLanguage.hebrew ? 'טוען...' : 'Loading...';
  String get error => language == AppLanguage.hebrew ? 'שגיאה' : 'Error';
  String get success => language == AppLanguage.hebrew ? 'הצלחה' : 'Success';

  // Settings Screen
  String get notifications => language == AppLanguage.hebrew ? 'התראות' : 'Notifications';
  String get pushNotifications => language == AppLanguage.hebrew ? 'התראות דחיפה' : 'Push Notifications';
  String get pushNotificationsSubtitle => language == AppLanguage.hebrew ? 'קבל התראות על מתכונים חדשים' : 'Receive notifications about new recipes';
  String get emailUpdates => language == AppLanguage.hebrew ? 'עדכוני אימייל' : 'Email Updates';
  String get emailUpdatesSubtitle => language == AppLanguage.hebrew ? 'קבל המלצות מתכונים שבועיות' : 'Get weekly recipe recommendations';
  String get appSettings => language == AppLanguage.hebrew ? 'הגדרות אפליקציה' : 'App Settings';
  String get darkMode => language == AppLanguage.hebrew ? 'מצב כהה' : 'Dark Mode';
  String get darkThemeActive => language == AppLanguage.hebrew ? 'ערכת נושא כהה פעילה' : 'Dark theme active';
  String get lightThemeActive => language == AppLanguage.hebrew ? 'ערכת נושא בהירה פעילה' : 'Light theme active';
  String get autoSaveRecipes => language == AppLanguage.hebrew ? 'שמירה אוטומטית של מתכונים' : 'Auto-save Recipes';
  String get autoSaveRecipesSubtitle => language == AppLanguage.hebrew ? 'שמור אוטומטית מתכונים שנוצרו' : 'Automatically save generated recipes';
  String get languageLabel => language == AppLanguage.hebrew ? 'שפה' : 'Language';
  String get selectLanguage => language == AppLanguage.hebrew ? 'בחר שפה' : 'Select Language';
  String get account => language == AppLanguage.hebrew ? 'חשבון' : 'Account';
  String get manageProfile => language == AppLanguage.hebrew ? 'נהל את הפרופיל שלך' : 'Manage your profile';
  String get privacy => language == AppLanguage.hebrew ? 'פרטיות' : 'Privacy';
  String get privacySettings => language == AppLanguage.hebrew ? 'הגדרות פרטיות' : 'Privacy settings';
  String get helpSupport => language == AppLanguage.hebrew ? 'עזרה ותמיכה' : 'Help & Support';
  String get getHelp => language == AppLanguage.hebrew ? 'קבל עזרה' : 'Get help';
  String get about => language == AppLanguage.hebrew ? 'אודות' : 'About';
  String get appVersion => language == AppLanguage.hebrew ? 'גרסת אפליקציה' : 'App Version';
  String get termsOfService => language == AppLanguage.hebrew ? 'תנאי שירות' : 'Terms of Service';
  String get privacyPolicy => language == AppLanguage.hebrew ? 'מדיניות פרטיות' : 'Privacy Policy';
  String get signOut => language == AppLanguage.hebrew ? 'התנתק' : 'Sign Out';
  String get signOutConfirmation => language == AppLanguage.hebrew ? 'פונקציונליות התנתקות בקרוב' : 'Sign out functionality coming soon';
  
  // Language names
  String get english => language == AppLanguage.hebrew ? 'אנגלית' : 'English';
  String get hebrew => language == AppLanguage.hebrew ? 'עברית' : 'עברית (Hebrew)';
  String get languageChangedToEnglish => language == AppLanguage.hebrew ? 'השפה שונתה לאנגלית' : 'Language changed to English';
  String get languageChangedToHebrew => language == AppLanguage.hebrew ? 'שפה שונתה לעברית' : 'Language changed to Hebrew';
  
  // Toggle messages
  String get darkModeEnabled => language == AppLanguage.hebrew ? 'מצב כהה מופעל' : 'Dark mode enabled';
  String get lightModeEnabled => language == AppLanguage.hebrew ? 'מצב בהיר מופעל' : 'Light mode enabled';
  String get pushNotificationsEnabled => language == AppLanguage.hebrew ? 'התראות דחיפה מופעלות' : 'Push notifications enabled';
  String get pushNotificationsDisabled => language == AppLanguage.hebrew ? 'התראות דחיפה מושבתות' : 'Push notifications disabled';
  String get emailUpdatesEnabled => language == AppLanguage.hebrew ? 'עדכוני אימייל מופעלים' : 'Email updates enabled';
  String get emailUpdatesDisabled => language == AppLanguage.hebrew ? 'עדכוני אימייל מושבתים' : 'Email updates disabled';
  String get autoSaveEnabled => language == AppLanguage.hebrew ? 'שמירה אוטומטית מופעלת' : 'Auto-save enabled';
  String get autoSaveDisabled => language == AppLanguage.hebrew ? 'שמירה אוטומטית מושבתת' : 'Auto-save disabled';
  
  // Coming soon messages
  String get comingSoon => language == AppLanguage.hebrew ? 'בקרוב' : 'coming soon';
  String get privacySettingsComingSoon => language == AppLanguage.hebrew ? 'הגדרות פרטיות בקרוב' : 'Privacy settings coming soon';
  String get helpSupportComingSoon => language == AppLanguage.hebrew ? 'עזרה ותמיכה בקרוב' : 'Help & Support coming soon';
  String get termsComingSoon => language == AppLanguage.hebrew ? 'תנאי שירות בקרוב' : 'Terms of Service coming soon';
  String get privacyPolicyComingSoon => language == AppLanguage.hebrew ? 'מדיניות פרטיות בקרוב' : 'Privacy Policy coming soon';
  
  // Home Screen
  String get searchPlaceholder => language == AppLanguage.hebrew ? 'תאר מנה או הדבק קישור...' : 'Describe a dish or paste a URL...';
  String get categoryAll => language == AppLanguage.hebrew ? 'הכל' : 'All';
  String get categoryItalian => language == AppLanguage.hebrew ? 'איטלקי' : 'Italian';
  String get categoryAsian => language == AppLanguage.hebrew ? 'אסייתי' : 'Asian';
  String get categoryQuick => language == AppLanguage.hebrew ? 'מהיר' : 'Quick';
  String get categoryVegan => language == AppLanguage.hebrew ? 'טבעוני' : 'Vegan';
  String get aiPresetsForYou => language == AppLanguage.hebrew ? 'המלצות AI עבורך' : 'AI Presets for You';
  String get viewAll => language == AppLanguage.hebrew ? 'הצג הכל' : 'View all';
  String get haveFoodPhoto => language == AppLanguage.hebrew ? 'יש לך תמונת אוכל?' : 'Have a food photo?';
  String get convertMealToRecipe => language == AppLanguage.hebrew ? 'המר כל מנה למתכון מיידי.' : 'Convert any meal into a recipe instantly.';
  String get tryPhotoToRecipe => language == AppLanguage.hebrew ? 'נסה תמונה למתכון' : 'Try Photo-to-Recipe';
  
  // Saved Recipes Screen
  String get savedRecipes => language == AppLanguage.hebrew ? 'מתכונים שמורים' : 'Saved Recipes';
  String get noSavedRecipesYet => language == AppLanguage.hebrew ? 'אין עדיין מתכונים שמורים' : 'No saved recipes yet';
  String get saveRecipesToSeeHere => language == AppLanguage.hebrew ? 'שמור מתכונים כדי לראות אותם כאן' : 'Save recipes to see them here';
  
  // Recipe Screen
  String get ingredients => language == AppLanguage.hebrew ? 'מרכיבים' : 'Ingredients';
  String get servings => language == AppLanguage.hebrew ? 'מנות' : 'servings';
  String get instructions => language == AppLanguage.hebrew ? 'הוראות הכנה' : 'Instructions';
  String get nutritionFacts => language == AppLanguage.hebrew ? 'עובדות תזונה' : 'Nutrition Facts';
  String get protein => language == AppLanguage.hebrew ? 'חלבון' : 'Protein';
  String get carbs => language == AppLanguage.hebrew ? 'פחמימות' : 'Carbs';
  String get fats => language == AppLanguage.hebrew ? 'שומנים' : 'Fats';
  String get fiber => language == AppLanguage.hebrew ? 'סיבים' : 'Fiber';
  String get startCooking => language == AppLanguage.hebrew ? 'התחל לבשל' : 'START COOKING';
  String get minutes => language == AppLanguage.hebrew ? 'דקות' : 'min';
  String get kcal => language == AppLanguage.hebrew ? 'קלוריות' : 'kcal';
  
  // Profile Screen
  String get pro => language == AppLanguage.hebrew ? 'מקצועי' : 'PRO';
  String get chefLevel => language == AppLanguage.hebrew ? 'רמת שף' : 'CHEF LEVEL';
  String get masterSaucier => language == AppLanguage.hebrew ? 'שף רוטב מומחה' : 'Master Saucier';
  String get nextRank => language == AppLanguage.hebrew ? 'הדרגה הבאה' : 'Next Rank';
  String get masterChef => language == AppLanguage.hebrew ? 'שף ראשי' : 'Master Chef';
  String get nextRankMasterChef => language == AppLanguage.hebrew ? 'הדרגה הבאה: שף ראשי' : 'Next Rank: Master Chef';
  String get xp => language == AppLanguage.hebrew ? 'נקודות ניסיון' : 'XP';
  String get recipesStat => language == AppLanguage.hebrew ? 'מתכונים' : 'RECIPES';
  String get followersStat => language == AppLanguage.hebrew ? 'עוקבים' : 'FOLLOWERS';
  String get createdStat => language == AppLanguage.hebrew ? 'נוצרו' : 'CREATED';
  String get recentGenerations => language == AppLanguage.hebrew ? 'יצירות אחרונות' : 'Recent Generations';
  String get fromText => language == AppLanguage.hebrew ? 'מטקסט' : 'FROM TEXT';
  String get generated => language == AppLanguage.hebrew ? 'נוצר' : 'Generated';
  
  // Difficulty Levels
  String getDifficulty(String difficulty) {
    final lower = difficulty.toLowerCase();
    if (lower == 'easy') {
      return language == AppLanguage.hebrew ? 'קל' : 'Easy';
    } else if (lower == 'medium' || lower == 'med') {
      return language == AppLanguage.hebrew ? 'בינוני' : 'Medium';
    } else if (lower == 'hard' || lower == 'difficult') {
      return language == AppLanguage.hebrew ? 'קשה' : 'Hard';
    }
    return difficulty; // Return as-is if unknown
  }
  
  // Landing Screen
  String get whatAreWeCooking => language == AppLanguage.hebrew ? 'מה אנחנו\nמבשלים' : 'What are we\ncooking';
  String get today => language == AppLanguage.hebrew ? 'היום?' : ' today?';
  String get describeIngredientsOrUpload => language == AppLanguage.hebrew ? 'תאר את המרכיבים שלך או העלה תמונה כדי ליצור מתכונים מיידיים.' : 'Describe your ingredients or upload a photo to generate instant recipes.';
  String get ingredientPlaceholder => language == AppLanguage.hebrew ? 'יש לי סלמון, אספרגוס ולימון. תן לי משהו בריא...' : 'I have salmon, asparagus and some lemon. Give me something healthy...';
  String get cook => language == AppLanguage.hebrew ? 'בשל' : 'Cook';
  String get cooking => language == AppLanguage.hebrew ? 'מבשל...' : 'Cooking...';
  String get quickSalad => language == AppLanguage.hebrew ? '🥗 סלט מהיר' : '🥗 Quick Salad';
  String get pastaNight => language == AppLanguage.hebrew ? '🍝 ליל פסטה' : '🍝 Pasta Night';
  String get highProtein => language == AppLanguage.hebrew ? '🥩 חלבון גבוה' : '🥩 High Protein';
  String get image => language == AppLanguage.hebrew ? 'תמונה' : 'Image';
  String get voice => language == AppLanguage.hebrew ? 'קול' : 'Voice';
  String get takePhoto => language == AppLanguage.hebrew ? 'צלם תמונה' : 'Take Photo';
  String get chooseFromGallery => language == AppLanguage.hebrew ? 'בחר מהגלריה' : 'Choose from Gallery';
  String get recordVideo => language == AppLanguage.hebrew ? 'הקלט וידאו' : 'Record Video';
  String get imageAttached => language == AppLanguage.hebrew ? '[תמונה מצורפת]' : '[Image attached]';
  String get imagesAttached => language == AppLanguage.hebrew ? '[תמונות מצורפות]' : '[image(s) attached]';
  String get filesAttached => language == AppLanguage.hebrew ? '[קבצים מצורפים]' : '[Files:';
  String get voiceRecordingAttached => language == AppLanguage.hebrew ? '[הקלטת קול מצורפת]' : '[Voice recording attached]';
  String get videoAttached => language == AppLanguage.hebrew ? '[וידאו מצורף]' : '[Video attached]';
  String get imageCaptured => language == AppLanguage.hebrew ? 'תמונה צולמה' : 'Image captured';
  String get imagesAdded => language == AppLanguage.hebrew ? 'תמונות נוספו' : 'image(s) added';
  String get filesAdded => language == AppLanguage.hebrew ? 'קבצים נוספו' : 'file(s) attached';
  String get voiceRecordingSaved => language == AppLanguage.hebrew ? 'הקלטת קול נשמרה' : 'Voice recording saved';
  String get videoRecorded => language == AppLanguage.hebrew ? 'וידאו הוקלט' : 'Video recorded';
  String get videoAdded => language == AppLanguage.hebrew ? 'וידאו נוסף' : 'Video added';
  String get recording => language == AppLanguage.hebrew ? 'מקליט... לחץ על המיקרופון כדי לעצור' : 'Recording... Tap mic to stop';
  String get permissionRequired => language == AppLanguage.hebrew ? 'נדרשת הרשאה. אנא אפשר בהגדרות.' : 'Permission required. Please enable in settings.';
  String get pleaseEnterIngredientsOrImage => language == AppLanguage.hebrew ? 'אנא הזן מרכיבים או צרף תמונה' : 'Please enter ingredients or attach an image';
  String get pleaseEnterAtLeastOneIngredient => language == AppLanguage.hebrew ? 'אנא הזן לפחות מרכיב אחד' : 'Please enter at least one ingredient';
  String get errorGeneratingRecipe => language == AppLanguage.hebrew ? 'שגיאה ביצירת מתכון' : 'Error generating recipe';
  
  // Login Screen
  String get aiCulinaryAssistant => language == AppLanguage.hebrew ? 'עוזר בישול AI' : 'AI CULINARY ASSISTANT';
  String get continueWithGoogle => language == AppLanguage.hebrew ? 'המשך עם Google' : 'Continue with Google';
  String get or => language == AppLanguage.hebrew ? 'או' : 'OR';
  String get emailAddress => language == AppLanguage.hebrew ? 'כתובת אימייל' : 'EMAIL ADDRESS';
  String get password => language == AppLanguage.hebrew ? 'סיסמה' : 'PASSWORD';
  String get emailPlaceholder => language == AppLanguage.hebrew ? 'שף@chefli.ai' : 'chef@chefli.ai';
  String get passwordPlaceholder => language == AppLanguage.hebrew ? '••••••••' : '••••••••';
  String get pleaseEnterEmail => language == AppLanguage.hebrew ? 'אנא הזן את האימייל שלך' : 'Please enter your email';
  String get pleaseEnterValidEmail => language == AppLanguage.hebrew ? 'אנא הזן אימייל תקין' : 'Please enter a valid email';
  String get pleaseEnterPassword => language == AppLanguage.hebrew ? 'אנא הזן את הסיסמה שלך' : 'Please enter your password';
  String get passwordMinLength => language == AppLanguage.hebrew ? 'הסיסמה חייבת להכיל לפחות 6 תווים' : 'Password must be at least 6 characters';
  String get forgotPassword => language == AppLanguage.hebrew ? 'שכחת סיסמה?' : 'Forgot Password?';
  String get signIn => language == AppLanguage.hebrew ? 'התחבר' : 'Sign In';
  String get createAccount => language == AppLanguage.hebrew ? 'צור חשבון' : 'Create Account';
  String get alreadyHaveAccount => language == AppLanguage.hebrew ? 'כבר יש לך חשבון?' : 'Already have an account?';
  String get dontHaveAccount => language == AppLanguage.hebrew ? 'אין לך חשבון?' : "Don't have an account?";
  String get passwordResetEmailSent => language == AppLanguage.hebrew ? 'אימייל איפוס סיסמה נשלח!' : 'Password reset email sent!';
  String get pleaseEnterEmailFirst => language == AppLanguage.hebrew ? 'אנא הזן את כתובת האימייל שלך תחילה' : 'Please enter your email address first';
  
  // Processing Screen
  String get chefliCraftingMasterpiece => language == AppLanguage.hebrew ? 'Chefli יוצר את\nיצירת המופת שלך...' : 'Chefli is crafting your\nmasterpiece...';
  String get analyzingIngredients => language == AppLanguage.hebrew ? 'מנתח מרכיבים...' : 'Analyzing ingredients...';
  String get matchingFlavorProfiles => language == AppLanguage.hebrew ? 'מתאים פרופילי טעמים...' : 'Matching flavor profiles...';
  String get calculatingNutrition => language == AppLanguage.hebrew ? 'מחשב תזונה...' : 'Calculating nutrition...';
  String get generatingRecipe => language == AppLanguage.hebrew ? 'יוצר מתכון...' : 'Generating recipe...';
  String get addingFinalTouches => language == AppLanguage.hebrew ? 'מוסיף מגעים אחרונים...' : 'Adding final touches...';
  String get processing => language == AppLanguage.hebrew ? 'מעבד' : 'PROCESSING';
  String get efficiencyEngine => language == AppLanguage.hebrew ? 'מנוע יעילות' : 'EFFICIENCY ENGINE';
  String get aiEngineGpt4 => language == AppLanguage.hebrew ? 'מנוע AI: GPT-4o מותאם' : 'AI engine: GPT-4o Optimized';
  String get quote1 => language == AppLanguage.hebrew ? '"בישול מעולה הוא על המסע, והמסע שלנו כמעט הושלם."' : '"Great cooking is about the journey, and ours is almost complete."';
  String get quote2 => language == AppLanguage.hebrew ? '"המרכיב הסודי הוא תמיד אהבה... וקצת קסם AI."' : '"The secret ingredient is always love... and a bit of AI magic."';
  String get quote3 => language == AppLanguage.hebrew ? '"אוכל טוב הוא הבסיס לאושר אמיתי."' : '"Good food is the foundation of genuine happiness."';
  String get quote4 => language == AppLanguage.hebrew ? '"בישול הוא כמו אהבה, צריך להיכנס אליו בהתלהבות."' : '"Cooking is like love, it should be entered into with abandon."';
  String get quote5 => language == AppLanguage.hebrew ? '"אוכל הוא הקרקע המשותפת שלנו, חוויה אוניברסלית."' : '"Food is our common ground, a universal experience."';
  
  List<String> get processingPhases => language == AppLanguage.hebrew 
    ? ['מנתח מרכיבים...', 'מתאים פרופילי טעמים...', 'מחשב תזונה...', 'יוצר מתכון...', 'מוסיף מגעים אחרונים...']
    : ['Analyzing ingredients...', 'Matching flavor profiles...', 'Calculating nutrition...', 'Generating recipe...', 'Adding final touches...'];
  
  List<String> get quotes => language == AppLanguage.hebrew
    ? [quote1, quote2, quote3, quote4, quote5]
    : [quote1, quote2, quote3, quote4, quote5];
}

extension SettingsProviderExtension on BuildContext {
  SettingsProvider? get settingsProvider => Provider.of<SettingsProvider>(this, listen: false);
}

