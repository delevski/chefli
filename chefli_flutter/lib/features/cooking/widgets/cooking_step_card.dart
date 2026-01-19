import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CookingStepCard extends StatelessWidget {
  final int stepNumber;
  final String stepText;
  final bool isCompleted;
  final bool isCurrent;

  const CookingStepCard({
    super.key,
    required this.stepNumber,
    required this.stepText,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCurrent
            ? ChefliTheme.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        border: Border.all(
          color: isCurrent
              ? ChefliTheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isCompleted || isCurrent
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ChefliTheme.primary,
                            const Color(0xFFd46b08),
                          ],
                        )
                      : null,
                  color: isCompleted || isCurrent
                      ? null
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: ChefliTheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Step $stepNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stepText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: isCompleted
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
