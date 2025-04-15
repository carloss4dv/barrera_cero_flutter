import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:result_dart/result_dart.dart';
import '../domain/forum_message_model.dart';
import '../domain/i_forum_service.dart';

class ForumService implements IForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'forum_messages';

  @override
  Future<Result<List<ForumMessageModel>>> getMessages() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final messages = snapshot.docs
          .map((doc) => ForumMessageModel.fromFirestore(doc))
          .toList();

      return Success(messages);
    } catch (e) {
      return Failure(Exception('Error al obtener mensajes: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ForumMessageModel>> addMessage(
    String content,
    String userId,
    String userName,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final message = ForumMessageModel(
        id: docRef.id,
        userId: userId,
        userName: userName,
        content: content,
        createdAt: DateTime.now(),
        comments: [],
        likes: 0,
      );

      await docRef.set(message.toMap());
      return Success(message);
    } catch (e) {
      return Failure(Exception('Error al agregar mensaje: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ForumMessageModel>> addComment(
    String messageId,
    String content,
    String userId,
    String userName,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc(messageId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return Failure(Exception('Mensaje no encontrado'));
      }

      final message = ForumMessageModel.fromFirestore(doc);
      final comment = ForumCommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        content: content,
        createdAt: DateTime.now(),
      );

      final updatedComments = [...message.comments, comment];
      await docRef.update({
        'comments': updatedComments.map((c) => c.toMap()).toList(),
      });

      return Success(message.copyWith(comments: updatedComments));
    } catch (e) {
      return Failure(Exception('Error al agregar comentario: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ForumMessageModel>> likeMessage(
    String messageId,
    String userId,
  ) async {
    try {
      final docRef = _firestore.collection(_collection).doc(messageId);
      final doc = await docRef.get();

      if (!doc.exists) {
        return Failure(Exception('Mensaje no encontrado'));
      }

      final message = ForumMessageModel.fromFirestore(doc);
      await docRef.update({
        'likes': message.likes + 1,
      });

      return Success(message.copyWith(likes: message.likes + 1));
    } catch (e) {
      return Failure(Exception('Error al dar like: ${e.toString()}'));
    }
  }
} 