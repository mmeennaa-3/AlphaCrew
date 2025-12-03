import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourguide/core/list_service.dart';
import 'package:tourguide/features/home/data/home_model.dart'; // <-- Correct Model Import
import 'package:tourguide/features/home/presentation/manager/home_getx.dart';
import 'package:tourguide/core/services/notification_service.dart';
import '../core/services/notification_service.dart';

class PlaceDetailPage extends StatelessWidget {
  final PlaceModel place;
  final HomeController homeController = Get.find<HomeController>();
  final ListService listService = Get.put(ListService());

  PlaceDetailPage({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(place.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 🖼️ Place Picture
            _buildPlaceImage(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        // Accessing properties that should exist on PlaceModel
                        "Rating: ",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    place.formattedAddress,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.favorite_border,
                        label: 'Add to Favorites',
                        onPressed: () {
                          _handleAddToFavorites(place);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.schedule,
                        label: 'Visit Later',
                        onPressed: () {
                          _handleScheduleVisit(context, place);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPlaceImage(BuildContext context) {
    return FutureBuilder<String?>(
      // ⭐️ Calling the controller method with 'ar' language ⭐️
      future: homeController.getPlaceImage(
        language: 'ar',
        placeName: place.name ?? place.formattedAddress ?? 'Unknown',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final imageUrl = snapshot.data;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              width: double.infinity,
              color: Colors.red[100],
              child: const Center(child: Text("Failed to load image")),
            ),
          );
        }

        // Fallback placeholder if no URL is returned
        return Container(
          height: 250,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  void _handleAddToFavorites(PlaceModel place) async {
    final result = await listService.addToFavorites(place);
    Get.snackbar(
      "Favorites",
      result == null ? "Added to Favorites!" : "Error: $result",
      backgroundColor: result == null ? Colors.green : Colors.red,
      colorText: Colors.white,
    );
    print(result);
  }

  void _handleScheduleVisit(BuildContext context, PlaceModel place) async {
    // 1. Show date/time picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // Combine date and time
    final DateTime visitTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final result = await listService.addToVisitsLater(place, visitTime);
    print(result);

    NotificationService.scheduleVisitNotification(
      id: place.id.hashCode,
      title: 'Visit Reminder',
      body: 'It\'s time to visit ${place.name}',
      dateTime: visitTime,
    );

    Get.snackbar(
      "Visit Later",
      result == null
          ? "Visit scheduled for ${visitTime.toIso8601String().split('T').first}"
          : "Error: $result",
      backgroundColor: result == null ? Colors.blue : Colors.red,
      colorText: Colors.white,
    );
  }
}


