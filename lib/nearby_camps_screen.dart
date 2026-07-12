import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyCampsScreen extends StatefulWidget {
  const NearbyCampsScreen({super.key});

  @override
  State<NearbyCampsScreen> createState() => _NearbyCampsScreenState();
}

class _NearbyCampsScreenState extends State<NearbyCampsScreen> {
  late GoogleMapController mapController;
  List<dynamic> allCamps = [];
  Set<Marker> markers = {};
  final TextEditingController _searchController = TextEditingController();
  final Color appColor = const Color(0xFF1F48FF);

  Position? userPosition;
  Map<String, dynamic>? nearestCamp;
  StreamSubscription<Position>? positionStream;
  List<dynamic> filteredCamps = [];

  @override
  void initState() {
    super.initState();
    loadCampsData();
    _initLocationTracking();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> loadCampsData() async {
    String jsonString = await rootBundle.loadString('assets/camps_india.json');
    setState(() {
      allCamps = json.decode(jsonString);
    });
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        userPosition = position;
      });
      if (filteredCamps.isNotEmpty) {
        _updateNearestCampAndMarkers();
      }
    });

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userPosition = pos;
    });
  }

  void searchCity(String cityName) {
    filteredCamps = allCamps.where((camp) =>
      camp["city"].toString().toLowerCase() == cityName.trim().toLowerCase()).toList();

    if (filteredCamps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No camps found for '$cityName'")),
      );

      setState(() {
        markers.clear();
        nearestCamp = null;
      });
      return;
    }

    double avgLat = 0;
    double avgLng = 0;
    for (var camp in filteredCamps) {
      avgLat += camp["lat"];
      avgLng += camp["lng"];
    }
    avgLat /= filteredCamps.length;
    avgLng /= filteredCamps.length;

    mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(avgLat, avgLng), 13));
    _updateNearestCampAndMarkers();
  }

  void _updateNearestCampAndMarkers() {
    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    Set<Marker> cityMarkers = {};

    for (var camp in filteredCamps) {
      final lat = camp["lat"];
      final lng = camp["lng"];

      if (userPosition != null) {
        double dist = _calculateDistance(userPosition!.latitude, userPosition!.longitude, lat, lng);
        if (dist < minDistance) {
          minDistance = dist;
          nearest = camp;
        }
      }
    }

    for (var camp in filteredCamps) {
      final lat = camp["lat"];
      final lng = camp["lng"];
      cityMarkers.add(Marker(
        markerId: MarkerId(camp["name"]),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: camp["name"],
          snippet: "${camp["date"]} at ${camp["time"]} • ${camp["organizer"]}",
        ),
      ));
    }

    setState(() {
      markers = cityMarkers;
      nearestCamp = nearest;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _degreeToRadian(lat2 - lat1);
    final dLon = _degreeToRadian(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  // Launch Google Maps with camp coordinates
  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final uri = Uri.parse(url);
    // Use LaunchMode.externalApplication for device browser/maps app
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Camps",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: appColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Enter city name",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => searchCity(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => searchCity(_searchController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (nearestCamp != null)
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.place, color: appColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nearest Camp: ${nearestCamp!["name"]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: appColor,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${nearestCamp!["date"]} at ${nearestCamp!["time"]}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Text(
                              "Organizer: ${nearestCamp!["organizer"]}",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.directions),
                  label: Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final lat = nearestCamp!["lat"];
                    final lng = nearestCamp!["lng"];
                    _openGoogleMaps(lat, lng);
                  },
                ),
              ],
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(20.5937, 78.9629),
                zoom: 4.5,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: {
                ...markers,
                if (userPosition != null)
                  Marker(
                    markerId: const MarkerId('user_position'),
                    position: LatLng(userPosition!.latitude, userPosition!.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    infoWindow: const InfoWindow(title: 'Your Location'),
                  ),
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
