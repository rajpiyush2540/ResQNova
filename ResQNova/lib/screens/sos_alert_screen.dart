import 'package:flutter/material.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';



class SosAlertScreen extends StatefulWidget {
  const SosAlertScreen({super.key});

  @override
  State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen> {
  List<Victim> get sosVictims {
    return VictimStore.victims
        .where((victim) => victim.sosTriggered == true)
        .toList();
  }

  Color priorityColor(String priority) {
    switch (priority) {
      case 'RED':
        return Colors.red;
      case 'YELLOW':
        return Colors.orange;
      case 'GREEN':
        return Colors.green;
      case 'BLACK':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  void showVictimDetails(Victim victim) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('🚨 SOS Victim Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${victim.name}'),
                const SizedBox(height: 8),
                Text('Age: ${victim.age}'),
                const SizedBox(height: 8),
                Text('Gender: ${victim.gender}'),
                const SizedBox(height: 8),
                Text('Priority: ${victim.triagePriority}'),
                const SizedBox(height: 8),
                Text(
                  'SOS: ${victim.sosTriggered ? "ACTIVE" : "RESOLVED"}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${victim.latitude ?? "Not available"}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Longitude: ${victim.longitude ?? "Not available"}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> resolveSos(Victim victim) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resolve SOS?'),
          content: Text(
            'Mark SOS alert for ${victim.name} as resolved?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('RESOLVE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // Create a new Victim object because all fields in Victim are final.
    final Victim resolvedVictim = Victim(
      id: victim.id,
      name: victim.name,
      age: victim.age,
      gender: victim.gender,
      triagePriority: victim.triagePriority,
      unconscious: victim.unconscious,
      breathing: victim.breathing,
      severeBleeding: victim.severeBleeding,
      canWalk: victim.canWalk,
      ppgActive: victim.ppgActive,
      acousticActive: victim.acousticActive,
      sosTriggered: false,
      latitude: victim.latitude,
      longitude: victim.longitude,
      timestamp: victim.timestamp,
    );

    // Find the old victim and replace it.
    final int index = VictimStore.victims.indexWhere(
      (item) => item.id == victim.id,
    );

    if (index != -1) {
      VictimStore.victims[index] = resolvedVictim;
    }

    await VictimStore.saveVictims();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SOS alert for ${victim.name} resolved.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Victim> victims = sosVictims;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alerts'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: victims.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Active SOS Alerts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All emergency alerts are clear.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sos,
                        color: Colors.red,
                        size: 45,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EMERGENCY SOS ALERT',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${victims.length} victim(s) require immediate attention.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ...victims.map(
                  (victim) => Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      victim.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Age: ${victim.age} • ${victim.gender}',
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor(
                                    victim.triagePriority,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  victim.triagePriority,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 25),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'GPS: ${victim.latitude ?? "N/A"}, '
                                  '${victim.longitude ?? "N/A"}',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    showVictimDetails(victim);
                                  },
                                  icon: const Icon(
                                    Icons.visibility,
                                  ),
                                  label: const Text('DETAILS'),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    resolveSos(victim);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle,
                                  ),
                                  label: const Text('RESOLVE'),
                                ),
                              ),
                            ],
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
}

