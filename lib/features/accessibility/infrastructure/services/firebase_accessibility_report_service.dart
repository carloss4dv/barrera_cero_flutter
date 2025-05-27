import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:result_dart/result_dart.dart';
import '../../domain/accessibility_report_model.dart';
import '../../domain/i_accessibility_report_service.dart';
import '../dtos/accessibility_report_dto.dart';

class FirebaseAccessibilityReportService implements IAccessibilityReportService {
  final FirebaseFirestore _firestore;
  
  FirebaseAccessibilityReportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ResultDart<List<AccessibilityReportModel>, AccessibilityReportException>> 
      getReportsForMarker(String markerId) async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .doc(markerId)
          .collection('accessibility_reports')
          .orderBy('created_at', descending: true)
          .get();

      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Asegurar que el ID del documento se incluya
        final dto = AccessibilityReportDto.fromJson(data);
        return dto.toDomain();
      }).toList();

      return Success(reports);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al obtener reportes: ${e.toString()}'),
      );
    }
  }
  @override
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> 
      addReport(String markerId, AccessibilityReportModel report) async {
    try {
      // Primero verificar si el usuario ya tiene un reporte para este marcador
      final existingReportsResult = await getUserReportForMarker(markerId, report.userId);
      if (existingReportsResult.isError()) {
        return Failure(existingReportsResult.exceptionOrNull()!);
      }
      
      final existingReports = existingReportsResult.getOrNull()!;
      if (existingReports.isNotEmpty) {
        return Failure(
          AccessibilityReportException('El usuario ya tiene un reporte para este lugar. Use updateReport para modificarlo.'),
        );
      }

      final reportRef = _firestore
          .collection('places')
          .doc(markerId)
          .collection('accessibility_reports')
          .doc();

      final dto = AccessibilityReportDto.fromDomain(report);
      final data = dto.toJson();
      
      // Agregar metadatos de timestamp
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();

      await reportRef.set(data);      // Crear el reporte con el ID generado
      final newReport = AccessibilityReportModel(
        id: reportRef.id,
        userId: report.userId,
        userName: report.userName,
        comments: report.comments,
        level: report.level,
      );

      return Success(newReport);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al guardar reporte: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<List<AccessibilityReportModel>, AccessibilityReportException>> 
      getUserReportForMarker(String markerId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .doc(markerId)
          .collection('accessibility_reports')
          .where('user_id', isEqualTo: userId)
          .get();

      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Asegurar que el ID del documento se incluya
        final dto = AccessibilityReportDto.fromJson(data);
        return dto.toDomain();
      }).toList();

      return Success(reports);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al obtener reporte del usuario: ${e.toString()}'),
      );
    }
  }
  @override
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> 
      updateReport(String markerId, AccessibilityReportModel report) async {
    try {
      print('Firebase: Actualizando reporte ${report.id} para marcador $markerId');
      
      final reportRef = _firestore
          .collection('places')
          .doc(markerId)
          .collection('accessibility_reports')
          .doc(report.id);

      // Verificar que el reporte existe
      final doc = await reportRef.get();
      if (!doc.exists) {
        print('Firebase: El reporte ${report.id} no existe');
        return Failure(
          AccessibilityReportException('No se encontró el reporte a actualizar'),
        );
      }

      final dto = AccessibilityReportDto.fromDomain(report);
      final data = dto.toJson();
      
      print('Firebase: Datos a actualizar: $data');
      
      // Mantener la fecha de creación original y actualizar la fecha de modificación
      data['updated_at'] = FieldValue.serverTimestamp();

      await reportRef.update(data);
      
      print('Firebase: Reporte actualizado exitosamente');

      return Success(report);
    } catch (e) {
      print('Firebase: Error al actualizar reporte: $e');
      return Failure(
        AccessibilityReportException('Error al actualizar reporte: ${e.toString()}'),
      );
    }
  }
  @override
  Future<ResultDart<AccessibilityLevel, AccessibilityReportException>> 
      getAccessibilityLevelForMarker(String markerId) async {
    try {
      final countByLevel = await _getReportCountByLevelInternal(markerId);
      
      // Encontrar el nivel con más reportes
      AccessibilityLevel predominantLevel = AccessibilityLevel.medium;
      int maxCount = 0;
      
      countByLevel.forEach((level, count) {
        if (count > maxCount) {
          maxCount = count;
          predominantLevel = level;
        }
      });
      
      // Si no hay reportes, devolver un error indicando que no hay reportes
      if (maxCount == 0) {
        return Failure(
          AccessibilityReportException('No hay reportes para este marcador'),
        );
      }
      
      return Success(predominantLevel);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al calcular nivel de accesibilidad: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<Map<AccessibilityLevel, int>, AccessibilityReportException>> 
      getReportCountByLevel(String markerId) async {
    try {
      final countByLevel = await _getReportCountByLevelInternal(markerId);
      return Success(countByLevel);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al obtener conteo de reportes: ${e.toString()}'),
      );
    }
  }

  Future<Map<AccessibilityLevel, int>> _getReportCountByLevelInternal(String markerId) async {
    final Map<AccessibilityLevel, int> countByLevel = {
      AccessibilityLevel.good: 0,
      AccessibilityLevel.medium: 0,
      AccessibilityLevel.bad: 0,
    };

    try {
      final snapshot = await _firestore
          .collection('places')
          .doc(markerId)
          .collection('accessibility_reports')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final levelString = data['accessibility_level'] as String?;
        
        if (levelString != null) {
          final level = _stringToAccessibilityLevel(levelString);
          countByLevel[level] = (countByLevel[level] ?? 0) + 1;
        }
      }
    } catch (e) {
      // Si hay error, devolver conteos en cero
      print('Error al contar reportes por nivel: $e');
    }

    return countByLevel;
  }

  AccessibilityLevel _stringToAccessibilityLevel(String levelString) {
    switch (levelString.toLowerCase()) {
      case 'good':
        return AccessibilityLevel.good;
      case 'bad':
        return AccessibilityLevel.bad;
      case 'medium':
      default:
        return AccessibilityLevel.medium;
    }
  }
}
