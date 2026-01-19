import 'dart:async';

class TimerState {
  final int stepIndex;
  final Duration duration;
  Duration remaining;
  bool isRunning;
  bool isPaused;
  Timer? _timer;
  final Function(int stepIndex)? onComplete;
  final Function(int stepIndex, Duration remaining)? onTick;

  TimerState({
    required this.stepIndex,
    required this.duration,
    required this.remaining,
    this.isRunning = false,
    this.isPaused = false,
    this.onComplete,
    this.onTick,
  });

  void start() {
    if (isRunning || remaining.inSeconds <= 0) return;
    
    isRunning = true;
    isPaused = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds > 0) {
        remaining = Duration(seconds: remaining.inSeconds - 1);
        onTick?.call(stepIndex, remaining);
      } else {
        stop();
        onComplete?.call(stepIndex);
      }
    });
  }

  void pause() {
    if (!isRunning) return;
    _timer?.cancel();
    isRunning = false;
    isPaused = true;
  }

  void resume() {
    if (!isPaused || remaining.inSeconds <= 0) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    isPaused = false;
  }

  void reset() {
    stop();
    remaining = duration;
  }

  void dispose() {
    stop();
  }
}

class TimerService {
  final Map<int, TimerState> _activeTimers = {};

  /// Parse time duration from step text
  /// Supports formats like: "5 minutes", "3 mins", "(5 mins)", "for 3 minutes", "1 min", "30 seconds"
  static Duration? parseTimeFromStep(String stepText) {
    // Try to match patterns like "5 minutes", "3 mins", "(5 mins)", etc.
    final patterns = [
      // Minutes patterns
      RegExp(r'\((\d+)\s*(?:min|minute|minutes|mins)\)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:min|minute|minutes|mins)', caseSensitive: false),
      RegExp(r'for\s+(\d+)\s*(?:min|minute|minutes|mins)', caseSensitive: false),
      // Seconds patterns
      RegExp(r'\((\d+)\s*(?:sec|second|seconds|secs)\)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:sec|second|seconds|secs)', caseSensitive: false),
      RegExp(r'for\s+(\d+)\s*(?:sec|second|seconds|secs)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(stepText);
      if (match != null) {
        final value = int.tryParse(match.group(1) ?? '');
        if (value != null && value > 0) {
          // Check if it's seconds or minutes
          final unit = match.group(0)?.toLowerCase() ?? '';
          if (unit.contains('sec')) {
            return Duration(seconds: value);
          } else {
            return Duration(minutes: value);
          }
        }
      }
    }

    // If no explicit unit found, try to extract just numbers and assume minutes
    final numberMatch = RegExp(r'(\d+)').firstMatch(stepText);
    if (numberMatch != null) {
      final value = int.tryParse(numberMatch.group(1) ?? '');
      if (value != null && value > 0 && value <= 60) {
        // Only assume minutes if the number is reasonable (1-60)
        return Duration(minutes: value);
      }
    }

    return null;
  }

  /// Create a timer for a step
  TimerState? createTimer({
    required int stepIndex,
    required String stepText,
    Function(int stepIndex)? onComplete,
    Function(int stepIndex, Duration remaining)? onTick,
  }) {
    final duration = parseTimeFromStep(stepText);
    if (duration == null) return null;

    final timerState = TimerState(
      stepIndex: stepIndex,
      duration: duration,
      remaining: duration,
      onComplete: onComplete,
      onTick: onTick,
    );

    _activeTimers[stepIndex] = timerState;
    return timerState;
  }

  /// Get timer for a step
  TimerState? getTimer(int stepIndex) {
    return _activeTimers[stepIndex];
  }

  /// Stop and remove a timer
  void removeTimer(int stepIndex) {
    _activeTimers[stepIndex]?.dispose();
    _activeTimers.remove(stepIndex);
  }

  /// Stop all timers
  void stopAllTimers() {
    for (var timer in _activeTimers.values) {
      timer.dispose();
    }
    _activeTimers.clear();
  }

  /// Dispose all timers
  void dispose() {
    stopAllTimers();
  }
}
