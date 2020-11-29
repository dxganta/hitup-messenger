part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class SendMessageEvent extends ChatEvent {
  final BuildContext context;
  final String msg;
  final String chatId;

  SendMessageEvent(this.context, this.msg, this.chatId);

  @override
  List<Object> get props => [msg, chatId];
}

class SendImageEvent extends ChatEvent {
  final BuildContext context;
  final File imageFile;
  final String chatId;

  SendImageEvent(this.context, this.imageFile, this.chatId);

  @override
  List<Object> get props => [imageFile, chatId];
}

class ReceivedMessageEvent extends ChatEvent {
  final String chatId;

  ReceivedMessageEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class LoadInitialMessagesEvent extends ChatEvent {
  final String chatId;

  LoadInitialMessagesEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class BlockUserEvent extends ChatEvent{
  final BuildContext context;
  final String chatId;
  BlockUserEvent(this.context, this.chatId);

  @override
  List<Object> get props => [context, chatId];
}

class UnblockUserEvent extends ChatEvent{
  final BuildContext context;
  final String chatId;
  UnblockUserEvent(this.context, this.chatId);

  @override
  List<Object> get props => [context, chatId];
}
