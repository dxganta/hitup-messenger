class ChatMessage {
  final String msg;
  final int time;
  final String msgType;
  final int msgStatus;
  final String chatId;

  ChatMessage({this.msg, this.time, this.msgType, this.chatId, this.msgStatus});

  factory ChatMessage.fromMap(Map map) {
    return ChatMessage(
      msg: map["msg"],
      time: map["time"],
      msgType: map["msgType"],
      chatId: map["chatId"],
      msgStatus: map["msgStatus"],
    );
  }

  @override
  String toString() => "msg : $msg, time : $time, "
      "msgType : $msgType, chatId : $chatId, msgStatus: $msgStatus";
}
