import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Crear nuevo usuario
  Future<void> createUser(User user) async {
    print('Creando usuario: ${user.toMap()}');
    await _firestore.collection(_collection).doc(user.id).set(user.toMap());
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
} 