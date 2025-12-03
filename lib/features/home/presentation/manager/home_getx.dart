import 'package:get/get.dart';
import 'package:tourguide/features/home/data/home_model.dart';
import 'package:tourguide/features/home/data/homerepo.dart';

class HomeController extends GetxController {
  final HomeRepo homeRepo = HomeRepo();

  var isLoading = false.obs;
  var placeData = <PlaceModel>[].obs;

  Future<void> getPlaceData({
    required String categoryType,
    required double lon,
    required double lat,
    required int radius,
  }) async {
    try {
      isLoading.value = true;
      final data = await homeRepo.getPlaceData(
        categoryType: categoryType,
        lon: lon,
        lat: lat,
        radius: radius,
      );
      placeData.value = data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getPlaceImage({
    required String language,
    required String placeName,
  }) async {
    return await homeRepo.fetchImage(
      language: language,
      areaName: placeName,
    );
  }
}
