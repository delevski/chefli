import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../models/mock_recipe.dart';

class IngredientTracker extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Set<int> usedIndices;
  final ValueChanged<int>? onIngredientToggled;
  final bool showAll;

  const IngredientTracker({
    super.key,
    required this.ingredients,
    required this.usedIndices,
    this.onIngredientToggled,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.chefHat,
                size: 20,
                color: ChefliTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                showAll ? l10n.allIngredients : l10n.ingredientsForStep,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isUsed = usedIndices.contains(index);

            return InkWell(
              onTap: onIngredientToggled != null
                  ? () => onIngredientToggled!(index)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUsed
                              ? ChefliTheme.accent
                              : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        color: isUsed
                            ? ChefliTheme.accent.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: isUsed
                          ? Icon(
                              LucideIcons.check,
                              size: 16,
                              color: ChefliTheme.accent,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isUsed
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
                          decoration: isUsed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    if (ingredient.quantity != 'unknown')
                      Text(
                        ingredient.quantity,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUsed
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white.withOpacity(0.6),
                          decoration: isUsed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
