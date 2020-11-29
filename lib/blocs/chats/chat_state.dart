part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  final ChatMessage chatMessage;

  const ChatState(this.chatMessage);
}

class ChatInitial extends ChatState {
  ChatInitial() : super(ChatMessage(msg: ".", time: null, msgType: 'text'));
  @override
  List<Object> get props => [];
}

class ReceivedMessageState extends ChatState {
  final ChatMessage chatMessage;

  ReceivedMessageState(this.chatMessage) : super(chatMessage);

  @override
  List<Object> get props => [chatMessage];
}

class InitialMessagesLoadedState extends ChatState {
  final ChatMessage chatMessage;

  InitialMessagesLoadedState(this.chatMessage) : super(chatMessage);

  @override
  List<Object> get props => [chatMessage];
}

class BlockedUserState extends ChatState{
  BlockedUserState():super(ChatMessage(msg: ".", time: null, msgType: 'text'));
  @override
  List<Object> get props => [];
}

class UnblockedUserState extends ChatState{
  UnblockedUserState():super(ChatMessage(msg:".", time: null, msgType: 'text'));

  @override
  List<Object> get props => [];
}
