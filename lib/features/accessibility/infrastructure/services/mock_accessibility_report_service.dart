import 'package:result_dart/result_dart.dart';
import '../../domain/accessibility_report_model.dart';
import '../../domain/i_accessibility_report_service.dart';
import 'dart:math';

class MockAccessibilityReportService implements IAccessibilityReportService {
  final Map<String, List<AccessibilityReportModel>> _markerReports = {};
  int _lastReportId = 0;
  final Random _random = Random();
  
  // Mapa de userIds a nombres para mantener consistencia
  final Map<String, String> _userNames = {
    'user1': 'Ana García',
    'user2': 'Carlos López', 
    'user3': 'María Rodríguez',
    'user4': 'Juan Martínez',
    'user5': 'Elena Fernández',
    'user6': 'David Sánchez',
    'user7': 'Laura Jiménez',
    'user8': 'Miguel Torres',
    'user9': 'Carmen Ruiz',
    'user10': 'Antonio Morales',
  };
  
  // Inicializar con datos mock
  MockAccessibilityReportService() {
    _initMockData();
  }
  
  String _generateId() {
    _lastReportId++;
    return 'report_$_lastReportId';
  }

  AccessibilityReportModel _createReport(String userId, String comments, AccessibilityLevel level) {
    return AccessibilityReportModel(
      id: _generateId(),
      userId: userId,
      userName: _userNames[userId] ?? 'Usuario',
      comments: comments,
      level: level,
    );
  }

  String _getRandomComment(AccessibilityLevel level) {
    final comments = {
      AccessibilityLevel.good: [
        'Excelente accesibilidad, todo está perfectamente adaptado',
        'Muy buena accesibilidad, no encontré ningún problema',
        'Totalmente accesible para personas con movilidad reducida',
        'Las instalaciones están muy bien adaptadas',
        'No hay barreras arquitectónicas',
      ],
      AccessibilityLevel.medium: [
        'Accesibilidad aceptable, pero hay algunas mejoras posibles',
        'Algunas áreas son accesibles, otras no tanto',
        'Hay rampas pero podrían estar mejor mantenidas',
        'La accesibilidad es regular, hay que mejorar algunos aspectos',
        'Algunos obstáculos en el camino',
      ],
      AccessibilityLevel.bad: [
        'Muy mala accesibilidad, casi imposible moverse',
        'No hay adaptaciones para personas con movilidad reducida',
        'Muchas barreras arquitectónicas',
        'Imposible acceder con silla de ruedas',
        'Necesita mejoras urgentes en accesibilidad',
      ],
    };
    
    final levelComments = comments[level]!;
    return levelComments[_random.nextInt(levelComments.length)];
  }
  
