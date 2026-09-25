class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String type; // text, voice
  final String? message;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isRead;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    this.message,
    this.voiceUrl,
    this.voiceDuration,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final data =
        json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return MessageModel(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id'].toString()) ?? 0,
      senderId: data['sender_id'] is int
          ? data['sender_id']
          : int.tryParse(data['sender_id'].toString()) ?? 0,
      receiverId: data['receiver_id'] is int
          ? data['receiver_id']
          : int.tryParse(data['receiver_id'].toString()) ?? 0,
      type: data['type']?.toString() ?? 'text',
      message: data['message']?.toString(),
      voiceUrl: data['voice_url']?.toString(),
      voiceDuration: data['voice_duration'] is int
          ? data['voice_duration']
          : int.tryParse(data['voice_duration'].toString()),
      isRead: data['is_read'] == true || data['is_read'] == 1,
      createdAt: data['created_at']?.toString() ?? '',
    );
  }
}

class ConversationModel {
  final int friendId;
  final String username;
  final String? avatarUrl;
  final String? lastMessage;
  final String lastMessageType;
  final String lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.friendId,
    required this.username,
    this.avatarUrl,
    this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final friendMap = json['friend'] is Map<String, dynamic>
        ? json['friend'] as Map<String, dynamic>
        : {};

    return ConversationModel(
      friendId: friendMap['id'] is int
          ? friendMap['id']
          : int.tryParse(friendMap['id'].toString()) ?? 0,
      username: friendMap['username']?.toString() ?? 'Friend',
      avatarUrl: friendMap['avatar_url']?.toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageType: json['last_message_type']?.toString() ?? 'text',
      lastMessageAt: json['last_message_at']?.toString() ?? '',
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(json['unread_count'].toString()) ?? 0,
    );
  }
}

class FriendModel {
  final int id;
  final int? userId;
  final String username;
  final String? avatarUrl;
  final bool isOnline;
  final String status;

  FriendModel({
    required this.id,
    this.userId,
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
    this.status = 'accepted',
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    final friend = json['friend'] as Map<String, dynamic>?;
    final other = sender ?? friend;

    return FriendModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: other?['id'] is int ? other!['id'] as int : (json['user_id'] is int ? json['user_id'] as int : null),
      username: json['username']?.toString() ?? other?['username']?.toString() ?? 'Friend',
      avatarUrl: json['avatar_url']?.toString() ?? other?['avatar_url']?.toString(),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      status: json['status']?.toString() ?? 'accepted',
    );
  }
}
