import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/mock_recipe.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/settings_provider.dart';

class RecipeScreen extends StatefulWidget {
  final String id;

  const RecipeScreen({super.key, required this.id});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final Set<int> _checkedIngredients = {0};

  Future<void> _shareRecipe(Recipe recipe, AppLocalizations l10n) async {
    try {
      final ingredientsList = recipe.ingredients
          .map((ing) => '• ${ing.name} ${ing.quantity != 'unknown' ? '(${ing.quantity})' : ''}')
          .join('\n');
      
      final stepsList = recipe.steps
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value}')
          .join('\n');

      final shareText = '''
${recipe.name}

${l10n.ingredients}:
$ingredientsList

${l10n.instructions}:
$stepsList

${recipe.calories != null ? '${recipe.calories} ${l10n.kcal}' : ''}
${'${recipe.time} ${l10n.minutes}'}
''';

      await Share.share(shareText, subject: recipe.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final recipeProvider = context.read<RecipeProvider>();
    await recipeProvider.toggleFavorite(recipe.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipeProvider.isFavorite(recipe.id)
                ? 'Recipe added to favorites'
                : 'Recipe removed from favorites',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: ChefliTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get recipe from provider or fallback to mock
    final recipeProvider = context.watch<RecipeProvider>();
    final recipe = recipeProvider.getRecipe(widget.id) ?? 
                   recipeProvider.currentRecipe ?? 
                   mockRecipe;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.bgSurface,
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
              // Hero Section
          SliverAppBar(
                expandedHeight: 460,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.bgSurface.withOpacity(0.6),
                        border: Border.all(
                          color: context.onSurface.withOpacity(0.1),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.chevronLeft,
                          color: context.onSurface,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                actions: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _shareRecipe(recipe, l10n),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: context.bgSurface.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.share2,
                                  color: context.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<RecipeProvider>(
                            builder: (context, recipeProvider, _) {
                              final isFavorite = recipeProvider.isFavorite(recipe.id);
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _toggleFavorite(recipe),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: context.bgSurface.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      LucideIcons.heart,
                                      color: isFavorite ? Colors.red : context.onSurface,
                                      size: 20,
                                      fill: isFavorite ? 1.0 : 0.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                    fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[900],
                        ),
                  ),
                      // Gradient Overlay
                      Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              context.bgSurface.withOpacity(0.8),
                            ],
                      ),
                    ),
                  ),
                      // Glassmorphic Title Card
                  Positioned(
                    bottom: 24,
                        left: 16,
                        right: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.bgSurface.withOpacity(0.6),
                                border: Border.all(
                                  color: context.onSurface.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                                    style: TextStyle(
                                      fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: context.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (recipe.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      recipe.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.onSurface.withOpacity(0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                        Row(
                          children: [
                                      _MetaBadge(
                                        LucideIcons.clock,
                                        '${recipe.time} ${l10n.minutes}',
                                      ),
                            const SizedBox(width: 12),
                                      _MetaBadge(
                                        LucideIcons.barChart3,
                                        l10n.getDifficulty(recipe.difficulty),
                                      ),
                                      if (recipe.calories != null) ...[
                            const SizedBox(width: 12),
                                        _MetaBadge(
                                          LucideIcons.flame,
                                          '${recipe.calories} ${l10n.kcal}',
                                        ),
                                      ],
                          ],
                        ),
                      ],
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
              // Content Section
          SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ingredients Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                          Text(
                            l10n.ingredients,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: context.onSurface,
                            ),
                          ),
                          Text(
                            '2 ${l10n.servings}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ChefliTheme.primary,
                            ),
                          ),
                        ],
                      ),
                   const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: context.surfaceOverlay,
                          border: Border.all(
                            color: context.onSurface.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Column(
                          children: recipe.ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            final isLast = index == recipe.ingredients.length - 1;
                            return _IngredientCheckbox(
                              ingredient: ingredient,
                              isChecked: _checkedIngredients.contains(index),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _checkedIngredients.add(index);
                                  } else {
                                    _checkedIngredients.remove(index);
                                  }
                                });
                              },
                              showBorder: !isLast,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Instructions Section
                      Text(
                        l10n.instructions,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: context.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...recipe.steps.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _StepCard(
                            number: entry.key + 1,
                            step: entry.value,
                          ),
                        );
                      }),
                   const SizedBox(height: 32),
                      // Nutrition Section
                      Text(
                        l10n.nutritionFacts,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: context.onSurface,
                        ),
                      ),
                   const SizedBox(height: 16),
                      // Wrap GridView in a container to prevent cutoff
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _NutritionCard(
                              l10n.protein, 
                              recipe.protein != null ? '${recipe.protein!.toStringAsFixed(0)}g' : '-',
                              isPrimary: true,
                            ),
                            _NutritionCard(
                              l10n.carbs, 
                              recipe.carbohydrates != null ? '${recipe.carbohydrates!.toStringAsFixed(0)}g' : '-',
                            ),
                            _NutritionCard(
                              l10n.fats, 
                              recipe.fats != null ? '${recipe.fats!.toStringAsFixed(0)}g' : '-',
                            ),
                            _NutritionCard(
                              l10n.fiber, 
                              // Estimate fiber based on carbs (rough estimate: ~10% of carbs)
                              recipe.carbohydrates != null && recipe.carbohydrates! > 0
                                  ? '${(recipe.carbohydrates! * 0.1).toStringAsFixed(0)}g'
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.bgSurface.withOpacity(0.95),
                    context.bgSurface,
                  ],
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/cooking/${recipe.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChefliTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: ChefliTheme.primary.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.playCircle, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          l10n.startCooking,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardOverlay,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ChefliTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientCheckbox extends StatelessWidget {
  final Ingredient ingredient;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final bool showBorder;

  const _IngredientCheckbox({
    required this.ingredient,
    required this.isChecked,
    required this.onChanged,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.cardBorder,
                ),
              ),
            )
          : null,
      child: CheckboxListTile(
        value: isChecked,
        onChanged: onChanged,
        activeColor: ChefliTheme.primary,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          ingredient.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.onSurface,
          ),
        ),
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(
          color: context.inputBorder,
          width: 2,
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String step;

  const _StepCard({required this.number, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardOverlay,
        border: Border.all(
          color: context.cardBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ChefliTheme.primary,
                  const Color(0xFFd46b08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: ChefliTheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Stays white - on orange gradient
                  fontSize: 14,
                ),
              ),
              ),
            ),
            const SizedBox(width: 16),
          Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.textMuted,
                                  height: 1.5,
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _NutritionCard(this.label, this.value, {this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isHebrew = settings.language == AppLanguage.hebrew;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary
            ? ChefliTheme.primary.withOpacity(0.1)
            : context.cardOverlay,
        border: Border.all(
          color: isPrimary
              ? ChefliTheme.primary.withOpacity(0.2)
              : context.cardBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHebrew ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: context.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPrimary ? ChefliTheme.primary : context.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
