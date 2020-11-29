class Conversation {
  final String phoneNumber;
  final String lastMessage;
  final String msgType;
  final int time;
  final String photoUrl;
  final String chatId;
  final String name;
  final String username;

  Conversation({
    this.phoneNumber,
    this.lastMessage,
    this.msgType,
    this.time,
    this.photoUrl,
    this.chatId,
    this.name,
    this.username,
  });

  factory Conversation.fromMap(Map map) {
    // here map is the map from the sqflite database
    return Conversation(
      phoneNumber: map["phoneNumber"],
      lastMessage: map["msg"],
      msgType: map["msgType"],
      time: map["time"],
      photoUrl: map["photoUrl"],
      chatId: map["chatId"],
      name: map['name'],
      username: map['username'],
    );
  }

  @override
  String toString() => "phoneNumber : $phoneNumber,"
      "lastMessage : $lastMessage, msgType : $msgType, time : $time, photoUrl : $photoUrl, "
      "chatId : $chatId";
}
