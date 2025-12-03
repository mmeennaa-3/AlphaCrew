class PlaceModel {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final String formattedAddress;
  final List<String> categories;
  final String? imageUrl; // optional

  PlaceModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.formattedAddress,
    required this.categories,
    this.imageUrl,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final props = json['properties'];
    final geom = json['geometry'];

    String? img;
    if (props['icon'] != null) {
      img = props['icon'];
    } else if (props['photos'] != null && (props['photos'] as List).isNotEmpty) {
      img = props['photos'][0]['url'];
    }

    final String uniqueId = props['place_id'] as String? ?? 'NO_ID';

    return PlaceModel(
      id: uniqueId,
      name: props['name'] ?? '',
      lat: (geom['coordinates'][1] as num).toDouble(),
      lon: (geom['coordinates'][0] as num).toDouble(),
      formattedAddress: props['formatted'] ?? '',
      categories: List<String>.from(props['categories'] ?? []),
      imageUrl: img,
    );
  }

  factory PlaceModel.fromJoinedJson(Map<String, dynamic> json) {
    // Data comes directly from the 'places_metadata' table columns
    return PlaceModel(
        // 1. ID: Should be non-null, but we make it safe just in case.
        //    Using ?? 'UNKNOWN' provides a fallback string.
        id: json['geoapify_id'] as String? ?? 'UNKNOWN_ID', 
        
        // 2. Name: If null, use an empty string or placeholder.
        name: json['name'] as String? ?? '', 
        
        // 3. Coordinates: Should be non-null if saved correctly, but often require
        //    casting the received type (e.g., num) to double.
        lat: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        lon: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        
        // 4. Formatted Address: If null, use an empty string.
        formattedAddress: json['formatted_address'] as String? ?? 'Address Not Found',
        
        // 5. Categories: Already handles null by using the string? cast.
        //    We ensure the categories list is correctly created.
        categories: [json['category'] as String? ?? ''], 
        
        imageUrl: null, 
    );
}
}
