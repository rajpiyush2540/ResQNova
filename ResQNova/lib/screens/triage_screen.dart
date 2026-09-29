import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController ageController =
      TextEditingController();

  // ============================================================
  // VICTIM DATA
  // ============================================================

  String gender = 'Male';

  bool unconscious = false;
  bool breathing = true;
  bool severeBleeding = false;
  bool canWalk = true;
  bool sosTriggered = false;

  // ============================================================
  // TRIAGE RESULT
  // ============================================================

  String triageResult = '';

  bool isSaving = false;

  // ============================================================
  // CALCULATE TRIAGE
  // ============================================================

  void calculateTriage() {
    String result;

    if (!breathing) {
      result = 'BLACK';
    } else if (unconscious || severeBleeding) {
      result = 'RED';
    } else if (!canWalk) {
      result = 'YELLOW';
    } else {
      result = 'GREEN';
    }

    setState(() {
      triageResult = result;
    });
  }

  // ============================================================
  // GET CURRENT GPS LOCATION
  // ============================================================

  Future<Position?> getCurrentLocation() async {
    try {
      // Check whether location service is enabled.
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location service is disabled. Please enable GPS.',
            ),
          ),
        );

        return null;
      }

      // Check permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Request permission if needed.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission still denied.
      if (permission == LocationPermission.denied) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied.',
            ),
          ),
        );

        return null;
      }

      // Permission permanently denied.
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. '
              'Please enable it from app settings.',
            ),
          ),
        );

        return null;
      }

      // Get GPS position.
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get GPS location: $e',
          ),
        ),
      );

      return null;
    }
  }

  // ============================================================
  // CREATE VICTIM OBJECT
  // ============================================================

  Victim createVictim({
    double? latitude,
    double? longitude,
  }) {
    return Victim(
      id: 'VQ-${DateTime.now().millisecondsSinceEpoch}',

      name: nameController.text.trim().isEmpty
          ? 'Unknown Victim'
          : nameController.text.trim(),

      age: int.tryParse(
            ageController.text.trim(),
          ) ??
          0,

      gender: gender,

      triagePriority: triageResult,

      unconscious: unconscious,

      breathing: breathing,

      severeBleeding: severeBleeding,

      canWalk: canWalk,

      // Prototype sensor status.
      ppgActive: true,

      acousticActive: true,

      sosTriggered: sosTriggered,

      latitude: latitude,

      longitude: longitude,

      timestamp: DateTime.now(),
    );
  }

  // ============================================================
  // SAVE VICTIM
  // ============================================================

  Future<void> saveVictim() async {
    // Triage must be completed first.
    if (triageResult.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete triage first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    // Capture GPS location.
    final Position? position =
        await getCurrentLocation();

    if (!mounted) return;

    // Create victim object.
    final Victim victim = createVictim(
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    // Save victim locally.
    await VictimStore.addVictim(victim);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    // Location message.
    final String locationMessage =
        position != null
            ? 'GPS Location:\n'
                'Latitude: '
                '${position.latitude.toStringAsFixed(6)}\n'
                'Longitude: '
                '${position.longitude.toStringAsFixed(6)}'
            : 'GPS location was not available.';

    // Show saved dialog.
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Victim Saved',
          ),

          content: Text(
            'Victim: ${victim.name}\n\n'
            'Priority: ${victim.triagePriority}\n\n'
            'SOS: '
            '${victim.sosTriggered ? "ACTIVE" : "No"}\n\n'
            '$locationMessage',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // RESULT COLOR
  // ============================================================

  Color getResultColor() {
    switch (triageResult) {
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

  // ============================================================
  // RESULT MESSAGE
  // ============================================================

  String getResultMessage() {
    switch (triageResult) {
      case 'RED':
        return 'Immediate attention required';

      case 'YELLOW':
        return 'Treatment can be delayed';

      case 'GREEN':
        return 'Minor injury / can wait';

      case 'BLACK':
        return 'No breathing detected';

      default:
        return '';
    }
  }

  // ============================================================
  // STATUS SWITCH
  // ============================================================

  Widget statusSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),

        value: value,

        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // SENSOR CARD
  // ============================================================

  Widget sensorCard(
    IconData icon,
    String title,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: const Color(0xFF0878D1),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'ResQNova Triage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: const Color(0xFF062B4A),

        foregroundColor: Colors.white,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color(0xFF0878D1),

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 35,
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Victim Assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Offline-first emergency triage',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // VICTIM INFORMATION
            // ==================================================

            const Text(
              'Victim Information',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,

              decoration: InputDecoration(
                labelText: 'Victim Name',

                prefixIcon:
                    const Icon(Icons.person),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                filled: true,

                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: ageController,

              keyboardType:
                  TextInputType.number,

              decoration: InputDecoration(
                labelText: 'Age',

                prefixIcon:
                    const Icon(Icons.cake),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                filled: true,

                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Gender
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(12),

                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: gender,

                  isExpanded: true,

                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male'),
                    ),

                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female'),
                    ),

                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        gender = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SENSOR STATUS
            // ==================================================

            const Text(
              'Sensor Status',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: sensorCard(
                    Icons.favorite,
                    'PPG',
                    'Active',
                    Colors.green,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: sensorCard(
                    Icons.mic,
                    'Acoustic',
                    'Active',
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SOS BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    sosTriggered = true;
                  });

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'SOS signal activated. '
                        'GPS will be captured when saving.',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.sos,
                  size: 30,
                ),

                label: const Text(
                  'SEND SOS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  foregroundColor: Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // SOS STATUS
            // ==================================================

            if (sosTriggered)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(15),

                margin:
                    const EdgeInsets.only(
                  bottom: 20,
                ),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,

                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color: Colors.red,
                  ),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'SOS ACTIVE — GPS location '
                        'will be saved with this victim.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // EMERGENCY ASSESSMENT
            // ==================================================

            const Text(
              'Emergency Assessment',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            statusSwitch(
              'Conscious',
              'Is the victim conscious?',
              !unconscious,
              (value) {
                setState(() {
                  unconscious = !value;
                });
              },
            ),

            statusSwitch(
              'Breathing',
              'Is the victim breathing normally?',
              breathing,
              (value) {
                setState(() {
                  breathing = value;
                });
              },
            ),

            statusSwitch(
              'Severe Bleeding',
              'Is severe bleeding present?',
              severeBleeding,
              (value) {
                setState(() {
                  severeBleeding = value;
                });
              },
            ),

            statusSwitch(
              'Can Walk',
              'Can the victim walk?',
              canWalk,
              (value) {
                setState(() {
                  canWalk = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // ==================================================
            // START TRIAGE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton(
                onPressed: calculateTriage,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF062B4A),

                  foregroundColor: Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                child: const Text(
                  'START TRIAGE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TRIAGE RESULT
            // ==================================================

            if (triageResult.isNotEmpty)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: getResultColor(),

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Column(
                  children: [

                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 45,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'TRIAGE PRIORITY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      triageResult,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      getResultMessage(),
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // SAVE VICTIM
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child:
                          ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : saveVictim,

                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                              ),

                        label: Text(
                          isSaving
                              ? 'GETTING GPS...'
                              : 'SAVE VICTIM',

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white,

                          foregroundColor:
                              Colors.black,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}