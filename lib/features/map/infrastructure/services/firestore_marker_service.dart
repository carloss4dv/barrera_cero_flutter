import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:result_type/result_type.dart';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_model.dart';
import '../../domain/marker_metadata.dart';

class FirestoreMarkerService implements IMarkerService {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'places';

  FirestoreMarkerService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Convierte un documento de Firestore a un MarkerModel
  MarkerModel _convertToMarker(DocumentSnapshot doc) {
    try {
      print('\nConvirtiendo documento a MarkerModel...');
      print('Documento ID: ${doc.id}');
      
      final data = doc.data() as Map<String, dynamic>;
      print('Datos del documento: $data');
      
      if (!data.containsKey('position')) {
        throw Exception('El documento no tiene campo position');
      }
      
      final geoPoint = data['position'] as GeoPoint;
      print('Posición: lat=${geoPoint.latitude}, lon=${geoPoint.longitude}');
      
      final type = data['type'] as String? ?? 'pointOfInterest';
      print('Tipo: $type');
      
      final marker = MarkerModel(
        id: doc.id,
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        type: MarkerType.values.firstWhere(
          (e) => e.toString() == 'MarkerType.$type',
          orElse: () => MarkerType.pointOfInterest,
        ),
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        metadata: MarkerMetadata.fromJson(data['metadata'] ?? {}),
      );
      
      print('MarkerModel creado exitosamente');
      return marker;
    } catch (e) {
      print('Error al convertir documento a MarkerModel: $e');
      rethrow;
    }
  }

  /// Convierte un MarkerModel a un Map para guardar en Firestore
  Map<String, dynamic> _convertToDocument(MarkerModel marker) {
    return {
      'position': GeoPoint(
        marker.position.latitude,
        marker.position.longitude,
      ),
      'type': marker.type.toString().split('.').last,
      'title': marker.title,
      'description': marker.description,
      'metadata': marker.metadata.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Guarda o actualiza un lugar en Firestore
  Future<Result<MarkerModel, MarkerError>> savePlace(MarkerModel marker) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(marker.id.isEmpty ? null : marker.id);
      final data = _convertToDocument(marker);
      
      await docRef.set(data, SetOptions(merge: true));
      
      // Recuperar el documento actualizado
      final updatedDoc = await docRef.get();
      return Success(_convertToMarker(updatedDoc));
    } catch (e) {
      return Failure(MarkerError.serverError(e.toString()));
    }
  }

  /// Obtiene un lugar específico por su ID
  @override
  Future<Result<MarkerModel, MarkerError>> getMarkerById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (!doc.exists) {
        return Failure(const MarkerError.notFound('Lugar no encontrado'));
      }
      
      return Success(_convertToMarker(doc));
    } catch (e) {
      return Failure(MarkerError.serverError(e.toString()));
    }
  }

  /// Obtiene lugares cercanos a una ubicación
  @override
  Future<Result<List<MarkerModel>, MarkerError>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusInMeters = 1000,
  }) async {
    try {
      // Convertir el radio de metros a grados (aproximación)
      final radiusInDegrees = radiusInMeters / 111320;
      
      // Crear bounds para la búsqueda
      final lowerLat = latitude - radiusInDegrees;
      final upperLat = latitude + radiusInDegrees;
      final lowerLon = longitude - radiusInDegrees;
      final upperLon = longitude + radiusInDegrees;
      
      // Consultar lugares dentro del área
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('position', isGreaterThan: GeoPoint(lowerLat, lowerLon))
          .where('position', isLessThan: GeoPoint(upperLat, upperLon))
          .get();
      
      final markers = querySnapshot.docs
          .map((doc) => _convertToMarker(doc))
          .where((marker) {
            // Filtrar más precisamente usando la distancia real
            final distance = const Distance().as(
              LengthUnit.Meter,
              LatLng(latitude, longitude),
              marker.position,
            );
            return distance <= radiusInMeters;
          })
          .toList();
      
      return Success(markers);
    } catch (e) {
      return Failure(MarkerError.serverError(e.toString()));
    }
  }

  /// Elimina un lugar por su ID
  Future<Result<void, MarkerError>> deletePlace(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      return Success(null);
    } catch (e) {
      return Failure(MarkerError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<MarkerModel, MarkerError>> getCurrentLocation() async {
    // Esta función debería implementarse usando un servicio de geolocalización
    // No es parte de la funcionalidad de Firestore
    throw UnimplementedError();
  }

  /// Obtiene todos los lugares guardados en Firestore
  Future<Result<List<MarkerModel>, MarkerError>> getAllPlaces() async {
    try {
      print('\nIntentando obtener documentos de Firestore...');
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .get();
      
      print('Número de documentos encontrados: ${querySnapshot.docs.length}');
      
      if (querySnapshot.docs.isEmpty) {
        print('No se encontraron documentos en la colección $_collectionName');
        return Success([]);
      }

      print('\nDetalles de los documentos:');
      for (var doc in querySnapshot.docs) {
        print('Documento ID: ${doc.id}');
        print('Datos: ${doc.data()}');
      }

      final markers = querySnapshot.docs
          .map((doc) {
            try {
              return _convertToMarker(doc);
            } catch (e) {
              print('Error al convertir documento ${doc.id}: $e');
              print('Datos del documento: ${doc.data()}');
              rethrow;
            }
          })
          .toList();

      print('\nMarcadores convertidos: ${markers.length}');
      for (var marker in markers) {
        print('- ID: ${marker.id}, Título: ${marker.title}, Posición: ${marker.position.latitude}, ${marker.position.longitude}');
      }

      return Success(markers);
    } catch (e) {
      print('\nError al obtener lugares de Firestore: $e');
      return Failure(MarkerError.serverError(e.toString()));
    }
  }
} 