import 'package:get/get.dart';
import 'package:tourguide/core/list_service.dart';
import 'package:tourguide/features/home/data/home_model.dart';
import 'package:tourguide/features/home/data/schedule_model.dart';

class ListController extends GetxController {
  final ListService service = Get.put(ListService());

  var isLoadingFavourites = true.obs;
  var favoriteList = <PlaceModel>[].obs;

  var isLoadingVisits = true.obs;
  var visitLaterList = <ScheduledPlace>[].obs;

  @override
  void onInit() {
    fetchLists();
    super.onInit();
  }

  // --------------------------
  //  MAIN FETCHER
  // --------------------------
  Future<void> fetchLists() async {
    await fetchFavorites();
    await fetchVisitLater();
  }

  // --------------------------
  //  REMOVE FUNCTIONS
  // --------------------------
  void removeFavorite(String id) {
    favoriteList.removeWhere((p) => p.id == id);
    Get.snackbar("Removed", "Place removed from favorites");
  }

  void removeVisitLater(String placeId) {
    visitLaterList.removeWhere((s) => s.place.id == placeId);
    Get.snackbar("Removed", "Visit removed");
  }

  // --------------------------
  //  FETCH FAVORITES
  // --------------------------
  Future<void> fetchFavorites() async {
    isLoadingFavourites.value = true;
    final fetchedFav = await service.getFavourites();
    favoriteList.assignAll(fetchedFav);
    isLoadingFavourites.value = false;
  }

  // --------------------------
  //  FETCH VISIT LATER
  // --------------------------
  Future<void> fetchVisitLater() async {
    isLoadingVisits.value = true;
    final scheduledList = await service.getVisitLaterList();
    visitLaterList.assignAll(scheduledList);
    isLoadingVisits.value = false;
  }
}
