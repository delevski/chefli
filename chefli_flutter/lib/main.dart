import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/landing/landing_screen.dart';
import 'features/home/home_screen.dart';
import 'features/recipe/recipe_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/saved/saved_recipes_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/cooking/cooking_screen.dart';
import 'providers/recipe_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue anyway - Firebase might work with default options
  }
  runApp(const ChefliApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return RecipeScreen(id: id);
      },
    ),
    GoRoute(
      path: '/cooking/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CookingScreen(recipeId: id);
      },
    ),
    GoRoute(
      path: '/saved',
      builder: (context, state) => const SavedRecipesScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(
        onLoginSuccess: () => state.extra != null 
            ? Navigator.of(context).pop(true)
            : context.go('/'),
        onClose: () => Navigator.of(context).pop(false),
      ),
    ),
  ],
);

class ChefliApp extends StatelessWidget {
  const ChefliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          // Wait for settings to initialize before building
          if (!settings.isInitialized) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          
          return MaterialApp.router(
            title: 'Chefli',
            theme: settings.isDarkMode ? ChefliTheme.darkTheme : ChefliTheme.lightTheme,
            locale: Locale(settings.languageCode),
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            builder: (context, child) {
              return Directionality(
                textDirection: settings.textDirection,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
