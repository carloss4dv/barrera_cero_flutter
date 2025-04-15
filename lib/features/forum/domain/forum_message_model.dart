import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forum_message_model.g.dart';

@JsonSerializable()
class ForumMessageModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  final List<ForumCommentModel> comments;
  final int likes;

  ForumMessageModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.comments,
    required this.likes,
  });

  factory ForumMessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForumMessageModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      comments: (data['comments'] as List<dynamic>?)
          ?.map((comment) => ForumCommentModel.fromMap(comment))
          .toList() ?? [],
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'likes': likes,
    };
  }

  factory ForumMessageModel.fromJson(Map<String, dynamic> json) => _$ForumMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ForumMessageModelToJson(this);

  ForumMessageModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
    List<ForumCommentModel>? comments,
    int? likes,
  }) {
    return ForumMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _dateTimeToTimestamp(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable()
class ForumCommentModel {
  final String id;
  final String userId;
  final String userName;
  final String content;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  ForumCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory ForumCommentModel.fromMap(Map<String, dynamic> map) {
    return ForumCommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ForumCommentModel.fromJson(Map<String, dynamic> json) => _$ForumCommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$ForumCommentModelToJson(this);

  static DateTime _dateTimeFromTimestamp(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _dateTimeToTimestamp(DateTime date) => Timestamp.fromDate(date);
} 