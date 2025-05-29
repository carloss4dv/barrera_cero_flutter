import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/challenge_model.dart';
import '../../infrastructure/services/mock_challenge_service.dart';
import '../../../../services/local_user_storage_service.dart';
import 'challenge_card.dart';
import 'distance_tracking_control.dart';

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
    print('=== DEBUG: ChallengesPanel._initializeService() INICIANDO ===');
    // Obtener los servicios de GetIt
    try {
      print('=== DEBUG: Obteniendo MockChallengeService de GetIt ===');
      _challengeService = GetIt.instance<MockChallengeService>();
      print('=== DEBUG: MockChallengeService obtenido correctamente ===');
      
      // Configurar callback para notificaciones de desafíos completados
      _challengeService!.onChallengeCompleted = (challenge, pointsAwarded) {
        if (mounted) {
          _showChallengeCompletedNotificationOnce(challenge, pointsAwarded);
        }
      };
      
      _loadChallenges();
    } catch (e) {
      print('=== ERROR: No se pudo obtener MockChallengeService: $e ===');
      // Si no se pueden obtener los servicios, mostrar lista vacía
      setState(() {
        _challenges = [];
        _isLoading = false;
      });
    }
  }

  /// Verificar si una notificación ya fue mostrada
  Future<bool> _wasNotificationAlreadyShown(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notification_shown_${challengeId}_$userId';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('ERROR: Error verificando notificación: $e');
      return false;
    }
  }

  /// Marcar una notificación como mostrada
  Future<void> _markNotificationAsShown(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notification_shown_${challengeId}_$userId';
      await prefs.setBool(key, true);
      print('=== DEBUG: Notificación marcada como mostrada para desafío $challengeId del usuario $userId ===');
    } catch (e) {
      print('ERROR: Error marcando notificación como mostrada: $e');
    }
  }

  /// Mostrar notificación cuando se completa un desafío SOLO UNA VEZ
  Future<void> _showChallengeCompletedNotificationOnce(Challenge challenge, int pointsAwarded) async {
    print('=== DEBUG: _showChallengeCompletedNotificationOnce() - Verificando si mostrar notificación para: ${challenge.title} ===');
    
    try {
      // Obtener el ID del usuario actual
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId == null) {
        print('=== DEBUG: No se pudo obtener el UID del usuario, no se mostrará notificación ===');
        return;
      }
      
      // Verificar si ya se mostró esta notificación
      final alreadyShown = await _wasNotificationAlreadyShown(challenge.id, currentUserId);
      
      if (alreadyShown) {
        print('=== DEBUG: Notificación para desafío ${challenge.title} ya fue mostrada antes, omitiendo ===');
        return;
      }
      
      print('=== DEBUG: Mostrando notificación por primera vez para desafío: ${challenge.title} ===');
      
      // Mostrar la notificación
      _showChallengeCompletedNotification(challenge, pointsAwarded);
      
      // Marcar como mostrada
      await _markNotificationAsShown(challenge.id, currentUserId);
      
    } catch (e) {
      print('=== ERROR: Error en _showChallengeCompletedNotificationOnce: $e ===');
      // En caso de error, mostrar la notificación por seguridad (mejor mostrar de más que de menos)
      _showChallengeCompletedNotification(challenge, pointsAwarded);
    }
  }

  /// Mostrar notificación cuando se completa un desafío (método original)
  void _showChallengeCompletedNotification(Challenge challenge, int pointsAwarded) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¡Desafío completado!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${challenge.title} - +$pointsAwarded B-points',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.stars,
              color: Colors.amber,
              size: 24,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Opcional: Scroll hasta el desafío completado
            _loadChallenges(); // Recargar para mostrar el estado actualizado
          },
        ),
      ),
    );
  }
  Future<void> _loadChallenges() async {
    print('=== DEBUG: ChallengesPanel._loadChallenges() - INICIANDO ===');
    
    if (_challengeService == null) {
      print('=== ERROR: ChallengesPanel - _challengeService es null, saliendo ===');
      return;
    }
    
    try {
      print('=== DEBUG: ChallengesPanel - Llamando a _challengeService.getChallenges() ===');
      final challenges = await _challengeService!.getChallenges();
      if (mounted) {
        setState(() {
          _challenges = challenges;
          _isLoading = false;
        });
        
        // Debug de los desafíos cargados
        print('=== DEBUG: ChallengesPanel - Desafíos cargados: ${challenges.length} ===');
        for (final challenge in challenges) {
          print('=== DEBUG: Desafío: ${challenge.title} - Progreso: ${challenge.currentProgress}/${challenge.target} - Completado: ${challenge.isCompleted} ===');
        }
      }
    } catch (e) {
      print('=== ERROR: ChallengesPanel - Error cargando desafíos: $e ===');
      if (mounted) {
        setState(() {
          _challenges = [];
          _isLoading = false;
        });
      }
    }
  }

  /// Método público para recargar los desafíos desde fuera del widget
  Future<void> refreshChallenges() async {
    print('DEBUG: ChallengesPanel - Refrescando desafíos...');
    await _loadChallenges();
  }
  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    // Colores usando el tema de Material Design
    final backgroundColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final accentColor = theme.colorScheme.primary;

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
                    ),                    boxShadow: [
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
                      ),                      // Header con título y botón de cerrar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
                      ),                      // Lista de desafíos
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: accentColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cargando desafíos...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _challenges.isEmpty
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
                                  )                                : ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: _challenges.length + 1, // +1 para el control de tracking
                                    itemBuilder: (context, index) {
                                      // Mostrar el control de tracking de distancia como el primer elemento
                                      if (index == 0) {
                                        return const DistanceTrackingControl();
                                      }
                                      
                                      // Mostrar los desafíos (ajustando el índice)
                                      final challenge = _challenges[index - 1];
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