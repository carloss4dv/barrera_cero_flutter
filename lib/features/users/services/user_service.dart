import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user.dart';
import '../../../services/local_user_storage_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';
  
  // Constantes para el sistema de puntos
  static const int VALIDATION_VOTE_POINTS = 20;
  // Crear nuevo usuario
  Future<void> createUser(User user) async {
    print('Creando usuario: ${user.toMap()}');
    await _firestore.collection(_collection).doc(user.id).set(user.toMap());
    
    // Sincronizar con almacenamiento local
    await localUserStorage.syncWithFirestore(user.toMap());
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  // Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    final querySnapshot = await _firestore.collection(_collection).get();
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data()))
        .toList();
  }
  // Actualizar usuario
  Future<void> updateUser(User user) async {
    await _firestore.collection(_collection).doc(user.id).update(user.toMap());
    
    // Sincronizar con almacenamiento local
    await localUserStorage.syncWithFirestore(user.toMap());
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }

  // Buscar usuarios por tipo de movilidad
  Future<List<User>> getUsersByMobilityType(MobilityType mobilityType) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('mobilityType', isEqualTo: mobilityType.toString().split('.').last)
        .get();
    
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data()))
        .toList();
  }
  // Añadir B-points a un usuario por validación de accesibilidad
  Future<void> awardValidationPoints(String userId) async {
    try {
      final userRef = _firestore.collection(_collection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('Usuario no encontrado');
        }
        
        final user = User.fromMap(userDoc.data()!);
        final newPoints = user.contributionPoints + VALIDATION_VOTE_POINTS;
        
        transaction.update(userRef, {
          'contributionPoints': newPoints,
          'updatedAt': DateTime.now(),
        });
      });
      
      // Actualizar puntos en almacenamiento local
      await localUserStorage.addContributionPoints(VALIDATION_VOTE_POINTS);
      
      print('Se otorgaron $VALIDATION_VOTE_POINTS B-points al usuario $userId');
    } catch (e) {
      print('Error al otorgar puntos: $e');
      throw e;
    }
  }

  // Obtener el ranking de usuarios por puntos
  Future<List<User>> getUserRankingByPoints({int limit = 10}) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .orderBy('contributionPoints', descending: true)
        .limit(limit)
        .get();
    
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data()))
        .toList();
  }  // Obtener el usuario actual (puede usar diferentes estrategias)
  Future<User?> getCurrentUser() async {
    try {
      print('DEBUG: Obteniendo usuario actual...');
      // Primero intentar obtener desde almacenamiento local
      final localUserData = await localUserStorage.getUserData();
      print('DEBUG: Datos locales obtenidos: $localUserData');
      
      if (localUserData != null && localUserData['id'] != null) {
        print('DEBUG: Buscando usuario con ID: ${localUserData['id']}');
        final user = await getUserById(localUserData['id']);
        print('DEBUG: Usuario encontrado: ${user?.id}');
        return user;
      }
      
      // Si no hay ID en los datos locales, usar el UID directamente
      if (localUserData != null && localUserData['uid'] != null) {
        print('DEBUG: Intentando con UID: ${localUserData['uid']}');
        // Crear un usuario temporal con los datos locales
        final tempUser = User(
          id: localUserData['uid'],
          email: localUserData['email'] ?? '',
          name: localUserData['name'] ?? 'Usuario',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        print('DEBUG: Usuario temporal creado: ${tempUser.id}');
        return tempUser;
      }
      
      print('DEBUG: No se encontraron datos locales de usuario');
      return null;
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  // Agregar puntos B al usuario actual
  Future<void> addBPoints(int points) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No se pudo obtener el usuario actual');
      }

      final userRef = _firestore.collection(_collection).doc(currentUser.id);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('Usuario no encontrado');
        }
        
        final user = User.fromMap(userDoc.data()!);
        final newPoints = user.contributionPoints + points;
        
        transaction.update(userRef, {
          'contributionPoints': newPoints,
          'updatedAt': DateTime.now(),
        });
      });
      
      // Actualizar puntos en almacenamiento local
      await localUserStorage.addContributionPoints(points);
      
      print('Se otorgaron $points B-points al usuario ${currentUser.id}');
    } catch (e) {
      print('Error al otorgar puntos: $e');
      throw e;
    }
  }
}