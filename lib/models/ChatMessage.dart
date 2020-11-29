class ChatMessage {
  final String msg;
  final int time;
  final String msgType;
  final String chatId;

  ChatMessage({this.msg, this.time, this.msgType, this.chatId});

  factory ChatMessage.fromMap(Map map) {
    return ChatMessage(
      msg: map["msg"],
      time: map["time"],
      msgType: map["msgType"],
      chatId: map["chatId"],
    );
  }

  @override
  String toString() => "msg : $msg, time : $time, "
      "msgType : $msgType, chatId : $chatId";
}
