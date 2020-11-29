import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:coocoo/config/Constants.dart';
import 'package:equatable/equatable.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(TimerStoppedState());

  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is StartTimerEvent) {
      timerStream = stopWatchStream();
      timerSubscription?.cancel();
      timerSubscription = timerStream.listen((int newTick) {
        add(TimerTickedEvent(newTick));
      });
    }
    if (event is TimerTickedEvent) {
      yield (TimerRunInProgressState(event.newTick));
    }
    if (event is StopTimerEvent) {
      timerSubscription?.cancel();
      timerStream = null;
      yield (TimerStoppedState());
    }
  }

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = Constants.resendOtpTime;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = Constants.resendOtpTime;
        streamController.close();
      }
    }

    void tick(_) {
      counter--;
      streamController.add(counter);
      if (counter < 1) {
        add(StopTimerEvent());
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }
}
