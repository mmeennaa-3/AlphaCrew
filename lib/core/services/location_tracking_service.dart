import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';
//import 'package:tourguide/features/home/data/home_model.dart';
import 'package:tourguide/features/home/models/saved_place.dart';

class LocationTrackingService {
  static StreamSubscription<Position>? _positionStream;

  static void startTracking(List<SavedPlace> places, {double radius = 100}) {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // كل 10 متر يحدث
      ),
    ).listen((position) {
      for (var place in places) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          place.latitude,
          place.longitude,
        );

        if (distance <= radius) {
          // لو قربنا من المكان أرسل notification
          NotificationService.scheduleVisitNotification(
            id: place.id.hashCode,
            title: 'Nearby Place',
            body: 'You are near ${place.name}',
            dateTime: DateTime.now(),
            type: NotificationType.location,
          );
        }
      }
    });
  }

  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
