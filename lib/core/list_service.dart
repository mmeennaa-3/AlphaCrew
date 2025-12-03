import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourguide/features/home/data/home_model.dart';
import 'package:tourguide/main.dart';

import '../features/home/data/schedule_model.dart';

class ListService extends GetxService {
  final user = cloud.auth.currentUser;

  //cache valid for 30 minutes
  static const Duration _cacheDuration = Duration(minutes: 30);
  final String _favBoxKey = 'favoritesCache';
  final String _visitBoxKey = 'visitsCache';

  bool _isCacheExpired(Map<String, dynamic> cachedData) {
    final storedTimestamp = cachedData['timestamp'] as String?;
    if (storedTimestamp == null) return true;

    final cacheTime = DateTime.parse(storedTimestamp);
    final expiryTime = cacheTime.add(_cacheDuration);

    return DateTime.now().isAfter(expiryTime);
  }

  Future<void> _invalidateCache(String boxKey, String userId) async {
    await Hive.box<Map>(boxKey).delete(userId);
  }

  Future<String?> savePlaceMetadata(PlaceModel place) async {
    try {
      await cloud.from('places').upsert({
        //if the consraint is met it skip the insertion
        'geoapify_id': place.id,
        'name': place.name,
        'latitude': place.lat,
        'longitude': place.lon,
        'category': place.categories.isNotEmpty ? place.categories.first : null,
        'formatted_address': place.formattedAddress,
      });
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> addToFavorites(PlaceModel place) async {
    if (user == null) return 'User is not logged in';
    final result = await savePlaceMetadata(place);
    if (result != null) return result;
    try {
      await cloud.from('favourites').insert({
        'user_id': user?.id,
        'place_id': place.id,
      });
      await _invalidateCache(_favBoxKey, user!.id);
      return null;
    } on PostgrestException catch (e) {
      // Log the specific error for debugging
      print('Metadata upsert failed: ${e.message}');
      return '$e';
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> addToVisitsLater(PlaceModel place, DateTime visitTime) async {
    if (user == null) return 'User is not looged in';
    final result = await savePlaceMetadata(place);
    if (result != null) return result;

    try {
      await cloud.from('visit_later').insert({
        'user_id': user?.id,
        'place_id': place.id,
        'visit_time': visitTime.toIso8601String(),
      });
      await _invalidateCache(_visitBoxKey, user!.id);
      return null; // Success
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return "This place is already in your schedule.";
      }
      print('Supabase error: $e');
      return "Failed to add to favorites: ${e.message}";
    } catch (e) {
      print(e);
      return "$e";
    }
  }

  Future<List<PlaceModel>> getFavourites() async {
    if (user == null) return [];

    final favoritesBox = Hive.box<Map>(_favBoxKey);
    final userId = user!.id;
    final cachedDataRaw = favoritesBox.get(userId);

    // Safe type conversion
    if (cachedDataRaw != null) {
      final cachedData = _convertToStringKeyMap(cachedDataRaw);
      if (!_isCacheExpired(cachedData)) {
        final List<dynamic> cachedList = cachedData['list'] as List<dynamic>;

        return cachedList.map((item) {
          final itemMap = _convertToStringKeyMap(item);
          final placeData = _convertToStringKeyMap(itemMap['place']);
          return PlaceModel.fromJoinedJson(placeData);
        }).toList();
      }
    }

    //if not in cache fetch from supabase
    try {
      final response = await cloud
          .from('favourites')
          .select('place_id, place:places(*)')
          .eq('user_id', user!.id);

      final List<dynamic> data = response;

      // 2. Transform to models
      final List<PlaceModel> fetchedList = data.map((item) {
        final itemMap = _convertToStringKeyMap(item);
        final placeData = _convertToStringKeyMap(itemMap['place']);
        return PlaceModel.fromJoinedJson(placeData);
      }).toList();

      //write to cache - ensure we're storing proper types
      await favoritesBox.put(userId, {
        'timestamp': DateTime.now().toIso8601String(),
        'list': data.map((item) => _convertToStringKeyMap(item)).toList(),
      });

      return fetchedList;
    } catch (e) {
      // If the network request fails, attempt to return STALE data from cache
      if (cachedDataRaw != null) {
        Get.snackbar('Offline Mode', 'Using old data. Connection failed.');

        final cachedData = _convertToStringKeyMap(cachedDataRaw);
        final List<dynamic> cachedList = cachedData['list'] as List<dynamic>;

        return cachedList.map((item) {
          final itemMap = _convertToStringKeyMap(item);
          final placeData = _convertToStringKeyMap(itemMap['place']);
          return PlaceModel.fromJoinedJson(placeData);
        }).toList();
      }
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<List<ScheduledPlace>> getVisitLaterList() async {
    if (user == null) return [];

    final visitsBox = Hive.box<Map>(_visitBoxKey);
    final userId = user!.id;
    final cachedDataRaw = visitsBox.get(userId);

    // Check Cache with safe type conversion
    if (cachedDataRaw != null) {
      final cachedData = _convertToStringKeyMap(cachedDataRaw);
      if (!_isCacheExpired(cachedData)) {
        final List<dynamic> cachedList = cachedData['list'] as List<dynamic>;

        return cachedList.map((item) {
          final itemMap = _convertToStringKeyMap(item);
          final placeData = _convertToStringKeyMap(itemMap['place']);
          final visitTime = DateTime.parse(itemMap['visit_time'] as String);
          return ScheduledPlace(
            place: PlaceModel.fromJoinedJson(placeData),
            visitTime: visitTime,
          );
        }).toList();
      }
    }

    // Fetch from cloud
    try {
      final response = await cloud
          .from('visit_later')
          .select('visit_time, place:places(*)')
          .eq('user_id', userId)
          .order('visit_time');

      final List<dynamic> data = response;

      final List<ScheduledPlace> scheduledList = data.map((item) {
        final itemMap = _convertToStringKeyMap(item);
        final placeData = _convertToStringKeyMap(itemMap['place']);
        final place = PlaceModel.fromJoinedJson(placeData);
        final visitTime = DateTime.parse(itemMap['visit_time'] as String);
        return ScheduledPlace(place: place, visitTime: visitTime);
      }).toList();

      await visitsBox.put(userId, {
        'timestamp': DateTime.now().toIso8601String(),
        'list': data.map((item) => _convertToStringKeyMap(item)).toList(),
      });

      return scheduledList;
    } catch (e) {
      if (cachedDataRaw != null) {
        final cachedData = _convertToStringKeyMap(cachedDataRaw);
        final List<dynamic> cachedList = cachedData['list'] as List<dynamic>;

        Get.snackbar('Visits Offline', 'Using old data. Check network.');

        return cachedList.map((item) {
          final itemMap = _convertToStringKeyMap(item);
          final placeData = _convertToStringKeyMap(itemMap['place']);
          final visitTime = DateTime.parse(itemMap['visit_time'] as String);
          return ScheduledPlace(
            place: PlaceModel.fromJoinedJson(placeData),
            visitTime: visitTime,
          );
        }).toList();
      }
      print('Network error fetching visits: $e');
      return [];
    }
  }

  // Helper method to safely convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertToStringKeyMap(
    Map<dynamic, dynamic> originalMap,
  ) {
    return Map<String, dynamic>.from(originalMap);
  }
}
