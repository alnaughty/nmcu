import 'package:cloud_firestore/cloud_firestore.dart';

class ChatroomModel {
  final List<Chat> chats;
  final Timestamp timestamp;

  const ChatroomModel({required this.chats, required this.timestamp});
  factory ChatroomModel.fromFirestore(Map<String, dynamic> data) {
    // Assuming 'chats' is a field that contains an array of chat data
    var chatData = List<Map<String, dynamic>>.from(data['chats'] ?? []);
    List<Chat> chatsList =
        chatData.map((chat) => Chat.fromFirestore(chat, "")).toList();
    print(data['updated_at']);
    return ChatroomModel(
      chats: chatsList,
      timestamp: data['updated_at'] as Timestamp,
      // timestamp: Timestamp.fromDate(DateTime.parse()),
    );
  }

  // Convert ChatroomModel to Firestore format (for adding or updating in Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'chats': chats.map((chat) => chat.toFirestore()).toList(),
      'timestamp': timestamp,
    };
  }
}

class Chat {
  final String id;
  final int userId;
  final String message, senderName, senderAvatar;
  final String? photoUrl;
  final Timestamp timestamp;

  Chat({
    required this.senderName,
    required this.id,
    required this.userId,
    required this.message,
    required this.senderAvatar,
    this.photoUrl,
    required this.timestamp,
  });

  // Convert Firestore document data to a Chat model
  factory Chat.fromFirestore(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      senderAvatar: data['sender_avatar'],
      senderName: data['sender_name'],
      userId: data['sender_id'],
      message: data['message'],
      photoUrl: data['photo_url'],
      timestamp: data['timestamp'] as Timestamp,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'message': message,
      'photo_url': photoUrl,
      'timestamp': timestamp,
      "sender_avatar": senderAvatar,
    };
  }
}
