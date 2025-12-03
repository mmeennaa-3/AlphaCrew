import 'package:tourguide/core/api_error.dart';
import 'package:tourguide/core/api_execption.dart';
import 'package:tourguide/core/api_service.dart';
import 'package:tourguide/core/endpoints.dart';

import 'home_model.dart';
import 'package:dio/dio.dart';
// import 'city_page.dart';
// import 'homerepo.dart';
// import 'HomeGetx.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tourguide/notifications_page.dart';
// import 'package:tourguide/profile.dart';

// import 'home_page.dart';
// import 'search_page.dart';
// import 'likes_page.dart';

class HomeRepo {
  ApiService apiService = ApiService();
  final Dio dio = Dio();

  HomeRepo();

  Future<List<PlaceModel>> getPlaceData({
    required String categoryType,
    required double lon,
    required double lat,
    required int radius,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '$places?$categories=$categoryType&filter=circle:$lon,$lat,$radius&limit=20&apiKey=$key',
      );
      if (response.isNotEmpty) {
        final features = response['features'] as List? ?? [];
        return features.map((e) => PlaceModel.fromJson(e)).toList();
      }
      return [];
    } on ApiExceptions catch (e) {
      throw ApiError(message: e.toString());
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<String?> fetchImage({required String language, required String areaName}) async {
    final url = 'https://$language.wikipedia.org/api/rest_v1/page/summary/$areaName';
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['thumbnail'] != null && data['thumbnail'].isNotEmpty) {
          return data['thumbnail']['source'];
        }
      }
    } catch (e) {
      throw ApiError(message: e.toString());
    }
    return null;
  }
}
