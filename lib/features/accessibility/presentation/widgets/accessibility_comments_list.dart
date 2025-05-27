import 'package:flutter/material.dart';
import '../../domain/accessibility_report_model.dart';

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
        child: CircularProgressIndicator(),
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final report = reports[index];
        return CommentItem(report: report);
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final AccessibilityReportModel report;

  const CommentItem({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar o icono del nivel de accesibilidad
          CircleAvatar(
            backgroundColor: _getLevelColor(report.level),
            child: Icon(
              _getLevelIcon(report.level),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Contenido del comentario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [                    Text(
                      report.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getLevelText(report.level),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getLevelColor(report.level),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.comments,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
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
        return 'Muy accesible (5 puntos)';
      case AccessibilityLevel.medium:
        return 'Accesible (4 puntos)';
      case AccessibilityLevel.bad:
        return 'Poco accesible (2 puntos)';
    }
  }
}