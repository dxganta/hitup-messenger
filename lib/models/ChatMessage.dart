class ChatMessage {
  final String msg;
  final int time;
  final String msgType;
  // final int msgStatus;
  final String chatId;
  final bool isSelf;

  ChatMessage({this.msg, this.time, this.msgType, this.chatId, this.isSelf});

  factory ChatMessage.fromMap(Map map) {
    return ChatMessage(
      msg: map["msg"],
      time: map["time"],
      msgType: map["msgType"],
      chatId: map["chatId"],
      isSelf: map["msgStatus"] == 1 ? true : false,
    );
  }

  @override
  String toString() => "msg : $msg, time : $time, "
      "msgType : $msgType, chatId : $chatId, isSelf: $isSelf";
}
