class SavedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime? visitDateTime;
  final bool isFavorite;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.visitDateTime,
    this.isFavorite = false,
  });
}