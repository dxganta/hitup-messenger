part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class FetchHomeChatsEvent extends HomeEvent {
  @override
  List<Object> get props => [];
}

class ConnectToServerEvent extends HomeEvent {
  final BuildContext context;

  ConnectToServerEvent(this.context);

  @override
  List<Object> get props => [context];
}

class DisconnectEvent extends HomeEvent {
  @override
  List<Object> get props => [];
}
