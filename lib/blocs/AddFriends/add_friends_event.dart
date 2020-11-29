part of 'add_friends_bloc.dart';

abstract class AddFriendsEvent extends Equatable {
  const AddFriendsEvent();
}

class SearchHitUpIdEvent extends AddFriendsEvent {
  final String hitUpId;

  SearchHitUpIdEvent(this.hitUpId);

  @override
  List<Object> get props => [hitUpId];
}

class AddButtonClickEvent extends AddFriendsEvent {
  final MyContact friend;
  final BuildContext context;

  AddButtonClickEvent(this.context, this.friend);

  @override
  List<Object> get props => [context, friend];
}

class AcceptFriendRequestEvent extends AddFriendsEvent {
  final String phoneNumber;
  final BuildContext context;

  AcceptFriendRequestEvent(this.phoneNumber, this.context);

  @override
  List<Object> get props => [phoneNumber, context];
}

class DeclineFriendRequestEvent extends AddFriendsEvent{
  final String phoneNumber;
  DeclineFriendRequestEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}
