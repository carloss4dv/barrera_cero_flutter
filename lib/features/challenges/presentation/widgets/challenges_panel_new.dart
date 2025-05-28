import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/challenge_model.dart';
import '../../infrastructure/services/mock_challenge_service.dart';
import 'challenge_card.dart';

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
  MockChallengeService? _challengeService;
  List<Challenge> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeService() {
    // Obtener los servicios de GetIt
    try {
      _challengeService = GetIt.instance<MockChallengeService>();
      _loadChallenges();
    } catch (e) {
      // Si no se pueden obtener los servicios, mostrar lista vacía
      setState(() {
        _challenges = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChallenges() async {
    if (_challengeService == null) return;
    
    try {
      final challenges = await _challengeService!.getChallenges();
      if (mounted) {
        setState(() {
          _challenges = challenges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _challenges = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    // Colores estándar
    final backgroundColor = Colors.white;
    final textColor = Colors.black87;
    final accentColor = Colors.blue;

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
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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

                      // Contenido scrolleable
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : _challenges.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.emoji_events_outlined,
                                          size: 64,
                                          color: textColor.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No hay desafíos disponibles',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _challenges.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
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
