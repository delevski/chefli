import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mock_recipe.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isProEnabled = true;

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

          // Main content - no bottom nav bar
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.surfaceOverlay,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.chevronLeft,
                              color: context.onSurface,
                              size: 24,
                            ),
                          ),
                        ),
                        Text(
                          l10n.profile,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: context.surfaceOverlay,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.bell,
                                  color: context.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.push('/settings'),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: context.surfaceOverlay,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.settings,
                                  color: context.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Profile Header Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final user = authProvider.user;
                            
                            if (user == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            
                            // Generate username from email
                            final username = user.email.split('@').first;
                            
                            return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: ChefliTheme.primary, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ChefliTheme.primary.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                        image: user.photoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(user.photoUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: user.photoUrl == null 
                                            ? ChefliTheme.primary.withOpacity(0.2) 
                                            : null,
                                      ),
                                      child: user.photoUrl == null
                                          ? Icon(
                                              LucideIcons.user,
                                              size: 64,
                                              color: ChefliTheme.primary,
                                            )
                                          : null,
                                ),
                                if (_isProEnabled)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ChefliTheme.primary,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: ChefliTheme.bgMain, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ChefliTheme.primary.withOpacity(0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        l10n.pro,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                                Text(
                                  user.name ?? user.email.split('@').first,
                                  style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: context.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                  '@$username',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.onSurfaceSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 250,
                              child: Text(
                                    user.email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                            );
                          },
                        ),
                      ),

                      // Action/Status Panel
                      GlassPanel(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: ChefliTheme.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    LucideIcons.award,
                                    color: ChefliTheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${l10n.chefLevel} 14',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ChefliTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.masterSaucier,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _isProEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isProEnabled = value;
                                });
                              },
                              activeColor: ChefliTheme.primary,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar Section
                      GlassPanel(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.nextRankMasterChef,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.onSurface.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '1,500 / 2,000 ${l10n.xp}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ChefliTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 0.75,
                                backgroundColor: context.onSurface.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(ChefliTheme.primary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(child: _StatCard(label: l10n.recipesStat, value: '124')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(label: l10n.followersStat, value: '1.2k')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(label: l10n.createdStat, value: '48')),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Recipe History Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.recentGenerations,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/saved'),
                            child: Text(
                              l10n.viewAll,
                              style: TextStyle(
                                fontSize: 14,
                                color: ChefliTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recipe History List
                      Consumer<RecipeProvider>(
                        builder: (context, provider, _) {
                          // Sort recipes by most recent (assuming they have a timestamp or are added in order)
                          final recipes = provider.allRecipes.reversed.take(3).toList();
                          
                          if (recipes.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                l10n.noSavedRecipesYet,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.onSurfaceSecondary,
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            children: recipes.map((recipe) => _RecipeHistoryCard(recipe: recipe, l10n: l10n)).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: context.onSurfaceSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeHistoryCard extends StatelessWidget {
  final Recipe recipe;
  final AppLocalizations l10n;

  const _RecipeHistoryCard({required this.recipe, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        onTap: () => context.push('/recipe/${recipe.id}'),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(recipe.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.fileText, size: 12, color: ChefliTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n.fromText,
                        style: TextStyle(
                          fontSize: 10,
                          color: ChefliTheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.generated} ${DateTime.now().toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ChefliTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.chevronRight,
                color: ChefliTheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
