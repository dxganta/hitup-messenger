part of 'add_friends_bloc.dart';

abstract class AddFriendsState extends Equatable {
  const AddFriendsState();
}

class AddFriendsInitial extends AddFriendsState {
  @override
  List<Object> get props => [];
}

class SearchingHitUpIdState extends AddFriendsState {
  @override
  List<Object> get props => [];
}

class HitUpIdExistsState extends AddFriendsState {
  final MyContact friend;

  HitUpIdExistsState(this.friend);

  @override
  List<Object> get props => [friend];
}

class HitUpIdNotExistsState extends AddFriendsState {
  final String hitupId;

  HitUpIdNotExistsState(this.hitupId);
  @override
  List<Object> get props => [hitupId];
}

class HitUpIdAlreadyThere extends AddFriendsState {
  final String hitUpId;
  final HitUpIdLocation hitUpIdLocation;

  HitUpIdAlreadyThere(this.hitUpId, this.hitUpIdLocation);

  @override
  List<Object> get props => [hitUpId, hitUpIdLocation];
}

class SendingFriendRequestState extends AddFriendsState {
  @override
  List<Object> get props => [];
}

class FriendRequestSentState extends AddFriendsState {
  final MyContact friend;

  FriendRequestSentState(this.friend);

  @override
  List<Object> get props => [friend];
}

class AcceptingFriendRequestState extends AddFriendsState {
  @override
  List<Object> get props => [];
}

class FriendRequestAcceptedState extends AddFriendsState {
  @override
  List<Object> get props => [];
}

class DecliningFriendRequestState extends AddFriendsState{
  @override
  List<Object> get props => [];
}

class FriendRequestDeclinedState extends AddFriendsState{
  @override
  List<Object> get props => [];
}
