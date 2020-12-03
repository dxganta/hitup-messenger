import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:coocoo/functions/ChatFunction.dart';
import 'package:coocoo/managers/db_manager.dart';
import 'package:coocoo/models/ChatMessage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial());

  ChatFunction chatFunction = ChatFunction();

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if (event is SendMessageEvent) {
      chatFunction.sendMessageToServer(event.context, event.msg, event.chatId);
    }
    if (event is SendImageEvent) {
      chatFunction.sendImageToServer(
          event.context, event.imageFile, event.chatId);
    }
    if (event is ReceivedMessageEvent) {
      List<ChatMessage> allMessages =
          await chatFunction.getAllMsgsFromMessagesTable(event.chatId);
      yield (ReceivedMessageState(allMessages));
    }
    if (event is LoadInitialMessagesEvent) {
      List<ChatMessage> lastChatMsgs =
          await chatFunction.getAllMsgsFromMessagesTable(event.chatId);
      yield (InitialMessagesLoadedState(lastChatMsgs));
    }
    if (event is BlockUserEvent) {
      chatFunction.blockUser(event.context, event.chatId);
      yield (BlockedUserState());
      DBManager.db.isBlocked(event.chatId);
    }
    if (event is UnblockUserEvent) {
      chatFunction.unBlockUser(event.context, event.chatId);
      yield (UnblockedUserState());
    }
  }
}
