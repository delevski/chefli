import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/mock_recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../services/timer_service.dart';
import '../../services/voice_service.dart';
import 'widgets/cooking_step_card.dart';
import 'widgets/cooking_timer.dart';
import 'widgets/ingredient_tracker.dart';

class CookingScreen extends StatefulWidget {
  final String recipeId;

  const CookingScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final TimerService _timerService = TimerService();
  final VoiceService _voiceService = VoiceService();
  final PageController _pageController = PageController();

  int _currentStepIndex = 0;
  final Set<int> _completedSteps = {};
  final Set<int> _usedIngredients = {};
  bool _showAllIngredients = false;
  bool _isVoiceListening = false;

  Recipe? _recipe;
  TimerState? _currentTimer;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
    _initializeVoiceService();
  }

  Future<void> _loadRecipe() async {
    final recipeProvider = context.read<RecipeProvider>();
    final recipe = recipeProvider.getRecipe(widget.recipeId) ??
                   recipeProvider.currentRecipe ??
                   mockRecipe;
    
    setState(() {
      _recipe = recipe;
    });

    // Create timer for first step if it has time
    if (recipe.steps.isNotEmpty) {
      _createTimerForStep(0);
    }
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
    _voiceService.onCommandRecognized = _handleVoiceCommand;
  }

  void _handleVoiceCommand(VoiceCommand command) {
    switch (command) {
      case VoiceCommand.nextStep:
        _goToNextStep();
        break;
      case VoiceCommand.previousStep:
        _goToPreviousStep();
        break;
      case VoiceCommand.startTimer:
        _currentTimer?.start();
        setState(() {});
        break;
      case VoiceCommand.stopTimer:
        _currentTimer?.stop();
        setState(() {});
        break;
      case VoiceCommand.completeStep:
        _completeCurrentStep();
        break;
      case VoiceCommand.repeatStep:
        // Could implement TTS here to read the step
        break;
      case VoiceCommand.unknown:
        break;
    }
  }

  void _createTimerForStep(int stepIndex) {
    if (_recipe == null || stepIndex >= _recipe!.steps.length) return;

    final stepText = _recipe!.steps[stepIndex];
    final timer = _timerService.createTimer(
      stepIndex: stepIndex,
      stepText: stepText,
      onComplete: (index) {
        if (mounted) {
          setState(() {
            // Timer completed - could auto-advance or show notification
          });
          _showTimerCompleteNotification();
        }
      },
      onTick: (index, remaining) {
        if (mounted) {
          setState(() {
            // Update UI with remaining time
          });
        }
      },
    );

    setState(() {
      _currentTimer = timer;
    });
  }

  void _showTimerCompleteNotification() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.bell, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.timerFinished),
          ],
        ),
        backgroundColor: ChefliTheme.accent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goToNextStep() {
    if (_recipe == null) return;
    if (_currentStepIndex < _recipe!.steps.length - 1) {
      _currentTimer?.stop();
      setState(() {
        _currentStepIndex++;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _createTimerForStep(_currentStepIndex);
    }
  }

  void _goToPreviousStep() {
    if (_currentStepIndex > 0) {
      _currentTimer?.stop();
      setState(() {
        _currentStepIndex--;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _createTimerForStep(_currentStepIndex);
    }
  }

  void _completeCurrentStep() {
    setState(() {
      _completedSteps.add(_currentStepIndex);
    });

    // Auto-advance to next step if not last step
    if (_currentStepIndex < (_recipe?.steps.length ?? 0) - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _goToNextStep();
      });
    } else {
      // All steps complete
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ChefliTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: ChefliTheme.accent, size: 32),
            const SizedBox(width: 12),
            Text(
              l10n.cookingComplete,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '${_recipe?.name ?? "Recipe"} is ready!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: Text(
              l10n.returnToRecipe,
              style: const TextStyle(color: ChefliTheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentStepIndex = 0;
                _completedSteps.clear();
                _usedIngredients.clear();
              });
              _pageController.jumpToPage(0);
              _createTimerForStep(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ChefliTheme.primary,
            ),
            child: Text(
              l10n.restartCooking,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVoiceListening() {
    if (_isVoiceListening) {
      _voiceService.stopListening();
      setState(() {
        _isVoiceListening = false;
      });
    } else {
      _voiceService.startListening(onCommand: _handleVoiceCommand);
      setState(() {
        _isVoiceListening = true;
      });
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    _voiceService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_recipe == null) {
      return Scaffold(
        backgroundColor: ChefliTheme.bgSurface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalSteps = _recipe!.steps.length;
    final progress = totalSteps > 0 ? (_completedSteps.length / totalSteps) : 0.0;

    return Scaffold(
      backgroundColor: ChefliTheme.bgSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recipe!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.stepXOfY(_currentStepIndex + 1, totalSteps),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceListening ? LucideIcons.mic : LucideIcons.micOff,
              color: _isVoiceListening ? ChefliTheme.accent : Colors.white70,
            ),
            onPressed: _toggleVoiceListening,
            tooltip: _isVoiceListening
                ? l10n.voiceCommandListening
                : 'Enable voice commands',
          ),
          IconButton(
            icon: Icon(
              _showAllIngredients ? LucideIcons.eyeOff : LucideIcons.eye,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showAllIngredients = !_showAllIngredients;
              });
            },
            tooltip: _showAllIngredients ? 'Hide all ingredients' : 'Show all ingredients',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.cookingProgress,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(_completedSteps.length / totalSteps * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(ChefliTheme.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalSteps, (index) {
                    final isCompleted = _completedSteps.contains(index);
                    final isCurrent = index == _currentStepIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? ChefliTheme.accent
                            : isCurrent
                                ? ChefliTheme.primary
                                : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _currentTimer?.stop();
                setState(() {
                  _currentStepIndex = index;
                });
                _createTimerForStep(index);
              },
              itemCount: totalSteps,
              itemBuilder: (context, index) {
                final stepText = _recipe!.steps[index];
                final isCompleted = _completedSteps.contains(index);
                final isCurrent = index == _currentStepIndex;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step card
                      CookingStepCard(
                        stepNumber: index + 1,
                        stepText: stepText,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                      ),
                      const SizedBox(height: 16),
                      // Timer (if step has time)
                      if (_currentTimer != null && index == _currentStepIndex)
                        CookingTimer(
                          timerState: _currentTimer,
                          onStart: () {
                            _currentTimer?.start();
                            setState(() {});
                          },
                          onPause: () {
                            _currentTimer?.pause();
                            setState(() {});
                          },
                          onResume: () {
                            _currentTimer?.resume();
                            setState(() {});
                          },
                          onStop: () {
                            _currentTimer?.stop();
                            setState(() {});
                          },
                        ),
                      // Ingredient tracker
                      IngredientTracker(
                        ingredients: _showAllIngredients
                            ? _recipe!.ingredients
                            : _recipe!.ingredients, // Could filter by step
                        usedIndices: _usedIngredients,
                        onIngredientToggled: (index) {
                          setState(() {
                            if (_usedIngredients.contains(index)) {
                              _usedIngredients.remove(index);
                            } else {
                              _usedIngredients.add(index);
                            }
                          });
                        },
                        showAll: _showAllIngredients,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Navigation controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ChefliTheme.bgSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Previous button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStepIndex > 0 ? _goToPreviousStep : null,
                      icon: const Icon(LucideIcons.chevronLeft),
                      label: Text(l10n.previousStep),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: _currentStepIndex > 0
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Complete step button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _completeCurrentStep,
                      icon: Icon(
                        _completedSteps.contains(_currentStepIndex)
                            ? LucideIcons.checkCircle
                            : LucideIcons.check,
                      ),
                      label: Text(l10n.completeStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _completedSteps.contains(_currentStepIndex)
                            ? ChefliTheme.accent
                            : ChefliTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStepIndex < totalSteps - 1
                          ? _goToNextStep
                          : null,
                      icon: const Icon(LucideIcons.chevronRight),
                      label: Text(l10n.nextStep),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: _currentStepIndex < totalSteps - 1
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
