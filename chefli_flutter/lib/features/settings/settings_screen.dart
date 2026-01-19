import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final l10n = AppLocalizations.of(context);
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: context.surfaceOverlay,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  settings.textDirection == TextDirection.rtl 
                                      ? LucideIcons.chevronRight 
                                      : LucideIcons.chevronLeft,
                                  color: context.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.settings,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: context.onSurface,
                                ),
                              ),
                            ),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Notifications Section
                        _SectionTitle(l10n.notifications),
                        const SizedBox(height: 12),
                        GlassPanel(
                          borderRadius: 16,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: LucideIcons.bell,
                                title: l10n.pushNotifications,
                                subtitle: l10n.pushNotificationsSubtitle,
                                trailing: Switch(
                                  value: settings.notificationsEnabled,
                                  onChanged: (value) {
                                    settings.setNotificationsEnabled(value);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value 
                                            ? l10n.pushNotificationsEnabled 
                                            : l10n.pushNotificationsDisabled),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  activeColor: ChefliTheme.primary,
                                ),
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.mail,
                                title: l10n.emailUpdates,
                                subtitle: l10n.emailUpdatesSubtitle,
                                trailing: Switch(
                                  value: settings.emailUpdatesEnabled,
                                  onChanged: (value) {
                                    settings.setEmailUpdatesEnabled(value);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value 
                                            ? l10n.emailUpdatesEnabled 
                                            : l10n.emailUpdatesDisabled),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  activeColor: ChefliTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Settings Section
                        _SectionTitle(l10n.appSettings),
                        const SizedBox(height: 12),
                        GlassPanel(
                          borderRadius: 16,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: LucideIcons.moon,
                                title: l10n.darkMode,
                                subtitle: settings.isDarkMode ? l10n.darkThemeActive : l10n.lightThemeActive,
                                trailing: Switch(
                                  value: settings.isDarkMode,
                                  onChanged: (value) {
                                    settings.setDarkMode(value);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value 
                                            ? l10n.darkModeEnabled 
                                            : l10n.lightModeEnabled),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  activeColor: ChefliTheme.primary,
                                ),
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.save,
                                title: l10n.autoSaveRecipes,
                                subtitle: l10n.autoSaveRecipesSubtitle,
                                trailing: Switch(
                                  value: settings.autoSaveEnabled,
                                  onChanged: (value) {
                                    settings.setAutoSaveEnabled(value);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value 
                                            ? l10n.autoSaveEnabled 
                                            : l10n.autoSaveDisabled),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  activeColor: ChefliTheme.primary,
                                ),
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.globe,
                                title: l10n.languageLabel,
                                subtitle: settings.languageName,
                                trailing: Icon(
                                  settings.textDirection == TextDirection.rtl 
                                      ? LucideIcons.chevronLeft 
                                      : LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () => _showLanguageDialog(context, settings, l10n),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Account Section
                        _SectionTitle(l10n.account),
                        const SizedBox(height: 12),
                        GlassPanel(
                          borderRadius: 16,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: LucideIcons.user,
                                title: l10n.profile,
                                subtitle: l10n.manageProfile,
                                trailing: Icon(
                                  LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () => context.push('/profile'),
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.shield,
                                title: l10n.privacy,
                                subtitle: l10n.privacySettings,
                                trailing: Icon(
                                  settings.textDirection == TextDirection.rtl 
                                      ? LucideIcons.chevronLeft 
                                      : LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.privacySettingsComingSoon)),
                                  );
                                },
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.helpCircle,
                                title: l10n.helpSupport,
                                subtitle: l10n.getHelp,
                                trailing: Icon(
                                  settings.textDirection == TextDirection.rtl 
                                      ? LucideIcons.chevronLeft 
                                      : LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.helpSupportComingSoon)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        _SectionTitle(l10n.about),
                        const SizedBox(height: 12),
                        GlassPanel(
                          borderRadius: 16,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: LucideIcons.info,
                                title: l10n.appVersion,
                                subtitle: '1.0.0',
                                trailing: const SizedBox.shrink(),
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.fileText,
                                title: l10n.termsOfService,
                                trailing: Icon(
                                  settings.textDirection == TextDirection.rtl 
                                      ? LucideIcons.chevronLeft 
                                      : LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.termsComingSoon)),
                                  );
                                },
                              ),
                              Divider(height: 1, color: context.onSurfaceSecondary),
                              _SettingTile(
                                icon: LucideIcons.lock,
                                title: l10n.privacyPolicy,
                                trailing: Icon(
                                  LucideIcons.chevronRight,
                                  color: context.onSurfaceSecondary,
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.privacyPolicyComingSoon)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign Out Button
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Show confirmation dialog
                                  final shouldSignOut = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) {
                                      final dialogL10n = AppLocalizations.of(dialogContext);
                                      final theme = Theme.of(dialogContext);
                                      return AlertDialog(
                                        backgroundColor: theme.colorScheme.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        title: Text(
                                          dialogL10n.signOut,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          dialogL10n.signOutConfirmation,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext, false),
                                            child: Text(
                                              dialogL10n.cancel,
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext, true),
                                            child: Text(
                                              dialogL10n.signOut,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldSignOut == true) {
                                    // Sign out the user
                                    await auth.signOut();
                                    
                                    // Navigate to login screen
                                    if (context.mounted) {
                                      context.go('/login');
                                    }
                                    
                                    // Show success message
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.signOutConfirmation),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                                  ),
                                ),
                                child: Text(
                                  l10n.signOut,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Navigation Bar
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(activeTab: NavTab.settings),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            dialogL10n.selectLanguage,
            style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOption(
                title: dialogL10n.english,
                isSelected: settings.language == AppLanguage.english,
                onTap: () {
                  settings.setLanguage(AppLanguage.english);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(dialogL10n.languageChangedToEnglish)),
                  );
                },
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                title: dialogL10n.hebrew,
                isSelected: settings.language == AppLanguage.hebrew,
                onTap: () {
                  settings.setLanguage(AppLanguage.hebrew);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(dialogL10n.languageChangedToHebrew)),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                dialogL10n.cancel,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.onSurface,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isRtl = settings.textDirection == TextDirection.rtl;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ChefliTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: ChefliTheme.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.onSurface,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.onSurfaceSecondary,
                      ),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? ChefliTheme.primary.withOpacity(0.2) : context.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ChefliTheme.primary : context.onSurfaceSecondary,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? ChefliTheme.primary : context.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, color: ChefliTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}