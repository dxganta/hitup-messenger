part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();
}

class StartTimerEvent extends TimerEvent {
  @override
  List<Object> get props => [];
}

class TimerTickedEvent extends TimerEvent {
  final int newTick;

  TimerTickedEvent(this.newTick);

  @override
  List<Object> get props => [newTick];
}

class StopTimerEvent extends TimerEvent {
  @override
  List<Object> get props => [];
}
