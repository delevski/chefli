import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/timer_service.dart';

class CookingTimer extends StatefulWidget {
  final TimerState? timerState;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;

  const CookingTimer({
    super.key,
    this.timerState,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onStop,
  });

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startUpdateTimer();
  }

  @override
  void didUpdateWidget(CookingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timerState != widget.timerState) {
      _startUpdateTimer();
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    if (widget.timerState?.isRunning == true) {
      _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && widget.timerState?.isRunning == true) {
          setState(() {});
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (widget.timerState == null) {
      return const SizedBox.shrink();
    }

    final timer = widget.timerState!;
    final isRunning = timer.isRunning;
    final isPaused = timer.isPaused;
    final remaining = timer.remaining;
    final isFinished = remaining.inSeconds <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFinished 
            ? ChefliTheme.accent.withOpacity(0.1)
            : ChefliTheme.primary.withOpacity(0.1),
        border: Border.all(
          color: isFinished
              ? ChefliTheme.accent.withOpacity(0.3)
              : ChefliTheme.primary.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.clock,
                color: isFinished ? ChefliTheme.accent : ChefliTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isFinished ? l10n.timerFinished : l10n.timeRemaining(remaining),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isFinished ? ChefliTheme.accent : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Timer display
          Text(
            _formatDuration(remaining),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: isFinished ? ChefliTheme.accent : ChefliTheme.primary,
              height: 1.0,
            ),
          ).animate(
            onPlay: (controller) {
              if (isRunning && !isFinished) {
                controller.repeat(reverse: true);
              }
            },
          ).scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 1000.ms,
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: 16),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRunning && !isPaused && !isFinished)
                ElevatedButton.icon(
                  onPressed: widget.onStart,
                  icon: const Icon(LucideIcons.play, size: 18),
                  label: Text(l10n.startTimer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChefliTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              if (isRunning)
                ElevatedButton.icon(
                  onPressed: widget.onPause,
                  icon: const Icon(LucideIcons.pause, size: 18),
                  label: Text(l10n.pauseTimer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              if (isPaused && !isFinished)
                ElevatedButton.icon(
                  onPressed: widget.onResume,
                  icon: const Icon(LucideIcons.play, size: 18),
                  label: Text(l10n.resumeTimer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChefliTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              if ((isRunning || isPaused) && !isFinished) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: widget.onStop,
                  icon: const Icon(LucideIcons.square, size: 18),
                  label: Text(l10n.stopTimer),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
