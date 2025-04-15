import 'package:result_dart/result_dart.dart';
import 'forum_message_model.dart';

abstract class IForumService {
  Future<Result<List<ForumMessageModel>>> getMessages();
  Future<Result<ForumMessageModel>> addMessage(String content, String userId, String userName);
  Future<Result<ForumMessageModel>> addComment(String messageId, String content, String userId, String userName);
  Future<Result<ForumMessageModel>> likeMessage(String messageId, String userId);
} 