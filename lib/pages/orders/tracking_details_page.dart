import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '/common/common_layout.dart';
import 'package:go_router/go_router.dart';

class TrackingDetailsPage extends StatelessWidget {
  final String orderId;

  const TrackingDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    final mockTracking = {
      'status': 'In Transit',
      'location': LatLng(12.9716, 77.5946), // Bangalore mock location
      'history': [
        {'status': 'Order Shipped', 'time': '10:00 AM'},
        {'status': 'Out for Delivery', 'time': '1:30 PM'},
        {'status': 'Delivered', 'time': '4:45 PM'},
      ],
    };

    return CommonLayout(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go('/orders/track', extra: {'orderId': orderId});
                  },
                ),
                const SizedBox(width: 4),
                const Text(
                  "Tracking Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: mockTracking['location'] as LatLng,
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
                          point: mockTracking['location'] as LatLng,
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
                // Zoom Controls
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

          // --- Order Progress Section ---
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
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
                  children: List.generate(
                    (mockTracking['history'] as List).length,
                    (index) {
                      final entry = (mockTracking['history'] as List)[index];
                      final isCompleted =
                          index < (mockTracking['history'] as List).length - 1;
                      final isLast =
                          index == (mockTracking['history'] as List).length - 1;

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
                                      isCompleted
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : Icons.access_time,
                                  size: 16,
                                  color:
                                      isCompleted
                                          ? Colors.white
                                          : Colors.black54,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
