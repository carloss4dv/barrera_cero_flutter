// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumMessageModel _$ForumMessageModelFromJson(Map<String, dynamic> json) =>
    ForumMessageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: ForumMessageModel._dateTimeFromTimestamp(
        json['createdAt'] as Timestamp,
      ),
      comments:
          (json['comments'] as List<dynamic>)
              .map((e) => ForumCommentModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      likes: (json['likes'] as num).toInt(),
    );

Map<String, dynamic> _$ForumMessageModelToJson(ForumMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'content': instance.content,
      'createdAt': ForumMessageModel._dateTimeToTimestamp(instance.createdAt),
      'comments': instance.comments,
      'likes': instance.likes,
    };

ForumCommentModel _$ForumCommentModelFromJson(Map<String, dynamic> json) =>
    ForumCommentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: ForumCommentModel._dateTimeFromTimestamp(
        json['createdAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$ForumCommentModelToJson(ForumCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'content': instance.content,
      'createdAt': ForumCommentModel._dateTimeToTimestamp(instance.createdAt),
    };
