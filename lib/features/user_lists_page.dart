import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourguide/features/home/data/home_model.dart';
import 'package:tourguide/features/home/data/schedule_model.dart';
import 'package:tourguide/features/home/presentation/manager/list_controller.dart';

class UserListsPage extends StatelessWidget {
  final ListController controller = Get.put(ListController());

  UserListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EAF3), // خلفية زي الصورة

        appBar: AppBar(
          backgroundColor: const Color(0xFFF4EAF3),
          elevation: 0,
          title: const Text(
            'Saved Places',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.black45,
            labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Visit Later'),
            ],
          ),
        ),

        body: TabBarView(
          children: [

            Obx(() {
              if (controller.isLoadingFavourites.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: controller.fetchFavorites,
                child: controller.favoriteList.isEmpty
                    ? _emptyMessage("No Favorites Added")
                    : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: controller.favoriteList.length,
                  itemBuilder: (context, index) {
                    final place = controller.favoriteList[index];
                    return _buildPlaceCard(
                      icon: Icons.favorite_border,
                      title: place.name,
                      address: place.formattedAddress,
                      scheduled: "Not Scheduled",
                      onRemove: () => controller.removeFavorite(place.id),
                      onMap: () => Get.toNamed("/map", arguments: place),
                    );
                  },
                ),
              );
            }),


            Obx(() {
              if (controller.isLoadingVisits.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: controller.fetchVisitLater,
                child: controller.visitLaterList.isEmpty
                    ? _emptyMessage("No Visits Scheduled")
                    : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: controller.visitLaterList.length,
                  itemBuilder: (context, index) {
                    final scheduled = controller.visitLaterList[index];
                    final place = scheduled.place;
                    final scheduledTime =
                        "${scheduled.visitTime.month}/${scheduled.visitTime.day} "
                        "${scheduled.visitTime.hour}:${scheduled.visitTime.minute.toString().padLeft(2, '0')}";

                    return _buildPlaceCard(
                      icon: Icons.schedule,
                      title: place.name,
                      address: place.formattedAddress,
                      scheduled: "Scheduled: $scheduledTime",
                      onRemove: () =>
                          controller.removeVisitLater(place.id),
                      onMap: () => Get.toNamed("/map", arguments: place),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard({
    required IconData icon,
    required String title,
    required String address,
    required String scheduled,
    required VoidCallback onRemove,
    required VoidCallback onMap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, // كرت أبيض زي الصورة
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EAF3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 30),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(address,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 15)),
                const SizedBox(height: 6),
                Text(scheduled,
                    style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == "map") onMap();
              if (value == "remove") onRemove();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "remove",
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Remove", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
