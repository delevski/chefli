import 'package:speech_to_text/speech_to_text.dart' as stt;

enum VoiceCommand {
  nextStep,
  previousStep,
  startTimer,
  stopTimer,
  completeStep,
  repeatStep,
  unknown,
}

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  Function(VoiceCommand)? onCommandRecognized;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
      onError: (error) {
        print('Speech recognition error: $error');
        _isListening = false;
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return _isAvailable;
  }

  /// Start listening for voice commands
  Future<void> startListening({
    Function(VoiceCommand)? onCommand,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) return;

    onCommandRecognized = onCommand;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final command = _parseCommand(result.recognizedWords);
          onCommandRecognized?.call(command);
          // Stop listening after recognizing a command
          stopListening();
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      localeId: 'en_US', // Can be made configurable
    );
  }

  /// Stop listening
  void stopListening() {
    if (!_isListening) return;
    _speech.stop();
    _isListening = false;
  }

  /// Cancel listening
  void cancel() {
    _speech.cancel();
    _isListening = false;
  }

  /// Parse recognized text into voice commands
  VoiceCommand _parseCommand(String text) {
    final lowerText = text.toLowerCase().trim();

    // Next step commands
    if (lowerText.contains('next') && 
        (lowerText.contains('step') || lowerText.contains('instruction'))) {
      return VoiceCommand.nextStep;
    }

    // Previous step commands
    if ((lowerText.contains('previous') || lowerText.contains('back') || lowerText.contains('last')) &&
        (lowerText.contains('step') || lowerText.contains('instruction'))) {
      return VoiceCommand.previousStep;
    }

    // Start timer commands
    if ((lowerText.contains('start') || lowerText.contains('begin')) &&
        (lowerText.contains('timer') || lowerText.contains('time'))) {
      return VoiceCommand.startTimer;
    }

    // Stop timer commands
    if ((lowerText.contains('stop') || lowerText.contains('pause') || lowerText.contains('cancel')) &&
        (lowerText.contains('timer') || lowerText.contains('time'))) {
      return VoiceCommand.stopTimer;
    }

    // Complete step commands
    if ((lowerText.contains('complete') || lowerText.contains('done') || lowerText.contains('finish')) &&
        (lowerText.contains('step') || lowerText.contains('instruction'))) {
      return VoiceCommand.completeStep;
    }

    // Repeat step commands
    if ((lowerText.contains('repeat') || lowerText.contains('read') || lowerText.contains('say')) &&
        (lowerText.contains('step') || lowerText.contains('instruction'))) {
      return VoiceCommand.repeatStep;
    }

    return VoiceCommand.unknown;
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _speech.cancel();
  }
}
