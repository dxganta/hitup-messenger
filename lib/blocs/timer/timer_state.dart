part of 'timer_bloc.dart';

abstract class TimerState extends Equatable {
  const TimerState();
}

class TimerInitial extends TimerState {
  @override
  List<Object> get props => [];
}

class TimerRunInProgressState extends TimerState {
  final int newTick;

  TimerRunInProgressState(this.newTick);

  @override
  List<Object> get props => [newTick];
}

class TimerStoppedState extends TimerState {
  @override
  List<Object> get props => [];
}
