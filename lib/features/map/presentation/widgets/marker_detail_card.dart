import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../features/accessibility/domain/accessibility_report_model.dart';
import '../../../../features/accessibility/presentation/widgets/accessibility_comments_list.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../domain/marker_model.dart';

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
  String? _errorMessage;
  late IAccessibilityReportService _reportService;
  
  @override
  void initState() {
    super.initState();
    _reportService = GetIt.instance<IAccessibilityReportService>();
    _loadReports();
  }
  
  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final result = await _reportService.getReportsForMarker(widget.marker.id);
    
    result.fold(
      (reports) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      },
      (error) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      },
    );
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
              color: Colors.white,
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                  
                  // Sección superior con icono y nombre
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMarkerColor(),
                      child: const Icon(
                        Icons.accessible,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      widget.marker.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      widget.marker.description.isNotEmpty
                          ? widget.marker.description
                          : 'Centro de accesibilidad',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón para cómo llegar
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text('Cómo llegar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: widget.onGetDirections,
                      ),
                    ),
                  ),
                  
                  // Sección de valoración
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escriba su reporte',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeedbackButton(
                              color: Colors.green,
                              icon: Icons.sentiment_very_satisfied,
                              level: AccessibilityLevel.good,
                            ),
                            _buildFeedbackButton(
                              color: Colors.amber,
                              icon: Icons.sentiment_neutral,
                              level: AccessibilityLevel.medium,
                            ),
                            _buildFeedbackButton(
                              color: Colors.red,
                              icon: Icons.sentiment_very_dissatisfied,
                              level: AccessibilityLevel.bad,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicador para ver más comentarios (solo visible si no está expandido)
                  if (!_isExpanded)
                    GestureDetector(
                      onTap: _toggleExpand,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ver comentarios de accesibilidad',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.blue,
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

  Widget _buildFeedbackButton({
    required Color color,
    required IconData icon,
    required AccessibilityLevel level,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
        onPressed: () => _showReportDialog(level),
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

  Color _getMarkerColor() {
    switch (widget.marker.type) {
      case MarkerType.pointOfInterest:
        return Colors.orange;
      case MarkerType.destination:
        return Colors.amber;
      case MarkerType.currentLocation:
        return Colors.red;
      default:
        return Colors.orange;
    }
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
        return 'accesibilidad buena';
      case AccessibilityLevel.medium:
        return 'accesibilidad media';
      case AccessibilityLevel.bad:
        return 'accesibilidad mala';
    }
  }
} 