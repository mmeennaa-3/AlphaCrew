import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'map_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;

  Future<void> _searchPlace(String place) async {
    if (place.isEmpty) return;

    _searchFocusNode.unfocus();
    
    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(place);
      
      if (locations.isNotEmpty) {
        LatLng newCenter = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        
        if (!context.mounted) return;
        
        // Use the initialCenter parameter name established in the MapPage fix
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapPage(center: newCenter),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found. Try a different query.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not perform search.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destinations'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Enter city, landmark, or address',
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _searchPlace(searchController.text),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
              onSubmitted: _searchPlace, // Triggers search when 'Enter' is pressed
              textInputAction: TextInputAction.search, // Visual hint on keyboard
            ),
            const SizedBox(height: 10),
            
          ],
        ),
      ),
    );
  }
}