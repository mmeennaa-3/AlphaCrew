import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourguide/features/home/presentation/manager/home_getx.dart'; // Assuming your controller path

class PlaceImageWidget extends StatelessWidget {
   PlaceImageWidget({super.key, required this.placeName});

  final String placeName;
  // Get the controller instance without creating a new one
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // The dimensions of the leading image in a ListTile are typically 40-56
    const double size = 50.0; 

    return FutureBuilder<String?>(
      future: homeController.getPlaceImage(
        language: 'ar',
        placeName: placeName,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a constrained loading indicator while fetching
          return const SizedBox(
            width: size,
            height: size,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final imageUrl = snapshot.data;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Display the fetched image
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Optional: for aesthetics
            child: Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.place, color: Colors.blueAccent, size: size),
            ),
          );
        }

        // Fallback icon if no image URL is found
        return const Icon(Icons.place, color: Colors.blueAccent, size: size);
      },
    );
  }
}