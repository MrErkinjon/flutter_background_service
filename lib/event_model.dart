import 'package:event_bus/event_bus.dart';

class EventModel<T> {
  final int event;
  final T data;

  EventModel({required this.event, required this.data});
}

final eventBus = EventBus();
const eventLocationList = 1;