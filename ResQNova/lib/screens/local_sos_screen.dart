import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';

class LocalSosScreen extends StatefulWidget {
  const LocalSosScreen({super.key});

  @override
  State<LocalSosScreen> createState() => _LocalSosScreenState();
}

class _LocalSosScreenState extends State<LocalSosScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();

  // Form values
  String selectedGender = 'Male';
  String selectedEmergency = 'Medical Emergency';

  // Location
  double? latitude;
  double? longitude;

  // Loading states
  bool gettingLocation = false;
  bool sendingSos = false;

  // ------------------------------------------------------------
  // GET LOCATION
  // ------------------------------------------------------------

  Future<void> getLocation() async {
    if (gettingLocation) {
      return;
    }

    setState(() {
      gettingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        setState(() {
          gettingLocation = false;
        });

        showMessage('Please turn on GPS/location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) {
          return;
        }

        setState(() {
          gettingLocation = false;
        });

        showMessage('Location permission was denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        setState(() {
          gettingLocation = false;
        });

        showMessage(
          'Location permission is permanently denied. '
          'Please enable it from app settings.',
        );

        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        gettingLocation = false;
      });

      showMessage('Emergency location captured successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        gettingLocation = false;
      });

      showMessage('Unable to get location.');
    }
  }

  // ------------------------------------------------------------
  // SEND SOS
  // ------------------------------------------------------------

  Future<void> sendSos() async {
    if (sendingSos) return;

    final String name = nameController.text.trim();
    final String ageText = ageController.text.trim();
    final String peopleText = peopleController.text.trim();

    // Validate name
    if (name.isEmpty) {
      showMessage('Please enter your name.');
      return;
    }

    // Validate age
    if (ageText.isEmpty) {
      showMessage('Please enter your age.');
      return;
    }

    // Validate number of people
    if (peopleText.isEmpty) {
      showMessage('Please enter number of people needing help.');
      return;
    }

    final int? age = int.tryParse(ageText);
    final int? numberOfPeople = int.tryParse(peopleText);

    if (age == null || age <= 0 || age > 120) {
      showMessage('Please enter a valid age between 1 and 120.');
      return;
    }

    if (numberOfPeople == null ||
        numberOfPeople <= 0 ||
        numberOfPeople > 1000) {
      showMessage('Please enter a valid number of people.');
      return;
    }

    // Capture location automatically if not already captured
    if (latitude == null || longitude == null) {
      await getLocation();

      if (!mounted) return;

      if (latitude == null || longitude == null) {
        showMessage('Unable to capture your emergency location.');
        return;
      }
    }

    setState(() {
      sendingSos = true;
    });

    try {
      // Create victim record
      //
      // Important:
      // Use gender: selectedGender.
      // Do not use gender7 or any other spelling.
      final Victim victim = Victim(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        age: age,
        gender: selectedGender,
        ppgActive: false,
        acousticActive: false,
        breathing: true,
        unconscious: false,
        severeBleeding: false,
        canWalk: false,
        triagePriority: 'RED',
        sosTriggered: true,
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      );
      // Save the SOS locally
      VictimStore.addVictim(victim);

      if (!mounted) return;

      setState(() {
        sendingSos = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: const Text(
              'SOS Sent Successfully',
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your emergency request has been '
                    'saved locally.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Emergency type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Emergency: $selectedEmergency',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Number of people
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.groups, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'People needing help: $numberOfPeople',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  if (latitude != null && longitude != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Location captured\n'
                        'Latitude: '
                        '${latitude!.toStringAsFixed(6)}\n'
                        'Longitude: '
                        '${longitude!.toStringAsFixed(6)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  const Text(
                    'The SOS is stored locally and can later '
                    'be transmitted through the disaster network.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('DONE'),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // Return to Home Screen
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        sendingSos = false;
      });

      showMessage('Unable to save SOS request.');
    }
  }

  // ------------------------------------------------------------
  // SHOW MESSAGE
  // ------------------------------------------------------------

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    peopleController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.sos, size: 60, color: Colors.red.shade700),
                  const SizedBox(height: 10),
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Use this feature only during a real emergency.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Information heading
            const Text(
              'Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // Name
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                hintText: 'Enter your age',
                prefixIcon: const Icon(Icons.cake),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Gender
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // Number of people
            TextField(
              controller: peopleController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of people needing help',
                hintText: 'Example: 2',
                prefixIcon: const Icon(Icons.groups),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Emergency type
            DropdownButtonFormField<String>(
              initialValue: selectedEmergency,
              decoration: InputDecoration(
                labelText: 'Emergency Type',
                prefixIcon: const Icon(Icons.warning),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Medical Emergency',
                  child: Text('Medical Emergency'),
                ),
                DropdownMenuItem(value: 'Accident', child: Text('Accident')),
                DropdownMenuItem(
                  value: 'Building Collapse',
                  child: Text('Building Collapse'),
                ),
                DropdownMenuItem(value: 'Fire', child: Text('Fire')),
                DropdownMenuItem(value: 'Flood', child: Text('Flood')),
                DropdownMenuItem(value: 'Trapped', child: Text('Trapped')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedEmergency = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // Location heading
            const Text(
              'Emergency Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Location card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        latitude != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: latitude != null ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          latitude != null
                              ? 'Location captured'
                              : 'Location not captured',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: latitude != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (latitude != null && longitude != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Latitude: '
                      '${latitude!.toStringAsFixed(6)}\n'
                      'Longitude: '
                      '${longitude!.toStringAsFixed(6)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: gettingLocation ? null : getLocation,
                      icon: gettingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        gettingLocation
                            ? 'Getting Location...'
                            : 'Capture My Location',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Send SOS button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: sendingSos ? null : sendSos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: sendingSos
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sos, size: 28),
                label: Text(
                  sendingSos ? 'SENDING SOS...' : 'SEND EMERGENCY SOS',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                'SOS will be stored locally for '
                'disaster-network delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
