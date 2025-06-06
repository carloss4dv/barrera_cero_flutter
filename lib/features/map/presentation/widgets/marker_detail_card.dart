import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../accessibility/domain/accessibility_report_model.dart';
import '../../../accessibility/presentation/widgets/accessibility_comments_list.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../domain/marker_model.dart';
import '../../../accessibility/domain/community_validation_model.dart';
import '../../../accessibility/domain/i_community_validation_service.dart';
import '../../../accessibility/infrastructure/services/community_validation_service.dart';
import '../../application/marker_cubit.dart';
import '../../../auth/service/auth_service.dart';
import '../../../users/presentation/widgets/b_points_widget.dart';
import '../../../users/domain/models/badge_system.dart';
import '../../../users/presentation/widgets/badges_widget.dart';
import '../../../users/services/user_service.dart';
import '../../../challenges/domain/challenge_model.dart';
import '../../../challenges/infrastructure/services/mock_challenge_service.dart';
import '../../../challenges/infrastructure/services/report_challenge_service.dart';
import '../../../../services/local_user_storage_service.dart';

class MarkerDetailCard extends StatefulWidget {
  final MarkerModel marker;
  final VoidCallback? onClose;
  final VoidCallback? onGetDirections;

  const MarkerDetailCard({
    Key? key,
    required this.marker,
    this.onClose,
    this.onGetDirections,
  }) : super(key: key);

  @override
  State<MarkerDetailCard> createState() => _MarkerDetailCardState();
}

class _MarkerDetailCardState extends State<MarkerDetailCard> {
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  bool _isExpanded = false;
  bool _isLoading = true;
  List<AccessibilityReportModel>? _reports;
  List<CommunityValidationModel>? _validations;
  String? _errorMessage;
  late IAccessibilityReportService _reportService;
  late ICommunityValidationService _validationService;
  MockChallengeService? _challengeService;
  
  // Para mostrar animación de B-points
  OverlayEntry? _overlayEntry;
    @override
  void initState() {
    super.initState();    _reportService = GetIt.instance<IAccessibilityReportService>();
    _validationService = GetIt.instance<ICommunityValidationService>();
    
    // Inicializar el servicio de desafíos usando GetIt
    _challengeService = GetIt.instance<MockChallengeService>();
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    await Future.wait([
      _loadReports(),
      _loadValidations(),
    ]);
    
    setState(() {
      _isLoading = false;
    });
  }
    Future<void> _loadReports() async {
    print('Cargando reportes para marcador: ${widget.marker.id}');
    final result = await _reportService.getReportsForMarker(widget.marker.id);
    
    result.fold(
      (reports) {
        print('Reportes cargados: ${reports.length}');
        for (var report in reports) {
          print('Reporte ${report.id}: ${report.comments} (${report.level})');
        }
        setState(() {
          _reports = reports;
        });
      },
      (error) {
        print('Error cargando reportes: ${error.message}');
        setState(() {
          _errorMessage = error.message;
        });
      },
    );
  }
  Future<void> _loadValidations() async {
    try {
      print('Loading validations for marker: ${widget.marker.id}');
      final result = await _validationService.getValidationsForMarker(widget.marker.id);
      result.fold(
        (validations) {
          print('Loaded ${validations.length} validations successfully');
          setState(() {
            _validations = validations;
          });
        },
        (error) {
          print('Error loading validations: $error');
          setState(() {
            _validations = [];
          });
        },
      );
      
      // En modo debug, limpiar validaciones obsoletas una sola vez
      if (kDebugMode && _validations?.isEmpty == true) {
        print('Running obsolete validations cleanup...');
        if (_validationService is CommunityValidationService) {
          await (_validationService as CommunityValidationService).cleanObsoleteValidations();
          // Recargar después de la limpieza
          final reloadResult = await _validationService.getValidationsForMarker(widget.marker.id);
          reloadResult.fold(
            (validations) {
              setState(() {
                _validations = validations;
              });
            },
            (error) {
              print('Error reloading validations after cleanup: $error');
            },
          );
        }
      }
    } catch (e) {
      print('Exception in _loadValidations: $e');
      setState(() {
        _validations = [];
      });
    }
  }  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
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

