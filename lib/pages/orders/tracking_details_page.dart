import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '/common/common_layout.dart';

class TrackingDetailsPage extends StatefulWidget {
  final String orderId;

  const TrackingDetailsPage({super.key, required this.orderId});

  @override
  State<TrackingDetailsPage> createState() => _TrackingDetailsPageState();
}

class _TrackingDetailsPageState extends State<TrackingDetailsPage> {
  bool isLoading = true;
  Map<String, dynamic>? trackingData;
  final mapController = MapController();
  Timer? liveUpdateTimer;

  @override
  void initState() {
    super.initState();
    _fetchTrackingDetails();
    _startLiveTracking();
  }

  @override
  void dispose() {
    liveUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLiveTracking() {
    liveUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _fetchLiveTrackingLocation();
    });
  }

  Future<void> _fetchTrackingDetails() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/track-details',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'orderId': widget.orderId}),
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);

        setState(() {
          trackingData = {
            'location': {
              'lat': res['data']['latitude'] ?? 0.0,
              'lng': res['data']['longitude'] ?? 0.0,
            },
            'history':
                (res['data']['trackingHistory'] as List).map((entry) {
                  return {
                    'status': entry['status'],
                    'message': entry['message'] ?? '',
                    'time': DateFormat(
                      'yyyy-MM-dd – kk:mm',
                    ).format(DateTime.parse(entry['createdAt'])),
                  };
                }).toList(),
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tracking info');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _fetchLiveTrackingLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(
        'http://localhost:3000/api/MobileApp/vendor/track-live',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'orderId': widget.orderId}),
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final lat = res['data']['latitude'] ?? 0.0;
        final lng = res['data']['longitude'] ?? 0.0;

        if (mounted) {
          setState(() {
            trackingData?['location'] = {'lat': lat, 'lng': lng};
          });
          mapController.move(LatLng(lat, lng), mapController.camera.zoom);
        }
      }
    } catch (e) {
      debugPrint("Live tracking error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || trackingData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lat = trackingData!['location']['lat'];
    final lng = trackingData!['location']['lng'];
    final location = LatLng(lat, lng);
    final history = trackingData!['history'] as List<dynamic>;

    return CommonLayout(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      () => context.go(
                        '/orders/track',
                        extra: {'orderId': widget.orderId},
                      ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Tracking Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Now',
                  onPressed: _fetchLiveTrackingLocation,
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 13,
                    minZoom: 3,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.my_vendor_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _zoomButton(
                        icon: Icons.add,
                        onPressed: () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom + 1,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _zoomButton(
                        icon: Icons.remove,
                        onPressed: () {
                          mapController.move(
                            mapController.camera.center,
                            mapController.camera.zoom - 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTrackingHistory(history),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Ok"),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTrackingHistory(List<dynamic> history) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tracking Progress",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(history.length, (index) {
              final entry = history[index];
              final isCompleted = index < history.length - 1;
              final isLast = index == history.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isCompleted ? Colors.green : Colors.grey.shade300,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.access_time,
                          size: 16,
                          color: isCompleted ? Colors.white : Colors.black54,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          height: 40,
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['status'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            entry['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _zoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: Colors.blue.shade600,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: Icon(icon, color: Colors.white)),
        ),
      ),
    );
  }
}
