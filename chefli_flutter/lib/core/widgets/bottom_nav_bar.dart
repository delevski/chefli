import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../localization/app_localizations.dart';
import 'glass_panel.dart';

enum NavTab { home, recipes, saved, settings }

class BottomNavBar extends StatelessWidget {
  final NavTab activeTab;

  const BottomNavBar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassPanel(
      borderRadius: 0,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: l10n.home,
                isActive: activeTab == NavTab.home,
                onTap: () => context.go('/'),
              ),
              _NavItem(
                icon: LucideIcons.chefHat,
                label: l10n.recipes,
                isActive: activeTab == NavTab.recipes,
                onTap: () => context.go('/home'),
              ),
              _NavItem(
                icon: LucideIcons.bookmark,
                label: l10n.saved,
                isActive: activeTab == NavTab.saved,
                onTap: () => context.go('/saved'),
              ),
              _NavItem(
                icon: LucideIcons.settings,
                label: l10n.settings,
                isActive: activeTab == NavTab.settings,
                onTap: () => context.go('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = context.onSurfaceSecondary;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? ChefliTheme.primary : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? ChefliTheme.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

