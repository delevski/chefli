import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/recipe_service.dart';
import '../../services/media_processing_service.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/auth_provider.dart';
import '../processing/processing_screen.dart';
import '../auth/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final MediaProcessingService _mediaService = MediaProcessingService();
  
  bool _isLoading = false;
  bool _hasFocus = false;
  bool _isRecording = false;
  
  // Attached files
  List<File> _attachedImages = [];
  List<File> _attachedFiles = [];
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // Request permissions
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.permissionRequired),
            action: SnackBarAction(
              label: l10n.settings,
              onPressed: () => openAppSettings(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }
    return true;
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.camera, color: ChefliTheme.primary),
              title: Text(l10n.takePhoto, style: TextStyle(color: sheetContext.onSurface)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  await _processImage(File(image.path));
                }
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: ChefliTheme.primary),
              title: Text(l10n.chooseFromGallery, style: TextStyle(color: sheetContext.onSurface)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final images = await _imagePicker.pickMultiImage(imageQuality: 80);
                if (images.isNotEmpty) {
                  for (final img in images) {
                    await _processImage(File(img.path));
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Pick files (PDF, documents, etc.)
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: false,
        withReadStream: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        
        final l10n = AppLocalizations.of(context);
        setState(() {
          _attachedFiles.addAll(files);
          final fileNames = result.files.map((f) => f.name).join(', ');
          _controller.text += _controller.text.isEmpty 
              ? '${l10n.filesAttached} $fileNames]' 
              : ' ${l10n.filesAttached} $fileNames]';
        });
        _showAttachmentSuccess('${files.length} ${l10n.filesAdded}');
      }
      } catch (e) {
        final l10n = AppLocalizations.of(context);
        _showError('${l10n.error}: $e');
      }
  }

  // Process image with OCR
  Future<void> _processImage(File imageFile) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Extracting text from image...'),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      // Extract text from image using OCR
      // Support multiple languages: English, Hebrew, Arabic
      final extractedText = await _mediaService.extractTextFromImage(
        imageFile,
        languageHints: ['eng', 'heb', 'ara'], // English, Hebrew, Arabic
      );

      // Add image to attachments
      setState(() {
        _attachedImages.add(imageFile);
      });

      // Append extracted text to input field
      setState(() {
        if (_controller.text.isNotEmpty && !_controller.text.endsWith('\n')) {
          _controller.text += '\n';
        }
        _controller.text += extractedText;
      });

      _showAttachmentSuccess('Image processed: ${extractedText.length} characters extracted');
    } catch (e) {
      _showError('Failed to extract text: ${e.toString()}');
      // Still add image even if OCR fails
      setState(() {
        _attachedImages.add(imageFile);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Process audio with transcription
  Future<void> _processAudio(File audioFile) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Transcribing audio...'),
            ],
          ),
          duration: const Duration(seconds: 60),
        ),
      );

      // Transcribe audio
      // Language code: 'en' for English, 'he' for Hebrew, 'ar' for Arabic
      final transcribedText = await _mediaService.transcribeAudio(
        audioFile,
        languageCode: 'en', // Change based on user's language preference
      );

      // Append transcribed text to input field
      setState(() {
        if (_controller.text.isNotEmpty && !_controller.text.endsWith('\n')) {
          _controller.text += '\n';
        }
        _controller.text += transcribedText;
      });

      _showAttachmentSuccess('Audio transcribed: ${transcribedText.length} characters');
    } catch (e) {
      _showError('Failed to transcribe audio: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  // Toggle audio recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isRecording = false;
        if (path != null) {
          _recordingPath = path;
        }
      });
      
      if (path != null) {
        // Transcribe the audio
        await _processAudio(File(path));
      }
    } else {
      // Start recording
      final hasPermission = await _requestPermission(Permission.microphone);
      if (!hasPermission) return;

      try {
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(dir.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        
        setState(() {
          _isRecording = true;
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.mic, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(l10n.recording),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(days: 1), // Keep until stopped
          ),
        );
      } catch (e) {
        final l10n = AppLocalizations.of(context);
        _showError('${l10n.error}: $e');
      }
    }
  }

  // Play/video picker placeholder
  Future<void> _pickVideo() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.video, color: ChefliTheme.primary),
              title: Text(l10n.recordVideo, style: TextStyle(color: sheetContext.onSurface)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final video = await _imagePicker.pickVideo(
                  source: ImageSource.camera,
                  maxDuration: const Duration(minutes: 2),
                );
                if (video != null) {
                  setState(() {
                    _attachedFiles.add(File(video.path));
                    _controller.text += _controller.text.isEmpty 
                        ? l10n.videoAttached 
                        : ' ${l10n.videoAttached}';
                  });
                  _showAttachmentSuccess(l10n.videoRecorded);
                }
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.film, color: ChefliTheme.primary),
              title: Text(l10n.chooseFromGallery, style: TextStyle(color: sheetContext.onSurface)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  setState(() {
                    _attachedFiles.add(File(video.path));
                    _controller.text += _controller.text.isEmpty 
                        ? l10n.videoAttached 
                        : ' ${l10n.videoAttached}';
                  });
                  _showAttachmentSuccess(l10n.videoAdded);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSuccess(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: ChefliTheme.accent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleCook() async {
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim().isEmpty && _attachedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterIngredientsOrImage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Parse ingredients from user input
    final ingredients = _controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('['))
        .toList();

    if (ingredients.isEmpty && _attachedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterAtLeastOneIngredient),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is logged in
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      // Show login screen as a modal
      final loggedIn = await _showLoginModal();
      if (!loggedIn) return; // User cancelled login
    }

    // Show processing screen
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _ProcessingWrapper(
            ingredients: ingredients.isEmpty ? ['food from image'] : ingredients,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // Clear attachments if recipe was generated successfully
    if (result == true && mounted) {
      _controller.clear();
      _attachedImages.clear();
      _attachedFiles.clear();
      _recordingPath = null;
    }
  }

  Future<bool> _showLoginModal() async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return LoginScreen(
            onLoginSuccess: () {
              Navigator.of(context).pop(true);
            },
            onClose: () {
              Navigator.of(context).pop(false);
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.bgMain,
      body: Container(
        color: context.bgMain,
        child: Stack(
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
                      top: -40,
                      right: -40,
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
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -40,
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
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top App Bar (no mock status bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ChefliTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.utensils,
                          color: ChefliTheme.bgMain,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Chefli',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return GestureDetector(
                            onTap: () {
                              if (auth.isLoggedIn) {
                                context.push('/profile');
                              } else {
                                context.push('/login');
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.surfaceOverlay,
                                border: Border.all(
                                  color: context.onSurface.withOpacity(0.1),
                                ),
                              ),
                              child: Icon(
                                auth.isLoggedIn ? LucideIcons.user : LucideIcons.logIn,
                                color: ChefliTheme.primary,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Main Content
            Center(
                child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 120),
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Section
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1,
                              color: context.onSurface,
                            ),
                            children: [
                              TextSpan(text: '${l10n.whatAreWeCooking}\n'),
                              TextSpan(
                                text: l10n.today.trim(),
                                style: TextStyle(color: ChefliTheme.primary),
                              ),
                            ],
                              ),
                        ).animate().fadeIn().moveY(begin: -20, end: 0),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 280,
                          child: Text(
                            l10n.describeIngredientsOrUpload,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.onSurfaceSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Composer Area
                    GlassPanel(
                      borderRadius: 16.0,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.surfaceOverlay,
                                  border: Border.all(
                                    color: context.onSurface.withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(
                                  LucideIcons.sparkle,
                                  color: context.onSurfaceSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                          child: TextField(
                            controller: _controller,
                                  focusNode: _focusNode,
                            maxLines: null,
                                  minLines: 3,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: context.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.ingredientPlaceholder,
                                    hintStyle: TextStyle(
                                      color: context.onSurface.withOpacity(0.3),
                                    ),
                              border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Show attached files preview
                          if (_attachedImages.isNotEmpty || _attachedFiles.isNotEmpty || _recordingPath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ..._attachedImages.map((img) => _AttachmentChip(
                                    icon: LucideIcons.image,
                                    label: l10n.image,
                                    onRemove: () => setState(() => _attachedImages.remove(img)),
                                  )),
                                  ..._attachedFiles.map((file) => _AttachmentChip(
                                    icon: LucideIcons.file,
                                    label: p.basename(file.path),
                                    onRemove: () => setState(() => _attachedFiles.remove(file)),
                                  )),
                                  if (_recordingPath != null)
                                    _AttachmentChip(
                                      icon: LucideIcons.mic,
                                      label: l10n.voice,
                                      onRemove: () => setState(() => _recordingPath = null),
                                    ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Multimodal Icons
                          Row(
                            children: [
                              _MediaButton(
                                icon: LucideIcons.image,
                                isActive: _attachedImages.isNotEmpty,
                                onTap: _pickImage,
                              ),
                              const SizedBox(width: 8),
                              _MediaButton(
                                icon: LucideIcons.paperclip,
                                isActive: _attachedFiles.isNotEmpty,
                                onTap: _pickFiles,
                              ),
                              const SizedBox(width: 8),
                              _MediaButton(
                                icon: LucideIcons.mic,
                                isActive: _isRecording,
                                isRecording: _isRecording,
                                onTap: _toggleRecording,
                              ),
                              const SizedBox(width: 8),
                              _MediaButton(
                                icon: LucideIcons.playCircle,
                                onTap: _pickVideo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Cook Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleCook,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ChefliTheme.primary,
                                foregroundColor: ChefliTheme.bgMain,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(ChefliTheme.bgMain),
                                      ),
                                    )
                                  else
                                    const Icon(LucideIcons.zap, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isLoading ? l10n.cooking : l10n.cook,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Suggestion Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: [
                          _SuggestionChip(l10n.quickSalad, onTap: () {
                            _controller.text = l10n.quickSaladIngredients;
                          }),
                          const SizedBox(width: 12),
                          _SuggestionChip(l10n.pastaNight, onTap: () {
                            _controller.text = l10n.pastaNightIngredients;
                          }),
                          const SizedBox(width: 12),
                          _SuggestionChip(l10n.highProtein, onTap: () {
                            _controller.text = l10n.highProteinIngredients;
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(activeTab: NavTab.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isRecording;

  const _MediaButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isRecording 
              ? Colors.red.withOpacity(0.3)
              : isActive 
                  ? ChefliTheme.primary.withOpacity(0.2)
                  : context.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
          border: isActive || isRecording
              ? Border.all(color: isRecording ? Colors.red : ChefliTheme.primary, width: 1.5)
              : null,
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: isRecording 
              ? Colors.red 
              : isActive 
                  ? ChefliTheme.primary 
                  : context.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _AttachmentChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ChefliTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ChefliTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(icon, size: 14, color: ChefliTheme.primary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ChefliTheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(LucideIcons.x, size: 14, color: ChefliTheme.primary),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SuggestionChip(this.label, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceOverlay,
          border: Border.all(color: context.onSurface.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: context.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that shows the processing screen while generating recipe
class _ProcessingWrapper extends StatefulWidget {
  final List<String> ingredients;

  const _ProcessingWrapper({required this.ingredients});

  @override
  State<_ProcessingWrapper> createState() => _ProcessingWrapperState();
}

class _ProcessingWrapperState extends State<_ProcessingWrapper> {
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _generateRecipe();
  }

  Future<void> _generateRecipe() async {
    try {
      final recipeService = RecipeService();
      final recipe = await recipeService.generateRecipe(widget.ingredients);

      if (!_isCancelled && mounted) {
        // Store recipe in provider
        context.read<RecipeProvider>().setCurrentRecipe(recipe);
        
        // Pop the processing screen and navigate to recipe
        Navigator.of(context).pop(true);
        context.push('/recipe/${recipe.id}');
      }
    } catch (e) {
      if (!_isCancelled && mounted) {
        final l10n = AppLocalizations.of(context);
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorGeneratingRecipe}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handleCancel() {
    _isCancelled = true;
    Navigator.of(context).pop(false);
  }  @override
  Widget build(BuildContext context) {
    return ProcessingScreen(
      onCancel: _handleCancel,
    );
  }
}