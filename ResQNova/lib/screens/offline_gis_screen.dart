import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';

class OfflineGisScreen extends StatefulWidget {
  const OfflineGisScreen({super.key});

  @override
  State<OfflineGisScreen> createState() => _OfflineGisScreenState();
}

class _OfflineGisScreenState extends State<OfflineGisScreen> {
  final MapController mapController = MapController();

  List<Victim> get gpsVictims {
    return VictimStore.victims
        .where(
          (victim) =>
              victim.latitude != null && victim.longitude != null,
        )
        .toList();
  }

  Color getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'YELLOW':
        return Colors.orange;
      case 'GREEN':
        return Colors.green;
      case 'BLACK':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }

  IconData getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'RED':
        return Icons.priority_high;
      case 'YELLOW':
        return Icons.warning;
      case 'GREEN':
        return Icons.check_circle;
      case 'BLACK':
        return Icons.person_off;
      default:
        return Icons.location_on;
    }
  }

  void showVictimDetails(Victim victim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final Color priorityColor =
            getPriorityColor(victim.triagePriority);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: priorityColor,
                      child: Icon(
                        getPriorityIcon(victim.triagePriority),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        victim.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _infoRow(
                  Icons.badge,
                  'Victim ID',
                  victim.id,
                ),

                _infoRow(
                  Icons.cake,
                  'Age',
                  '${victim.age} years',
                ),

                _infoRow(
                  Icons.person,
                  'Gender',
                  victim.gender,
                ),

                _infoRow(
                  Icons.medical_services,
                  'Triage Priority',
                  victim.triagePriority,
                  valueColor: priorityColor,
                ),

                _infoRow(
                  Icons.sos,
                  'SOS Status',
                  victim.sosTriggered ? 'ACTIVE' : 'Not Active',
                  valueColor:
                      victim.sosTriggered ? Colors.red : Colors.green,
                ),

                _infoRow(
                  Icons.location_on,
                  'Latitude',
                  victim.latitude!.toStringAsFixed(6),
                ),

                _infoRow(
                  Icons.location_on,
                  'Longitude',
                  victim.longitude!.toStringAsFixed(6),
                ),

                _infoRow(
                  Icons.access_time,
                  'Saved',
                  _formatDate(victim.timestamp),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      mapController.move(
                        LatLng(
                          victim.latitude!,
                          victim.longitude!,
                        ),
                        17,
                      );
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('SHOW ON MAP'),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  LatLng get initialLocation {
    if (gpsVictims.isNotEmpty) {
      final victim = gpsVictims.first;

      return LatLng(
        victim.latitude!,
        victim.longitude!,
      );
    }

    // Default location if no victim GPS is available.
    return const LatLng(22.5726, 88.3639);
  }

  List<Marker> buildMarkers() {
    return gpsVictims.map((victim) {
      final Color markerColor =
          getPriorityColor(victim.triagePriority);

      return Marker(
        point: LatLng(
          victim.latitude!,
          victim.longitude!,
        ),
        width: victim.sosTriggered ? 70 : 55,
        height: victim.sosTriggered ? 70 : 55,
        child: GestureDetector(
          onTap: () => showVictimDetails(victim),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (victim.sosTriggered)
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.20),
                  ),
                ),

              Icon(
                victim.sosTriggered
                    ? Icons.sos
                    : getPriorityIcon(victim.triagePriority),
                size: victim.sosTriggered ? 48 : 40,
                color: victim.sosTriggered
                    ? Colors.red
                    : markerColor,
              ),

              if (victim.sosTriggered)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void showAllVictims() {
    if (gpsVictims.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No saved victims with GPS coordinates found.',
          ),
        ),
      );
      return;
    }

    if (gpsVictims.length == 1) {
      mapController.move(
        initialLocation,
        17,
      );
      return;
    }

    double minLat = gpsVictims.first.latitude!;
    double maxLat = gpsVictims.first.latitude!;
    double minLng = gpsVictims.first.longitude!;
    double maxLng = gpsVictims.first.longitude!;

    for (final victim in gpsVictims) {
      final lat = victim.latitude!;
      final lng = victim.longitude!;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    mapController.move(
      LatLng(centerLat, centerLng),
      14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final victims = gpsVictims;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline GIS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Show all victims',
            onPressed: showAllVictims,
            icon: const Icon(Icons.center_focus_strong),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: victims.isNotEmpty ? 16 : 5,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.resqnova',
              ),

              MarkerLayer(
                markers: buildMarkers(),
              ),
            ],
          ),

          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${victims.length} victim'
                        '${victims.length == 1 ? '' : 's'} with GPS',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (victims.any(
                      (victim) => victim.sosTriggered,
                    ))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${victims.where((v) => v.sosTriggered).length} SOS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 15,
                  runSpacing: 8,
                  children: [
                    _legendItem(
                      Colors.red,
                      'RED',
                    ),
                    _legendItem(
                      Colors.orange,
                      'YELLOW',
                    ),
                    _legendItem(
                      Colors.green,
                      'GREEN',
                    ),
                    _legendItem(
                      Colors.black,
                      'BLACK',
                    ),
                    _legendItem(
                      Colors.red,
                      'SOS',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    Color color,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
