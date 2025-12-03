// lib/models/scheduled_place.dart

import 'package:tourguide/features/home/data/home_model.dart';

class ScheduledPlace {
  final PlaceModel place;
  final DateTime visitTime;

  ScheduledPlace({required this.place, required this.visitTime});
}