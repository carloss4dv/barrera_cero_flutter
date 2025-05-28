import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/challenge_model.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);

    // Colores adaptados para alto contraste
    final backgroundColor = challenge.isCompleted 
        ? (isHighContrastMode ? AccessibilityProvider.kAccentColor : Colors.green)
        : (isHighContrastMode ? theme.colorScheme.surface : Colors.grey[100]);
    
    final textColor = challenge.isCompleted
        ? Colors.white
        : (isHighContrastMode ? theme.colorScheme.onSurface : Colors.black87);
    
    final iconColor = challenge.isCompleted
        ? Colors.white
        : (isHighContrastMode ? AccessibilityProvider.kAccentColor : Colors.blue);

    final progressColor = isHighContrastMode 
        ? AccessibilityProvider.kAccentColor
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isHighContrastMode 
            ? Border.all(color: AccessibilityProvider.kAccentColor, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Acción al tocar el desafío (podría mostrar más detalles)
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con icono y estado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        challenge.icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${challenge.points} B-Points',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (challenge.isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Descripción
                Text(
                  challenge.description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Progreso
                if (challenge.type == ChallengeType.reports) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso:',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${challenge.currentProgress}/${challenge.target}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: textColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        challenge.isCompleted 
                            ? Colors.white 
                            : progressColor,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