  /// Mostrar diálogo de desafío completado SOLO UNA VEZ
  Future<void> _showChallengeCompletedDialogOnce(Challenge challenge) async {
    print('=== DEBUG: _showChallengeCompletedDialogOnce() - Verificando si mostrar diálogo para: ${challenge.title} ===');
    
    try {
      // Obtener el ID del usuario actual
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId == null) {
        print('=== DEBUG: No se pudo obtener el UID del usuario, no se mostrará diálogo ===');
        return;
      }
      
      // Verificar si ya se mostró esta notificación
      final alreadyShown = await _wasNotificationAlreadyShown(challenge.id, currentUserId);
      
      if (alreadyShown) {
        print('=== DEBUG: Diálogo para desafío ${challenge.title} ya fue mostrado antes, omitiendo ===');
        return;
      }
      
      print('=== DEBUG: Mostrando diálogo por primera vez para desafío: ${challenge.title} ===');
      
      // Mostrar el diálogo
      _showChallengeCompletedDialog(challenge);
      
      // Marcar como mostrado
      await _markNotificationAsShown(challenge.id, currentUserId);
      
    } catch (e) {
      print('=== ERROR: Error en _showChallengeCompletedDialogOnce: $e ===');
      // En caso de error, mostrar el diálogo por seguridad (mejor mostrar de más que de menos)
      _showChallengeCompletedDialog(challenge);
    }
  }  /// Verifica si algún desafío ha sido completado y otorga puntos B-points
  /// Si [justCreatedReport] es true, indica que se acaba de crear un nuevo reporte
  Future<void> _checkAndAwardChallenges({bool justCreatedReport = false}) async {
    if (_challengeService == null) return;
    
    try {
      final completedChallenges = await _challengeService!.checkAndAwardCompletedChallenges(justCreatedReport: justCreatedReport);
      
      if (completedChallenges.isNotEmpty) {
        for (final challenge in completedChallenges) {
          // Mostrar notificación de desafío completado SOLO UNA VEZ
          await _showChallengeCompletedDialogOnce(challenge);
        }
      }
    } catch (e) {
      print('Error verificando desafíos: $e');
    }
  }

  /// Muestra un diálogo cuando se completa un desafío
  void _showChallengeCompletedDialog(Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('¡Desafío Completado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              challenge.icon,
              color: Colors.blue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              challenge.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¡Has ganado ${challenge.points} B-Points!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('¡Genial!'),
          ),
        ],
      ),
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _scrollController.animateTo(
        0.9,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.animateTo(
        0.3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }  }
  
  void _showBPointsAnimation() {
    if (!mounted) return;
    
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: MediaQuery.of(context).size.width * 0.2,
        right: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: BPointsEarnedAnimation(
            pointsEarned: 20,
            onAnimationComplete: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
          ),
        ),
      ),
    );
      Overlay.of(context).insert(_overlayEntry!);
  }

  void _showBadgeUnlockedAnimation(BadgeInfo badge) {
    if (!mounted) return;
    
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.2,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: BadgeUnlockedAnimation(
            badge: badge,
            onAnimationComplete: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);
    
    // Colores adaptados para alto contraste
    final cardColor = isHighContrastMode ? theme.colorScheme.surface : Colors.white;    final textColor = isHighContrastMode ? theme.colorScheme.onSurface : Colors.black87;
    final accentColor = isHighContrastMode ? theme.colorScheme.primary : Colors.blue;
    // La variable dividerColor no se está usando, la eliminamos
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        controller: _scrollController,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                setState(() {
                  _isExpanded = notification.extent > 0.5;
                });
                return true;
              },
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [                  // Indicador de arrastre
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                    // Sección superior con icono y nombre
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isHighContrastMode ? accentColor : _getIconBackgroundColor(),
                      child: Icon(
                        Icons.accessible,
                        color: isHighContrastMode ? Colors.black : Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      widget.marker.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      widget.marker.description.isNotEmpty
                          ? widget.marker.description
                          : 'Centro de accesibilidad',
                      style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share, color: textColor),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de "Cómo llegar"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<MarkerCubit>().getRouteToDestination(widget.marker);
                      },
                      icon: Icon(
                        Icons.directions,
                        color: isHighContrastMode ? Colors.black : Colors.white,
                      ),
                      label: Text(
                        'Cómo llegar',
                        style: TextStyle(
                          color: isHighContrastMode ? Colors.black : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHighContrastMode 
                            ? AccessibilityProvider.kAccentColor 
                            : Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                    // Sección de valoración
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          'Reporte de accesibilidad',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Comparte tu experiencia sobre la accesibilidad de este lugar',
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                          // Verificar si el usuario está autenticado
                        Builder(builder: (context) {
                          final authService = GetIt.instance<AuthService>();
                          final bool isAuthenticated = authService.currentUser != null;
                          
                          if (isAuthenticated) {
                            // Mostrar botones de reporte si está autenticado con información del reporte existente
                            return FutureBuilder<AccessibilityReportModel?>(
                              future: _getUserExistingReport(),
                              builder: (context, snapshot) {
                                final existingReport = snapshot.data;
                                
                                return Column(
                                  children: [
                                    // Mostrar indicador si ya existe un reporte
                                    if (existingReport != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '✓ Ya tienes un reporte aquí',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                  Text(
                                                    'Nivel: ${_getLevelText(existingReport.level)} • Toca para editar',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Botones de feedback
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildFeedbackButton(
                                          color: isHighContrastMode ? theme.colorScheme.secondary : Colors.green,
                                          icon: Icons.sentiment_very_satisfied,
                                          level: AccessibilityLevel.good,
                                          highContrastMode: isHighContrastMode,
                                          existingReport: existingReport,
                                        ),
                                        _buildFeedbackButton(
                                          color: isHighContrastMode ? theme.colorScheme.secondary : Colors.amber,
                                          icon: Icons.sentiment_neutral,
                                          level: AccessibilityLevel.medium,
                                          highContrastMode: isHighContrastMode,
                                          existingReport: existingReport,
                                        ),
                                        _buildFeedbackButton(
                                          color: isHighContrastMode ? theme.colorScheme.error : Colors.red,
                                          icon: Icons.sentiment_very_dissatisfied,
                                          level: AccessibilityLevel.bad,
                                          highContrastMode: isHighContrastMode,
                                          existingReport: existingReport,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Mostrar mensaje de inicio de sesión si no está autenticado
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: Column(
                                  children: [                                    Icon(
                                      Icons.lock_outline,
                                      color: textColor.withOpacity(0.6),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Debes iniciar sesión para añadir reportes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: textColor.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/login');
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.login, color: accentColor, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Iniciar sesión',
                                            style: TextStyle(
                                              color: accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                  ),                  // Sección de validación comunitaria
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Validación comunitaria',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Icon(
                              Icons.accessibility_new,
                              color: isHighContrastMode 
                                  ? AccessibilityProvider.kAccentColor 
                                  : Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Mostrar todas las preguntas de existencia de elementos
                        ...ValidationQuestionType.values.map((questionType) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildValidationQuestion(
                            question: questionType.getQuestionText(),
                            questionType: questionType,
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  // Indicador para ver más comentarios (solo visible si no está expandido)
                  if (!_isExpanded)
                    GestureDetector(
                      onTap: _toggleExpand,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ver comentarios de accesibilidad',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Sección de comentarios (visible cuando está expandido)
                  if (_isExpanded) const Divider(),
                  if (_isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Comentarios de accesibilidad',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggleExpand,
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AccessibilityCommentsList(
                            reports: _reports ?? [],
                            isLoading: _isLoading,
                            errorMessage: _errorMessage,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );  }  // Método eliminado ya que no se estaba utilizando

  Future<AccessibilityReportModel?> _getUserExistingReport() async {
    final authService = GetIt.instance<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) return null;
    
    try {
      final result = await _reportService.getUserReportForMarker(widget.marker.id, currentUser.uid);
      if (result.isSuccess()) {
        final reports = result.getOrNull()!;
        return reports.isNotEmpty ? reports.first : null;
      }
    } catch (e) {
      print('Error obteniendo reporte del usuario: $e');
    }
    
    return null;
  }

  Widget _buildFeedbackButton({
    required Color color,
    required IconData icon,
    required AccessibilityLevel level,
    bool highContrastMode = false,    AccessibilityReportModel? existingReport,
  }) {
    final iconColor = highContrastMode ? Colors.black : Colors.white;
    final isSelectedLevel = existingReport?.level == level;
    final hasExistingReport = existingReport != null;
    
    return Semantics(
      button: true,
      label: hasExistingReport 
          ? (isSelectedLevel ? 'Editar tu reporte de ${level.toString().split('.').last}' : 'Cambiar a ${level.toString().split('.').last}')
          : 'Reportar como ${level.toString().split('.').last}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReportDialog(level),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: isSelectedLevel && hasExistingReport 
                          ? color 
                          : hasExistingReport 
                              ? color.withOpacity(0.3)
                              : color,
                      radius: 20,
                      child: Icon(
                        icon, 
                        color: isSelectedLevel && hasExistingReport 
                            ? iconColor 
                            : hasExistingReport 
                                ? iconColor.withOpacity(0.6)
                                : iconColor,
                      ),
                    ),
                    if (isSelectedLevel && hasExistingReport)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getLevelText(level),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelectedLevel && hasExistingReport 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    color: isSelectedLevel && hasExistingReport 
                        ? Colors.blue 
                        : hasExistingReport 
                            ? Colors.grey 
                            : null,
                  ),
                ),
                if (isSelectedLevel && hasExistingReport)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'TU REPORTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }  Future<void> _showReportDialog(AccessibilityLevel level) async {
    final authService = GetIt.instance<AuthService>();
    
    // Verificar si el usuario está autenticado
    if (authService.currentUser == null) {
      // Mostrar diálogo de autenticación requerida
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Inicio de sesión requerido',
            style: TextStyle(color: Colors.blue),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Debes iniciar sesión para poder añadir reportes de accesibilidad.'),
              SizedBox(height: 10),
              Text(
                'Los reportes de la comunidad nos ayudan a mejorar la información de accesibilidad para todos.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
      return;
    }

    final currentUser = authService.currentUser!;
    
    // Verificar si el usuario ya tiene un reporte para este marcador
    final existingReportsResult = await _reportService.getUserReportForMarker(widget.marker.id, currentUser.uid);
    
    AccessibilityReportModel? existingReport;
    if (existingReportsResult.isSuccess()) {
      final reports = existingReportsResult.getOrNull()!;
      if (reports.isNotEmpty) {
        existingReport = reports.first;
      }
    }
    
    final TextEditingController commentController = TextEditingController();
    AccessibilityLevel selectedLevel = level;
    
    // Si hay un reporte existente, prellenar los campos
    if (existingReport != null) {
      commentController.text = existingReport.comments;
      selectedLevel = existingReport.level;
    }
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existingReport != null 
                ? 'Editar reporte de ${_getLevelText(selectedLevel)}'
                : 'Nuevo reporte de ${_getLevelText(selectedLevel)}',
            style: TextStyle(color: _getLevelColor(selectedLevel)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (existingReport != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ya tienes un reporte para este lugar. Puedes modificar el texto y nivel de accesibilidad.',
                          style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              // Selector de nivel de accesibilidad
              Text(
                'Nivel de accesibilidad:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLevelSelector(
                    level: AccessibilityLevel.good,
                    selectedLevel: selectedLevel,
                    onTap: () => setDialogState(() => selectedLevel = AccessibilityLevel.good),
                  ),
                  _buildLevelSelector(
                    level: AccessibilityLevel.medium,
                    selectedLevel: selectedLevel,
                    onTap: () => setDialogState(() => selectedLevel = AccessibilityLevel.medium),
                  ),
                  _buildLevelSelector(
                    level: AccessibilityLevel.bad,
                    selectedLevel: selectedLevel,
                    onTap: () => setDialogState(() => selectedLevel = AccessibilityLevel.bad),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: 'Describa la accesibilidad de este lugar',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  if (existingReport != null) {
                    _updateReport(existingReport, selectedLevel, commentController.text);
                  } else {
                    _submitReport(selectedLevel, commentController.text);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(existingReport != null ? 'Actualizar' : 'Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector({
    required AccessibilityLevel level,
    required AccessibilityLevel selectedLevel,
    required VoidCallback onTap,
  }) {
    final isSelected = level == selectedLevel;
    final color = _getLevelColor(level);
    final icon = _getLevelIcon(level);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              _getLevelText(level),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLevelIcon(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return Icons.sentiment_very_satisfied;
      case AccessibilityLevel.medium:
        return Icons.sentiment_neutral;
      case AccessibilityLevel.bad:
        return Icons.sentiment_very_dissatisfied;
    }
  }Future<void> _submitReport(AccessibilityLevel level, String comment) async {
    final authService = GetIt.instance<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para enviar reportes')),
      );
      return;
    }
    
    // Obtener el nombre del usuario de las shared preferences
    String userName = 'Usuario'; // Valor por defecto
    try {
      final localUserStorage = LocalUserStorageService();
      final retrievedUserName = await localUserStorage.getUserName();
      if (retrievedUserName != null && retrievedUserName.isNotEmpty) {
        userName = retrievedUserName;
      } else {
        // Si no hay nombre en localStorage, usar el displayName de Firebase o email
        userName = currentUser.displayName ?? 
                  currentUser.email?.split('@').first ?? 
                  'Usuario';
      }
    } catch (e) {
      print('Error obteniendo nombre de usuario: $e');
      // Usar fallback de Firebase
      userName = currentUser.displayName ?? 
                currentUser.email?.split('@').first ?? 
                'Usuario';
    }
    
    final report = AccessibilityReportModel(
      id: '', // Se generará en el servicio
      userId: currentUser.uid, // Usar el ID real del usuario autenticado
      userName: userName, // Usar el nombre obtenido de shared preferences
      comments: comment,
      level: level,
    );
      final result = await _reportService.addReport(widget.marker.id, report);
      result.fold(      (success) async {
        // Actualizar cache de conteo de reportes de forma inteligente
        await ReportChallengeService.smartUpdateCacheForCurrentUser();
        
        // Recargar los reportes
        _loadReports();
          // Verificar y otorgar desafíos completados (indica que se creó un nuevo reporte)
        await _checkAndAwardChallenges(justCreatedReport: true);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      },(error) {
        // Verificar si el error es porque ya existe un reporte
        if (error.message.contains('ya tiene un reporte')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ya tienes un reporte para este lugar. Si quieres cambiarlo, selecciona el botón correspondiente para editarlo.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // Mostrar otros errores
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar reporte: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );  }
  Future<void> _updateReport(AccessibilityReportModel existingReport, AccessibilityLevel level, String comment) async {
    final authService = GetIt.instance<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para actualizar reportes')),
      );
      return;
    }
    
    print('Actualizando reporte: ${existingReport.id}');
    print('Nuevo comentario: $comment');
    print('Nuevo nivel: $level');
    
    // Obtener el nombre del usuario de las shared preferences
    String userName = existingReport.userName; // Mantener el nombre original por defecto
    try {
      final localUserStorage = LocalUserStorageService();
      final retrievedUserName = await localUserStorage.getUserName();
      if (retrievedUserName != null && retrievedUserName.isNotEmpty) {
        userName = retrievedUserName;
      }
    } catch (e) {
      print('Error obteniendo nombre de usuario: $e');
      // Mantener el nombre original del reporte
    }
    
    final updatedReport = AccessibilityReportModel(
      id: existingReport.id, // Mantener el mismo ID
      userId: existingReport.userId, // Mantener el mismo userId
      userName: userName, // Actualizar el nombre si es necesario
      comments: comment,
      level: level,
    );
    
    print('Enviando actualización con ID: ${updatedReport.id}');
      final result = await _reportService.updateReport(widget.marker.id, updatedReport);
      result.fold(      (success) async {
        print('Reporte actualizado exitosamente');
        
        // Para actualizaciones no necesitamos cambiar el cache ya que no cambia el conteo
        // Pero limpiamos el cache para asegurar consistencia de datos
        await ReportChallengeService.clearCacheForCurrentUser();
        
        // Recargar los reportes
        _loadReports();
          // Verificar y otorgar desafíos completados (por si había cambios en el progreso)
        await _checkAndAwardChallenges(justCreatedReport: false);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      },
      (error) {
        print('Error al actualizar reporte: ${error.message}');
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar reporte: ${error.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Color _getLevelColor(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return Colors.green;
      case AccessibilityLevel.medium:
        return Colors.amber;
      case AccessibilityLevel.bad:
        return Colors.red;
    }
  }
  
  /// Obtiene el color de fondo para el ícono del lugar
  /// Devuelve gris si no hay reportes, o el color del nivel predominante si los hay
  Color _getIconBackgroundColor() {
    if (_reports == null || _reports!.isEmpty) {
      // Sin reportes - mostrar gris desaturado
      return Colors.grey.shade400;
    }
    
    // Con reportes - mostrar color del nivel predominante
    return _getLevelColor(_getPredominantLevel());
  }
  
  String _getLevelText(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return 'Buena';
      case AccessibilityLevel.medium:
        return 'Regular';
      case AccessibilityLevel.bad:
        return 'Mala';
    }
  }

  AccessibilityLevel _getPredominantLevel() {
    if (_reports == null || _reports!.isEmpty) {
      return AccessibilityLevel.medium;
    }

    // Calcular la media de las puntuaciones
    double totalScore = 0;
    for (final report in _reports!) {
      switch (report.level) {        
        case AccessibilityLevel.good:
          totalScore += 5; // Reporte positivo vale 5
          break;
        case AccessibilityLevel.medium:
          totalScore += 3; // Reporte neutro vale 3
          break;
        case AccessibilityLevel.bad:
          totalScore += 1; // Reporte negativo vale 1
          break;  
      }
    }
    
    final averageScore = totalScore / _reports!.length;

    // Determinar el nivel predominante según la media
    if (averageScore >= 4.0) {
      return AccessibilityLevel.good; // 4.0 - 5.0: bueno
    } else if (averageScore >= 2.0) {
      return AccessibilityLevel.medium; // 2.0 - 3.99: medio
    } else {
      return AccessibilityLevel.bad; // < 2.0: malo
    }
  }

  Widget _buildVoteButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildValidationQuestion({
    required String question,
    required ValidationQuestionType questionType,
  }) {
    final validation = _validations?.firstWhere(
      (v) => v.questionType == questionType,
      orElse: () => CommunityValidationModel(
        id: 'temp_${questionType.toString()}',
        markerId: widget.marker.id,
        questionType: questionType,
        positiveVotes: 0,
        negativeVotes: 0,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: [],
      ),
    );

    final theme = Theme.of(context);
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final textColor = isHighContrastMode ? theme.colorScheme.onSurface : Colors.black87;
    final authService = GetIt.instance<AuthService>();
    final bool isAuthenticated = authService.currentUser != null;
      // Verificar si esta validación realmente existe
    final validationExists = _validations?.any((v) => v.questionType == questionType) ?? false;
    
    // Verificar si el usuario ya ha votado
    final currentUserId = authService.currentUser?.uid;
    final hasUserVoted = validationExists && 
        currentUserId != null && 
        validation!.votedUserIds.contains(currentUserId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        // Mostrar botones de voto solo si el usuario está autenticado
        if (isAuthenticated)
          hasUserVoted
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ya has votado en esta pregunta',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVoteButton(
                      icon: Icons.check_circle,
                      label: 'Sí',
                      color: Colors.green,
                      onTap: () => _handleVote(questionType, true),
                    ),
                    _buildVoteButton(
                      icon: Icons.cancel,
                      label: 'No',
                      color: Colors.red,
                      onTap: () => _handleVote(questionType, false),
                    ),
                  ],
                )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: textColor.withOpacity(0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Debes iniciar sesión para votar',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 8,
            child: Stack(
              children: [
                // Fondo gris para toda la barra
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                // Barra de diferencia positiva (verde) o negativa (roja)
                Builder(
                  builder: (context) {
                    final positiveVotes = validationExists ? (validation?.positiveVotes ?? 0) : 0;
                    final negativeVotes = validationExists ? (validation?.negativeVotes ?? 0) : 0;
                    final voteDifference = positiveVotes - negativeVotes;
                    final totalNeeded = validation?.totalVotesNeeded ?? 10;
                    
                    // Calculamos un factor de proporción
                    double progress = voteDifference.abs() / totalNeeded;
                    // Limitamos el progreso a un máximo de 1.0 (100%)
                    progress = progress.clamp(0.0, 1.0);
                    
                    return FractionallySizedBox(
                      alignment: voteDifference >= 0 ? Alignment.centerLeft : Alignment.centerRight,
                      widthFactor: progress,
                      child: Container(
                        color: voteDifference >= 0 ? Colors.green : Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Positivos: ${validation?.positiveVotes ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Diferencia: ${(validation?.positiveVotes ?? 0) - (validation?.negativeVotes ?? 0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (validation?.positiveVotes ?? 0) >= (validation?.negativeVotes ?? 0) ? 
                      Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Negativos: ${validation?.negativeVotes ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Se necesitan 10 votos de diferencia para validar',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }  Future<void> _handleVote(ValidationQuestionType questionType, bool isPositive) async {
    try {
      // Obtener el usuario actual del servicio de autenticación
      final authService = GetIt.instance<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes iniciar sesión para votar')),
          );
        }
        return;
      }      // Verificar si la validación existe, si no, crearla
      final validationExists = _validations?.any((v) => v.questionType == questionType) ?? false;
      print('Validation exists for ${questionType}: $validationExists');
      
      if (!validationExists) {
        print('Creating new validation for ${questionType}');
        // Crear la validación primero
        final createResult = await _validationService.createValidation(widget.marker.id, questionType);
        createResult.fold(
          (newValidation) {
            print('Successfully created validation: ${newValidation.id}');
            setState(() {
              _validations = [...(_validations ?? []), newValidation];
            });
          },
          (error) {
            // Manejar error silenciosamente - no mostrar al usuario
            print('Error creating validation: $error');
            return;
          },
        );
      }

      // Obtener puntos actuales del usuario antes de votar
      final userService = UserService();
      final userBefore = await userService.getUserById(currentUser.uid);
      final oldPoints = userBefore?.contributionPoints ?? 0;

      final result = await _validationService.addVote(
        widget.marker.id,
        questionType,
        isPositive,
        currentUser.uid, // Usar ID real del usuario
      );

      result.fold(
        (success) async {
          setState(() {
            _validations = _validations?.map((v) => 
              v.questionType == questionType ? success : v
            ).toList() ?? [success];
          });
          
          // Verificar si se desbloqueó una nueva insignia
          final userAfter = await userService.getUserById(currentUser.uid);
          final newPoints = userAfter?.contributionPoints ?? 0;
          final newBadge = BadgeSystem.checkNewBadgeUnlocked(oldPoints, newPoints);
          
          // Mostrar animación de B-points
          _showBPointsAnimation();
          
          // Si hay una nueva insignia, mostrar su animación después de los B-points
          if (newBadge != null) {
            // Esperar un poco para que termine la animación de B-points
            Future.delayed(const Duration(milliseconds: 1500), () {
              _showBadgeUnlockedAnimation(newBadge);
            });
          }
          
          // Mostrar mensaje de éxito con información de puntos
          if (mounted) {
            final message = newBadge != null 
                ? '¡Voto registrado! Has ganado 20 B-points y desbloqueado la insignia ${newBadge.name}!'
                : '¡Voto registrado! Has ganado 20 B-points';
                
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: Duration(seconds: newBadge != null ? 5 : 3),
              ),
            );
          }        },
        (failure) {
          // Verificar si el error es porque ya ha votado
          if (failure.toString().contains('Ya has votado')) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ya has votado en esta pregunta'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            // Para otros errores, mantener el comportamiento silencioso
            print('Vote failed: $failure');
          }
        },
      );
    } catch (e) {
      // Manejar excepción silenciosamente - no mostrar al usuario
      print('Exception in _handleVote: $e');
    }
  }
}