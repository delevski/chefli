import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

          // Main content
          CustomScrollView(
            slivers: [
              // Header with proper spacing
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ChefliTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LucideIcons.chefHat,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chefli',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: context.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: context.surfaceOverlay,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // TODO: Implement notifications
                                },
                                icon: Icon(
                                  LucideIcons.bell,
                                  color: context.onSurface,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return Container(
                                  width: 40,
                                  height: 40,
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
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: GlassPanel(
                          borderRadius: 12,
                          padding: EdgeInsets.zero,
                          child: Container(
                            height: 48,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Icon(
                                    LucideIcons.search,
                                    color: context.onSurfaceSecondary,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(color: context.onSurface),
                                    decoration: InputDecoration(
                                      hintText: l10n.searchPlaceholder,
                                      hintStyle: TextStyle(
                                        color: context.onSurface.withOpacity(0.4),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: Icon(
                                      LucideIcons.sparkle,
                                      color: ChefliTheme.primary,
                                      size: 20,
                                    ),
                                    onPressed: () => context.go('/'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Category Chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _CategoryChip(l10n.categoryAll, isActive: true),
                            const SizedBox(width: 12),
                            _CategoryChip(l10n.categoryItalian),
                            const SizedBox(width: 12),
                            _CategoryChip(l10n.categoryAsian),
                            const SizedBox(width: 12),
                            _CategoryChip(l10n.categoryQuick),
                            const SizedBox(width: 12),
                            _CategoryChip(l10n.categoryVegan),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.aiPresetsForYou,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.viewAll,
                          style: TextStyle(
                            color: ChefliTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recipe Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 4 / 5,
                  ),
                  delegate: SliverChildListDelegate([
                    _RecipeCard(
                      title: 'Classic Spaghetti Carbonara',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuADyZ96WPEmeyXCGQAEEGH1K0IX2yAyaQ0VSeqXahkETcoG6Osm1HatMy6TQ06ndhqi5Vo2MfuApFVYOnJPH0roWlPILsxZzyJ6ifbRw3HgpA-eKDsu117yRXe1mepv8G41DnV-p4Xi9Fn-FHpjQJlEJ5-dYrGk6rHJDc9A__C4qG6RdxFJPPtLZELpk3iOIt9GEWw2rPw8fkj-1jzJknGsuN_JLdLUWAG1ofoYS7qwIU5wUFczlafmbAVLwRMx3K8WcanOdUEwC3ZI',
                      time: '20m',
                      difficulty: l10n.getDifficulty('easy'),
                    ),
                    _RecipeCard(
                      title: 'Authentic Miso Ramen',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSsbrUWQQobgDbHdnNMvLYw44t-s80E1KR5Zcsr8mW9R8Ie12v7_NrNwjfVhHrX_i1hELaB-Jl8kz2qjnlNhOApS3YtsWNCpZgD1vHIirDjZAkDpkfYDNYxiInVLQyQearRha-IPdK-OibRNSiFb0UxqSUicI_3_wDQxsskYpv1N8RkklCP0CVwxuaFaisa9r9E3Wt-PseazGCU53Dy0xP_raet04dUwGUcZOMi0l1N9CBcmqJmDEf4PPH5MXGx_OzdLnXSjL3uv4u',
                      time: '45m',
                      difficulty: l10n.getDifficulty('medium'),
                    ),
                    _RecipeCard(
                      title: 'Summer Quinoa Salad',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuClLUzRYSWPaurk_4TUugyOGS8u6al4dodHpRqb8RclspvZQva5huYtXuGp9WJrz3htqHUGw3tvZ8ATc46m0phMbHbaUBfIbfLFCgob_GyBrZISitNoUMl4BNZXfglFI6TItvq_YWQtglU_Wo887BWCWq5ljBITEhHUL4xlEs4mu6BI6RoA5l0ZRn-eQEOm0DNRA8Injnp_OVa89o9FcKMGHkSeUNs5UPwN-1M2LbwE8o2K8ZJ2_DaMLLTBXsF0CJEsXGF1uhfiCzs7',
                      time: '15m',
                      difficulty: l10n.getDifficulty('easy'),
                    ),
                    _RecipeCard(
                      title: 'Smashed Avocado Toast',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzWwzFQUs1gf7HNVsn8vY-MJDBsJma6LE2kbgV7h-3FEtz6TkaXO6vIxELMl1Nw_NIy0n7XxdiEALSmLVqOc4WYawLyBq_gdDUgKnndPFoFq1Jau7ULYCT9iSKRTRlJYonmjgqCB9jTVlAzNOVb7iKi1CG-WMsz4e1-wrleiZpVMtyva59-DYI_QI-_TdfhDycXoafFvyqElZMDsm9jQj-ky_5yGAHRnsXVZBDKCqbijD5E8yk2nVOseR_BDBpxo4eR3Ll2pUOfsqp',
                      time: '10m',
                      difficulty: l10n.getDifficulty('easy'),
                    ),
                  ]),
                ),
              ),

              // Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          ChefliTheme.primary,
                          Colors.orange.shade800,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.haveFoodPhoto,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.convertMealToRecipe,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ChefliTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                l10n.tryPhotoToRecipe,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            LucideIcons.camera,
                            size: 100,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom padding for nav bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),

          // Bottom Navigation Bar
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(activeTab: NavTab.recipes),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _CategoryChip(this.label, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? ChefliTheme.primary : context.surfaceOverlay,
        border: isActive ? null : Border.all(color: context.onSurface.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? Colors.white : context.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;

  const _RecipeCard({
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.bgSurface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: context.bgSurface),
          ),
          // Gradient overlay - keep black for image overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          // Content - text over image should stay white
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 12, color: ChefliTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.gauge, size: 12, color: ChefliTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      difficulty,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heart,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
