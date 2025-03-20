import 'package:result_dart/result_dart.dart';
import '../../domain/accessibility_report_model.dart';
import '../../domain/i_accessibility_report_service.dart';

class MockAccessibilityReportService implements IAccessibilityReportService {
  final Map<String, List<AccessibilityReportModel>> _markerReports = {};
  int _lastReportId = 0;
  
  // Inicializar con datos mock
  MockAccessibilityReportService() {
    _initMockData();
  }
  
  String _generateId() {
    _lastReportId++;
    return 'report_$_lastReportId';
  }
  
  void _initMockData() {
    // Marcadores de Zaragoza
    
    // Plaza del Pilar
    final String markerPilar = 'marker_plaza_pilar';
    _markerReports[markerPilar] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Excelente accesibilidad, hay rampas por todos lados',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user2',
        comments: 'La plaza está muy bien adaptada para sillas de ruedas',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user3',
        comments: 'Algunos pavimentos irregulares cerca de la fuente',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Mercado Central
    final String markerMercado = 'marker_mercado_central';
    _markerReports[markerMercado] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user4',
        comments: 'Entrada principal con buen acceso y ascensor',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user5',
        comments: 'Pasillos amplios en general, pero algunos puestos son estrechos',
        level: AccessibilityLevel.medium,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user6',
        comments: 'A veces hay mucha gente y es difícil moverse en silla de ruedas',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Parque Grande
    final String markerParqueGrande = 'marker_parque_grande';
    _markerReports[markerParqueGrande] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user2',
        comments: 'Los caminos principales están bien adaptados',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user3',
        comments: 'La zona de las escaleras no tiene alternativa accesible',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user7',
        comments: 'Los senderos secundarios son difíciles para sillas de ruedas',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // La Aljafería
    final String markerAljaferia = 'marker_aljaferia';
    _markerReports[markerAljaferia] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Dispone de rampas y ascensor, pero algunas zonas no son accesibles',
        level: AccessibilityLevel.medium,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user8',
        comments: 'El acceso principal está bien adaptado',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user5',
        comments: 'Las zonas históricas tienen limitaciones de accesibilidad',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Puente de Piedra
    final String markerPuente = 'marker_puente_piedra';
    _markerReports[markerPuente] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user3',
        comments: 'Aceras estrechas y con bordillos altos',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user6',
        comments: 'Difícil cruzar con silla de ruedas, mejor buscar alternativa',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user9',
        comments: 'Las rampas de acceso son muy empinadas',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Estación Delicias
    final String markerDelicias = 'marker_estacion_delicias';
    _markerReports[markerDelicias] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user4',
        comments: 'Excelente accesibilidad general, ascensores y rampas',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user7',
        comments: 'Zonas comerciales totalmente accesibles',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user5',
        comments: 'Personal muy atento con las personas de movilidad reducida',
        level: AccessibilityLevel.good,
      ),
    ];
    
    // El Tubo
    final String markerTubo = 'marker_el_tubo';
    _markerReports[markerTubo] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Calles estrechas y con adoquines, muy complicado para sillas',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user8',
        comments: 'Imposible transitar en algunas calles con silla de ruedas',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user10',
        comments: 'Algunos bares tienen escalones en la entrada sin rampa',
        level: AccessibilityLevel.bad,
      ),
    ];
    
    // Centro Comercial GranCasa
    final String markerGranCasa = 'marker_grancasa';
    _markerReports[markerGranCasa] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user2',
        comments: 'Totalmente accesible, ascensores amplios y baños adaptados',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user4',
        comments: 'Los pasillos son amplios y bien señalizados',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user9',
        comments: 'Algunas tiendas tienen espacios estrechos',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Ciudad Universitaria
    final String markerUniversidad = 'marker_universidad';
    _markerReports[markerUniversidad] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user5',
        comments: 'La mayoría de facultades están adaptadas, pero con limitaciones',
        level: AccessibilityLevel.medium,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user6',
        comments: 'Edificios nuevos con buena accesibilidad',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user10',
        comments: 'Algunos edificios históricos tienen problemas de acceso',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    // Incluir también los datos mock originales
    final String marker1 = 'marker_plaza_mayor';
    _markerReports[marker1] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Buen acceso para sillas de ruedas',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user2',
        comments: 'Rampas bien mantenidas',
        level: AccessibilityLevel.good,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user3',
        comments: 'Algunos obstáculos en el camino',
        level: AccessibilityLevel.medium,
      ),
    ];
    
    final String marker2 = 'marker_calle_principal';
    _markerReports[marker2] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Aceras estrechas',
        level: AccessibilityLevel.medium,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user2',
        comments: 'Algunas rampas están deterioradas',
        level: AccessibilityLevel.medium,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user4',
        comments: 'Hay un tramo con buen acceso',
        level: AccessibilityLevel.good,
      ),
    ];
    
    final String marker3 = 'marker_callejon';
    _markerReports[marker3] = [
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user1',
        comments: 'Imposible pasar con silla de ruedas',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user5',
        comments: 'Escaleras sin alternativa accesible',
        level: AccessibilityLevel.bad,
      ),
      AccessibilityReportModel(
        id: _generateId(),
        userId: 'user3',
        comments: 'Aceras muy deterioradas',
        level: AccessibilityLevel.bad,
      ),
    ];
  }

  @override
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> addReport(
      String markerId, AccessibilityReportModel report) async {
    try {
      if (!_markerReports.containsKey(markerId)) {
        _markerReports[markerId] = [];
      }
      
      final newReport = AccessibilityReportModel(
        id: _generateId(), 
        userId: report.userId,
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