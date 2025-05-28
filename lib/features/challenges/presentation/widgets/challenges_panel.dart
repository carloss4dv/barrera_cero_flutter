import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/challenge_model.dart';
import '../../infrastructure/services/mock_challenge_service.dart';
import 'challenge_card.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';

class ChallengesPanel extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onClose;

  const ChallengesPanel({
    Key? key,
    required this.isExpanded,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ChallengesPanel> createState() => _ChallengesPanelState();
}

class _ChallengesPanelState extends State<ChallengesPanel> {
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  final MockChallengeService _challengeService = MockChallengeService();
  List<Challenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChallenges() {
    setState(() {
      _challenges = _challengeService.getMockChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);
    
    // Colores adaptados para alto contraste
    final backgroundColor = isHighContrastMode 
        ? theme.colorScheme.surface
        : Colors.white;
    final textColor = isHighContrastMode 
        ? theme.colorScheme.onSurface
        : Colors.black87;
    final accentColor = isHighContrastMode 
        ? AccessibilityProvider.kAccentColor
        : Colors.blue;

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black54,
          child: DraggableScrollableSheet(
            controller: _scrollController,
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return GestureDetector(
                onTap: () {}, // Evita que el tap cierre el panel
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    border: isHighContrastMode 
                        ? Border.all(color: AccessibilityProvider.kAccentColor, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Handle indicator
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header con título y botón de cerrar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: isHighContrastMode 
                              ? Border(bottom: BorderSide(color: AccessibilityProvider.kAccentColor))
                              : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: accentColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Desafíos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onClose,
                              icon: Icon(
                                Icons.close,
                                color: textColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lista de desafíos
                      Expanded(
                        child: _challenges.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_outlined,
                                      size: 64,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay desafíos disponibles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _challenges.length,
                                itemBuilder: (context, index) {
                                  final challenge = _challenges[index];
                                  return ChallengeCard(challenge: challenge);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}