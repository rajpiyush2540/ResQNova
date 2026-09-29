import 'package:flutter/material.dart';

import '../models/victim.dart';

class ResourceAllocationDetailsScreen extends StatefulWidget {
  final Victim victim;

  const ResourceAllocationDetailsScreen({
    super.key,
    required this.victim,
  });

  @override
  State<ResourceAllocationDetailsScreen> createState() =>
      _ResourceAllocationDetailsScreenState();
}

class _ResourceAllocationDetailsScreenState
    extends State<ResourceAllocationDetailsScreen> {
  String rescueTeam = 'Team Alpha';
  String ambulance = 'Ambulance 01';
  String medicalKit = 'Kit 01';

  bool teamAssigned = false;
  bool ambulanceAssigned = false;
  bool kitAssigned = false;

  Color getPriorityColor(String priority) {
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

  void assignResources() {
    setState(() {
      teamAssigned = true;
      ambulanceAssigned = true;
      kitAssigned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resources assigned successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final victim = widget.victim;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Allocation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      victim.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text('Age: ${victim.age}'),
                    Text('Gender: ${victim.gender}'),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Text(
                          'Priority: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getPriorityColor(
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Assign Rescue Team',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: rescueTeam,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Team Alpha',
                  child: Text('Team Alpha'),
                ),
                DropdownMenuItem(
                  value: 'Team Bravo',
                  child: Text('Team Bravo'),
                ),
                DropdownMenuItem(
                  value: 'Team Charlie',
                  child: Text('Team Charlie'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    rescueTeam = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Assign Ambulance',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: ambulance,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Ambulance 01',
                  child: Text('Ambulance 01'),
                ),
                DropdownMenuItem(
                  value: 'Ambulance 02',
                  child: Text('Ambulance 02'),
                ),
                DropdownMenuItem(
                  value: 'Ambulance 03',
                  child: Text('Ambulance 03'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    ambulance = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Assign Medical Kit',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: medicalKit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Kit 01',
                  child: Text('Medical Kit 01'),
                ),
                DropdownMenuItem(
                  value: 'Kit 02',
                  child: Text('Medical Kit 02'),
                ),
                DropdownMenuItem(
                  value: 'Kit 03',
                  child: Text('Medical Kit 03'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    medicalKit = value;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            if (victim.latitude != null &&
                victim.longitude != null)
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  title: const Text('Victim Location'),
                  subtitle: Text(
                    '${victim.latitude}, ${victim.longitude}',
                  ),
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: assignResources,
                icon: const Icon(Icons.local_shipping),
                label: const Text(
                  'ASSIGN RESOURCES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (teamAssigned)
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('Rescue Team Assigned'),
              ),

            if (ambulanceAssigned)
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('Ambulance Assigned'),
              ),

            if (kitAssigned)
              const ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('Medical Kit Assigned'),
              ),
          ],
        ),
      ),
    );
  }
}