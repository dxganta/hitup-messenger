part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  final List<Conversation> conversations;
  const HomeState(this.conversations);
}

class HomeInitial extends HomeState {
  HomeInitial() : super([]);

  @override
  List<Object> get props => [];
}

class FetchedHomeChatsState extends HomeState {
  final List<Conversation> conversations;
  FetchedHomeChatsState(this.conversations) : super(conversations);

  @override
  List<Object> get props => [conversations];
}