  void _initMockData() {
    // Marcadores de Zaragoza
    
    // Plaza del Pilar
    final String markerPilar = 'marker_plaza_pilar';
    _markerReports[markerPilar] = [
      _createReport('user1', 'Excelente accesibilidad, hay rampas por todos lados', AccessibilityLevel.good),
      _createReport('user2', 'La plaza está muy bien adaptada para sillas de ruedas', AccessibilityLevel.good),
      _createReport('user3', 'Algunos pavimentos irregulares cerca de la fuente', AccessibilityLevel.medium),
    ];
    
    // Mercado Central
    final String markerMercado = 'marker_mercado_central';
    _markerReports[markerMercado] = [
      _createReport('user4', 'Entrada principal con buen acceso y ascensor', AccessibilityLevel.good),
      _createReport('user5', 'Pasillos amplios en general, pero algunos puestos son estrechos', AccessibilityLevel.medium),
      _createReport('user6', 'A veces hay mucha gente y es difícil moverse en silla de ruedas', AccessibilityLevel.medium),
    ];
    
    // Parque Grande
    final String markerParqueGrande = 'marker_parque_grande';
    _markerReports[markerParqueGrande] = [
      _createReport('user2', 'Los caminos principales están bien adaptados', AccessibilityLevel.good),
      _createReport('user3', 'La zona de las escaleras no tiene alternativa accesible', AccessibilityLevel.bad),
      _createReport('user7', 'Los senderos secundarios son difíciles para sillas de ruedas', AccessibilityLevel.medium),
    ];
    
    // La Aljafería
    final String markerAljaferia = 'marker_aljaferia';
    _markerReports[markerAljaferia] = [
      _createReport('user1', 'Dispone de rampas y ascensor, pero algunas zonas no son accesibles', AccessibilityLevel.medium),
      _createReport('user8', 'El acceso principal está bien adaptado', AccessibilityLevel.good),
      _createReport('user5', 'Las zonas históricas tienen limitaciones de accesibilidad', AccessibilityLevel.medium),
    ];
    
    // Puente de Piedra
    final String markerPuente = 'marker_puente_piedra';
    _markerReports[markerPuente] = [
      _createReport('user3', 'Aceras estrechas y con bordillos altos', AccessibilityLevel.bad),
      _createReport('user6', 'Difícil cruzar con silla de ruedas, mejor buscar alternativa', AccessibilityLevel.bad),
      _createReport('user9', 'Las rampas de acceso son muy empinadas', AccessibilityLevel.medium),
    ];
    
    // Estación Delicias
    final String markerDelicias = 'marker_estacion_delicias';
    _markerReports[markerDelicias] = [
      _createReport('user4', 'Excelente accesibilidad general, ascensores y rampas', AccessibilityLevel.good),
      _createReport('user7', 'Zonas comerciales totalmente accesibles', AccessibilityLevel.good),
      _createReport('user5', 'Personal muy atento con las personas de movilidad reducida', AccessibilityLevel.good),
    ];
    
    // El Tubo
    final String markerTubo = 'marker_el_tubo';
    _markerReports[markerTubo] = [
      _createReport('user1', 'Calles estrechas y con adoquines, muy complicado para sillas', AccessibilityLevel.bad),
      _createReport('user8', 'Imposible transitar en algunas calles con silla de ruedas', AccessibilityLevel.bad),
      _createReport('user10', 'Algunos bares tienen escalones en la entrada sin rampa', AccessibilityLevel.bad),
    ];
    
    // Centro Comercial GranCasa
    final String markerGranCasa = 'marker_grancasa';
    _markerReports[markerGranCasa] = [
      _createReport('user2', 'Totalmente accesible, ascensores amplios y baños adaptados', AccessibilityLevel.good),
      _createReport('user4', 'Los pasillos son amplios y bien señalizados', AccessibilityLevel.good),
      _createReport('user9', 'Algunas tiendas tienen espacios estrechos', AccessibilityLevel.medium),
    ];
    
    // Ciudad Universitaria
    final String markerUniversidad = 'marker_universidad';
    _markerReports[markerUniversidad] = [
      _createReport('user5', 'La mayoría de facultades están adaptadas, pero con limitaciones', AccessibilityLevel.medium),
      _createReport('user6', 'Edificios nuevos con buena accesibilidad', AccessibilityLevel.good),
      _createReport('user10', 'Algunos edificios históricos tienen problemas de acceso', AccessibilityLevel.medium),
    ];
    
    // Incluir también los datos mock originales
    final String marker1 = 'marker_plaza_mayor';
    _markerReports[marker1] = [
      _createReport('user1', 'Buen acceso para sillas de ruedas', AccessibilityLevel.good),
      _createReport('user2', 'Rampas bien mantenidas', AccessibilityLevel.good),
      _createReport('user3', 'Algunos obstáculos en el camino', AccessibilityLevel.medium),
    ];
    
    final String marker2 = 'marker_calle_principal';
    _markerReports[marker2] = [
      _createReport('user1', 'Aceras estrechas', AccessibilityLevel.medium),
      _createReport('user2', 'Algunas rampas están deterioradas', AccessibilityLevel.medium),
      _createReport('user4', 'Hay un tramo con buen acceso', AccessibilityLevel.good),
    ];
    
    final String marker3 = 'marker_callejon';
    _markerReports[marker3] = [
      _createReport('user1', 'Imposible pasar con silla de ruedas', AccessibilityLevel.bad),
      _createReport('user5', 'Escaleras sin alternativa accesible', AccessibilityLevel.bad),
      _createReport('user3', 'Aceras muy deterioradas', AccessibilityLevel.bad),
    ];
  }
  @override
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> addReport(
      String markerId, AccessibilityReportModel report) async {
    try {
      if (!_markerReports.containsKey(markerId)) {
        _markerReports[markerId] = [];
      }
      
      // Verificar si el usuario ya tiene un reporte para este marcador
      final existingUserReports = _markerReports[markerId]!.where((r) => r.userId == report.userId).toList();
      if (existingUserReports.isNotEmpty) {
        return Failure(
          AccessibilityReportException('El usuario ya tiene un reporte para este lugar. Use updateReport para modificarlo.'),
        );
      }
      
      final newReport = AccessibilityReportModel(
        id: _generateId(), 
        userId: report.userId,
        userName: report.userName,
        comments: report.comments,
        level: report.level,
      );
      
      _markerReports[markerId]!.add(newReport);
      return Success(newReport);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al añadir reporte: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<List<AccessibilityReportModel>, AccessibilityReportException>> getUserReportForMarker(
      String markerId, String userId) async {
    try {
      if (!_markerReports.containsKey(markerId)) {
        return Success([]);
      }
      
      final userReports = _markerReports[markerId]!
          .where((report) => report.userId == userId)
          .toList();
      
      return Success(userReports);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al obtener reporte del usuario: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> updateReport(
      String markerId, AccessibilityReportModel report) async {
    try {
      if (!_markerReports.containsKey(markerId)) {
        return Failure(
          AccessibilityReportException('No se encontró el marcador'),
        );
      }
      
      final reports = _markerReports[markerId]!;
      final index = reports.indexWhere((r) => r.id == report.id);
      
      if (index == -1) {
        return Failure(
          AccessibilityReportException('No se encontró el reporte a actualizar'),
        );
      }
      
      // Actualizar el reporte manteniendo el mismo ID
      final updatedReport = AccessibilityReportModel(
        id: report.id,
        userId: report.userId,
        userName: report.userName,
        comments: report.comments,
        level: report.level,
      );
      
      reports[index] = updatedReport;
      return Success(updatedReport);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al actualizar reporte: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<AccessibilityLevel, AccessibilityReportException>> getAccessibilityLevelForMarker(
      String markerId) async {
    try {
      if (!_markerReports.containsKey(markerId) || _markerReports[markerId]!.isEmpty) {
        return Failure(
          AccessibilityReportException('No hay reportes para este marcador'),
        );
      }
      
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
      
      return Success(predominantLevel);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al calcular nivel de accesibilidad: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ResultDart<Map<AccessibilityLevel, int>, AccessibilityReportException>> getReportCountByLevel(
      String markerId) async {
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
    if (!_markerReports.containsKey(markerId)) {
      return {
        AccessibilityLevel.good: 0,
        AccessibilityLevel.medium: 0,
        AccessibilityLevel.bad: 0,
      };
    }
    
    final reports = _markerReports[markerId]!;
    final Map<AccessibilityLevel, int> countByLevel = {
      AccessibilityLevel.good: 0,
      AccessibilityLevel.medium: 0,
      AccessibilityLevel.bad: 0,
    };
    
    for (var report in reports) {
      countByLevel[report.level] = (countByLevel[report.level] ?? 0) + 1;
    }
    
    return countByLevel;
  }

  @override
  Future<ResultDart<List<AccessibilityReportModel>, AccessibilityReportException>> getReportsForMarker(
      String markerId) async {
    try {
      if (!_markerReports.containsKey(markerId)) {
        return Success([]);
      }
      
      return Success(_markerReports[markerId]!);
    } catch (e) {
      return Failure(
        AccessibilityReportException('Error al obtener reportes: ${e.toString()}'),
      );
    }
  }
}