import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mock_recipe.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh recipes when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().refreshRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.bgMain,
      body: Stack(
        children: [
          // Background Glows
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final primaryGlowOpacity = isDark ? 0.15 : 0.08;
              final accentGlowOpacity = isDark ? 0.1 : 0.05;
              return Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ChefliTheme.primary.withOpacity(primaryGlowOpacity),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -100,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ChefliTheme.accent.withOpacity(accentGlowOpacity),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.chevronLeft, color: context.onSurface, size: 24),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            l10n.savedRecipes,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.search, color: context.onSurface, size: 22),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 4),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: context.surfaceOverlay,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  if (auth.isLoggedIn) {
                                    context.push('/profile');
                                  } else {
                                    context.push('/login');
                                  }
                                },
                                icon: Icon(
                                  auth.isLoggedIn ? LucideIcons.user : LucideIcons.logIn,
                                  color: context.onSurface,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: Consumer<RecipeProvider>(
                  builder: (context, provider, _) {
                    final recipes = provider.allRecipes;
                    
                    if (recipes.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.bookmark,
                                size: 64,
                                color: context.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noSavedRecipesYet,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: context.onSurfaceSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.saveRecipesToSeeHere,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.onSurface.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 4 / 5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = recipes[index];
                          return _RecipeCard(recipe: recipe);
                        },
                        childCount: recipes.length,
                      ),
                    );
                  },
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),

          // Bottom Navigation Bar
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(activeTab: NavTab.saved),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;
    final imageUrl = hasImage 
        ? recipe.imageUrl! 
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
    
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback placeholder if image fails to load
                    return Container(
                      color: context.bgSurface,
                      child: Center(
                        child: Icon(
                          LucideIcons.image,
                          size: 48,
                          color: context.onSurface.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: context.bgSurface,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: ChefliTheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dark overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.6, 1.0],
                    ),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: ChefliTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.time}m',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(LucideIcons.barChart, size: 14, color: ChefliTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.getDifficulty(recipe.difficulty),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.heart, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}


