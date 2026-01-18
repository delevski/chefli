import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class ProcessingScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  
  const ProcessingScreen({
    super.key,
    this.onCancel,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  
  int _currentPhaseIndex = 0;
  int _currentQuoteIndex = 0;
  
  List<String> _phases = [];
  List<String> _quotes = [];

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
      // Update phase based on progress
      if (_phases.isNotEmpty) {
      final newPhaseIndex = (_progressController.value * _phases.length).floor();
      if (newPhaseIndex != _currentPhaseIndex && newPhaseIndex < _phases.length) {
        setState(() => _currentPhaseIndex = newPhaseIndex);
        }
      }
    });
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _progressController.forward();
    
    // Cycle quotes
    Future.delayed(const Duration(seconds: 4), _cycleQuotes);
  }
  
  void _cycleQuotes() {
    if (!mounted) return;
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
    });
    Future.delayed(const Duration(seconds: 4), _cycleQuotes);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Initialize phases and quotes if not already set
    if (_phases.isEmpty) {
      _phases = l10n.processingPhases;
      _quotes = l10n.quotes;
    }
    return Scaffold(
      backgroundColor: ChefliTheme.bgMain,
      body: Container(
        decoration: BoxDecoration(
          color: ChefliTheme.bgMain,
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              ChefliTheme.primary.withOpacity(0.08),
              ChefliTheme.bgMain,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Rings Container
                    _buildAnimatedRings(),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      l10n.chefliCraftingMasterpiece,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // Current Phase
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _phases[_currentPhaseIndex],
                        key: ValueKey(_currentPhaseIndex),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ChefliTheme.primary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // AI Engine
                    Text(
                      l10n.aiEngineGpt4,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Efficiency Engine
                    _buildEfficiencyBar(),
                    
                    const SizedBox(height: 24),
                    
                    // Quote
                    _buildQuote(),
                  ],
                ),
              ),
              
              // Bottom Icons
              _buildBottomIcons(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              // Close Button
              GestureDetector(
                onTap: widget.onCancel,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Processing Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated dot
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ChefliTheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: ChefliTheme.primary.withOpacity(0.5 * _pulseController.value),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.processing.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              const SizedBox(width: 48), // Balance for close button
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedRings() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 260 + (_pulseController.value * 20),
                height: 260 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ChefliTheme.primary.withOpacity(0.15 * _pulseController.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Glass container
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white.withOpacity(0.03),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          
          // Outer rotating ring (orange)
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _RingPainter(
                    color: ChefliTheme.primary,
                    strokeWidth: 3,
                    progress: 0.75,
                  ),
                ),
              );
            },
          ),
          
          // Inner rotating ring (green/teal)
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi * 0.7,
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _RingPainter(
                    color: ChefliTheme.accent.withOpacity(0.6),
                    strokeWidth: 2,
                    progress: 0.6,
                  ),
                ),
              );
            },
          ),
          
          // Center pot icon
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  LucideIcons.soup,
                  size: 48,
                  color: ChefliTheme.primary,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scaleXY(
                begin: 1.0,
                end: 1.08,
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
              
              const SizedBox(height: 12),
              
              // Dot indicators
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPhaseIndex % 3
                          ? ChefliTheme.primary
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
  
  Widget _buildEfficiencyBar() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.efficiencyEngine.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Text(
                        '${(_progressController.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          ChefliTheme.accent,
                          ChefliTheme.primary.withOpacity(0.5),
                          Colors.white.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
        );
      },
    );
  }
  
  Widget _buildQuote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          _quotes[_currentQuoteIndex],
          key: ValueKey(_currentQuoteIndex),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.white.withOpacity(0.4),
            height: 1.4,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _BottomIcon(icon: LucideIcons.utensils),
        const SizedBox(width: 48),
        _BottomIcon(icon: LucideIcons.flame),
        const SizedBox(width: 48),
        _BottomIcon(icon: LucideIcons.soup),
      ],
    ).animate(delay: 400.ms).fadeIn().moveY(begin: 20, end: 0);
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  
  const _BottomIcon({required this.icon});
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 24,
      color: Colors.white.withOpacity(0.25),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;
  
  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}



