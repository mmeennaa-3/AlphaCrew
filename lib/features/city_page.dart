import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourguide/features/home/presentation/manager/home_getx.dart';
import 'package:tourguide/features/place_detail_page.dart';
import 'package:tourguide/features/search_page.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key, required this.center});

  final LatLng center;

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      homeController.getPlaceData(
        categoryType: 'tourism.attraction',
        lon: widget.center.longitude,
        lat: widget.center.latitude,
        radius: 5000,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Attractions"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.to(() => SearchPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.placeData.isEmpty) {
          return const Center(child: Text('No data found'));
        }

        return ListView.builder(
          itemCount: homeController.placeData.length,
          itemBuilder: (context, index) {
            final place = homeController.placeData[index];

            const double leadingSize = 50.0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: SizedBox(
                      width: leadingSize,
                      height: leadingSize,
                      child: FutureBuilder<String?>(
                        future: homeController.getPlaceImage(
                          language: 'ar',
                          placeName: place.name,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          final imageUrl = snapshot.data;

                          if (imageUrl != null && imageUrl.isNotEmpty) {
                            return Image.network(
                              imageUrl,
                              width: leadingSize,
                              height: leadingSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.place,
                                    color: Colors.blueAccent,
                                    size: leadingSize,
                                  ),
                            );
                          }
                          return const Icon(
                            Icons.place,
                            color: Colors.blueAccent,
                            size: leadingSize,
                          );
                        },
                      ),
                    ),

                    title: Text(
                      place.name.isNotEmpty ? place.name : "Unnamed place",
                    ),
                    subtitle: Text(place.formattedAddress),
                    trailing: Text(
                      place.categories.isNotEmpty
                          ? place.categories.first
                          : "No category",
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Get.to(
                        () => PlaceDetailPage(place: place),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
