import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/accessibility_report_model.dart';
import '../../../auth/service/auth_service.dart';
import '../../../../widgets/loading_card.dart';

class AccessibilityCommentsList extends StatelessWidget {
  final List<AccessibilityReportModel> reports;
  final bool isLoading;
  final String? errorMessage;

  const AccessibilityCommentsList({
    Key? key,
    required this.reports,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: LoadingCard(
          message: 'Cargando comentarios de accesibilidad...',
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (reports.isEmpty) {
      return const Center(
        child: Text(
          'No hay reportes de accesibilidad para este lugar.',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Obtener el usuario actual
    final authService = GetIt.instance<AuthService>();
    final currentUserId = authService.currentUser?.uid;

    // Separar reportes: primero el del usuario actual, luego los demás
    final userReport = reports.where((r) => r.userId == currentUserId).toList();
    final otherReports = reports.where((r) => r.userId != currentUserId).toList();
    
    final sortedReports = [...userReport, ...otherReports];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedReports.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final report = sortedReports[index];
        final isCurrentUser = report.userId == currentUserId;
        return CommentItem(
          report: report,
          isCurrentUser: isCurrentUser,
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final AccessibilityReportModel report;
  final bool isCurrentUser;

  const CommentItem({
    Key? key,
    required this.report,
    this.isCurrentUser = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isCurrentUser ? BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.15),
            Colors.blue.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar o icono del nivel de accesibilidad
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: _getLevelColor(report.level),
                  radius: isCurrentUser ? 22 : 18,
                  child: Icon(
                    _getLevelIcon(report.level),
                    color: Colors.white,
                    size: isCurrentUser ? 22 : 18,
                  ),
                ),
                if (isCurrentUser)
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
                        Icons.person,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Contenido del comentario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            report.userName,
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.bold,
                              fontSize: isCurrentUser ? 15 : 14,
                              color: isCurrentUser ? Colors.blue[800] : Colors.black,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.blue[700]!],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Tu reporte',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor(report.level).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getLevelColor(report.level).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getLevelText(report.level),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getLevelColor(report.level),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: isCurrentUser 
                        ? const EdgeInsets.all(12) 
                        : const EdgeInsets.all(8),
                    decoration: isCurrentUser ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ) : null,
                    child: Text(
                      report.comments,
                      style: TextStyle(
                        fontSize: isCurrentUser ? 15 : 14,
                        height: 1.3,
                        color: isCurrentUser ? Colors.grey[800] : Colors.black87,
                      ),
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

  Color _getLevelColor(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return Colors.green; // Verde para reportes positivos (5 puntos)
      case AccessibilityLevel.medium:
        return Colors.amber; // Amarillo para reportes neutros (4 puntos)
      case AccessibilityLevel.bad:
        return Colors.red; // Rojo para reportes negativos (2 puntos)
    }
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
  }

  String _getLevelText(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return 'Muy accesible';
      case AccessibilityLevel.medium:
        return 'Accesible';
      case AccessibilityLevel.bad:
        return 'Poco accesible';
    }
  }
}