part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> chatMessages;

  const ChatState(this.chatMessages);
}

class ChatInitial extends ChatState {
  ChatInitial() : super([]);
  @override
  List<Object> get props => [];
}

class ReceivedMessageState extends ChatState {
  final List<ChatMessage> chatMessages;

  ReceivedMessageState(this.chatMessages) : super(chatMessages);

  @override
  List<Object> get props => [chatMessages];
}

class InitialMessagesLoadedState extends ChatState {
  final List<ChatMessage> chatMessages;

  InitialMessagesLoadedState(this.chatMessages) : super(chatMessages);

  @override
  List<Object> get props => [chatMessages];
}

class BlockedUserState extends ChatState {
  BlockedUserState() : super([]);
  @override
  List<Object> get props => [];
}

class UnblockedUserState extends ChatState {
  UnblockedUserState() : super([]);

  @override
  List<Object> get props => [];
}
