import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../../../features/accessibility/domain/accessibility_report_model.dart';
import '../../../../features/accessibility/presentation/widgets/accessibility_comments_list.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../domain/marker_model.dart';
import '../../../accessibility/domain/community_validation_model.dart';
import '../../../accessibility/domain/i_community_validation_service.dart';
import 'package:result_dart/result_dart.dart';
import '../../application/marker_cubit.dart';

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
  
  @override
  void initState() {
    super.initState();
    _reportService = GetIt.instance<IAccessibilityReportService>();
    _validationService = GetIt.instance<ICommunityValidationService>();
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
    final result = await _reportService.getReportsForMarker(widget.marker.id);
    
    result.fold(
      (reports) {
        setState(() {
          _reports = reports;
        });
      },
      (error) {
        setState(() {
          _errorMessage = error.message;
        });
      },
    );
  }
  
  Future<void> _loadValidations() async {
    try {
      final result = await _validationService.getValidationsForMarker(widget.marker.id);
      result.fold(
        (validations) {
          setState(() {
            _validations = validations;
          });
        },
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString())),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    final theme = Theme.of(context);
    
    // Colores adaptados para alto contraste
    final cardColor = isHighContrastMode ? theme.colorScheme.surface : Colors.white;
    final textColor = isHighContrastMode ? theme.colorScheme.onSurface : Colors.black87;
    final accentColor = isHighContrastMode ? theme.colorScheme.primary : Colors.blue;
    final dividerColor = isHighContrastMode ? theme.colorScheme.onSurface.withOpacity(0.5) : Colors.grey[300];
    
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
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _getLevelColor(_getPredominantLevel()),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                  
                  // Sección superior con icono y nombre
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isHighContrastMode ? accentColor : _getLevelColor(_getPredominantLevel()),
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
                      children: [
                        Text(
                          'Escriba su reporte',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeedbackButton(
                              color: isHighContrastMode ? theme.colorScheme.secondary : Colors.green,
                              icon: Icons.sentiment_very_satisfied,
                              level: AccessibilityLevel.good,
                              highContrastMode: isHighContrastMode,
                            ),
                            _buildFeedbackButton(
                              color: isHighContrastMode ? theme.colorScheme.secondary : Colors.amber,
                              icon: Icons.sentiment_neutral,
                              level: AccessibilityLevel.medium,
                              highContrastMode: isHighContrastMode,
                            ),
                            _buildFeedbackButton(
                              color: isHighContrastMode ? theme.colorScheme.error : Colors.red,
                              icon: Icons.sentiment_very_dissatisfied,
                              level: AccessibilityLevel.bad,
                              highContrastMode: isHighContrastMode,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sección de validación comunitaria
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildValidationQuestion(
                          question: '¿Existe una rampa en este lugar?',
                          questionType: ValidationQuestionType.rampExists,
                        ),
                        const SizedBox(height: 12),
                        _buildValidationQuestion(
                          question: '¿En qué estado se encuentra la rampa?',
                          questionType: ValidationQuestionType.rampCondition,
                        ),
                        const SizedBox(height: 12),
                        _buildValidationQuestion(
                          question: '¿La rampa tiene el ancho adecuado?',
                          questionType: ValidationQuestionType.rampWidth,
                        ),
                        const SizedBox(height: 12),
                        _buildValidationQuestion(
                          question: '¿La pendiente de la rampa es adecuada?',
                          questionType: ValidationQuestionType.rampSlope,
                        ),
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
    );
  }

  Color _getMarkerColor() {
    switch (widget.marker.type) {
      case MarkerType.pointOfInterest:
        return Colors.orange;
      case MarkerType.destination:
        return Colors.amber;
      case MarkerType.currentLocation:
        return Colors.red;
      default:
        return widget.marker.color;
    }
  }

  Widget _buildFeedbackButton({
    required Color color,
    required IconData icon,
    required AccessibilityLevel level,
    bool highContrastMode = false,
  }) {
    final iconColor = highContrastMode ? Colors.black : Colors.white;
    
    return Semantics(
      button: true,
      label: 'Reportar como ${level.toString().split('.').last}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReportDialog(level),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _getLevelText(level),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReportDialog(AccessibilityLevel level) async {
    final TextEditingController commentController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Nuevo reporte de ${_getLevelText(level)}',
          style: TextStyle(color: _getLevelColor(level)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                _submitReport(level, commentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitReport(AccessibilityLevel level, String comment) async {
    final report = AccessibilityReportModel(
      id: '', // Se generará en el servicio
      userId: 'current_user', // En producción, obtendríamos el ID del usuario actual
      comments: comment,
      level: level,
    );
    
    final result = await _reportService.addReport(widget.marker.id, report);
    
    result.fold(
      (success) {
        // Recargar los reportes
        _loadReports();
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      },
      (error) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar reporte: ${error.message}'),
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
    
    final countByLevel = <AccessibilityLevel, int>{
      AccessibilityLevel.good: 0,
      AccessibilityLevel.medium: 0,
      AccessibilityLevel.bad: 0,
    };
    
    for (final report in _reports!) {
      countByLevel[report.level] = (countByLevel[report.level] ?? 0) + 1;
    }
    
    AccessibilityLevel predominantLevel = AccessibilityLevel.medium;
    int maxCount = 0;
    
    countByLevel.forEach((level, count) {
      if (count > maxCount) {
        maxCount = count;
        predominantLevel = level;
      }
    });
    
    return predominantLevel;
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
  }

  Widget _buildValidationQuestion({
    required String question,
    required ValidationQuestionType questionType,
  }) {
    final validation = _validations?.firstWhere(
      (v) => v.questionType == questionType,
      orElse: () => CommunityValidationModel(
        id: questionType.toString(),
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
        Row(
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
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: validation?.getProgress() ?? 0,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            (validation?.getProgress() ?? 0) >= 0.7 ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${validation?.positiveVotes ?? 0} de ${validation?.totalVotesNeeded ?? 10} votos necesarios para verificación',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _handleVote(ValidationQuestionType questionType, bool isPositive) async {
    try {
      final result = await _validationService.addVote(
        widget.marker.id,
        questionType,
        isPositive,
        'current_user_id', // TODO: Reemplazar con ID de usuario real
      );

      result.fold(
        (success) {
          setState(() {
            _validations = _validations?.map((v) => 
              v.questionType == questionType ? success : v
            ).toList() ?? [success];
          });
        },
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.toString())),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
} 