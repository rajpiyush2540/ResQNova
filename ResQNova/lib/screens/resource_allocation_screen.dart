import 'package:flutter/material.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';

class ResourceAllocationScreen extends StatefulWidget {
  const ResourceAllocationScreen({super.key});

  @override
  State<ResourceAllocationScreen> createState() =>
      _ResourceAllocationScreenState();
}

class _ResourceAllocationScreenState
    extends State<ResourceAllocationScreen> {
  List<Victim> get victims => VictimStore.victims;

  int countPriority(String priority) {
    return victims
        .where(
          (victim) =>
              victim.triagePriority.toUpperCase() == priority,
        )
        .length;
  }

  int get activeSosCount {
    return victims.where((victim) => victim.sosTriggered).length;
  }

  int get gpsCount {
    return victims
        .where(
          (victim) =>
              victim.latitude != null &&
              victim.longitude != null,
        )
        .length;
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
        return Colors.blue;
    }
  }

  IconData priorityIcon(String priority) {
    switch (priority) {
      case 'RED':
        return Icons.priority_high;
      case 'YELLOW':
        return Icons.warning;
      case 'GREEN':
        return Icons.check_circle;
      case 'BLACK':
        return Icons.person_off;
      default:
        return Icons.person;
    }
  }

  void showPriorityVictims(String priority) {
    final filteredVictims = victims
        .where(
          (victim) =>
              victim.triagePriority.toUpperCase() == priority,
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 15),

                Text(
                  '$priority Priority Victims',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${filteredVictims.length} victim(s)',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const Divider(),

                Expanded(
                  child: filteredVictims.isEmpty
                      ? const Center(
                          child: Text(
                            'No victims in this category.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredVictims.length,
                          itemBuilder: (context, index) {
                            final victim = filteredVictims[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    priorityColor(priority),
                                child: Icon(
                                  priorityIcon(priority),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                victim.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Age: ${victim.age} • '
                                'Gender: ${victim.gender}',
                              ),
                              trailing: victim.sosTriggered
                                  ? Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'SOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget priorityCard({
    required String priority,
    required String title,
    required String description,
  }) {
    final count = countPriority(priority);
    final color = priorityColor(priority);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showPriorityVictims(priority),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: color,
                child: Icon(
                  priorityIcon(priority),
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$count',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 7),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resource Allocation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 45,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Emergency Resource Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Use victim priority to determine '
                      'where emergency resources are needed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                statisticCard(
                  title: 'Total Victims',
                  value: '${victims.length}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                statisticCard(
                  title: 'Active SOS',
                  value: '$activeSosCount',
                  icon: Icons.sos,
                  color: Colors.red,
                ),
                statisticCard(
                  title: 'GPS Located',
                  value: '$gpsCount',
                  icon: Icons.location_on,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Triage Resource Priority',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            priorityCard(
              priority: 'RED',
              title: 'RED — Immediate',
              description:
                  'Critical victims requiring immediate medical attention.',
            ),

            priorityCard(
              priority: 'YELLOW',
              title: 'YELLOW — Urgent',
              description:
                  'Victims requiring medical attention but currently stable.',
            ),

            priorityCard(
              priority: 'GREEN',
              title: 'GREEN — Minor',
              description:
                  'Walking wounded and victims with minor injuries.',
            ),

            priorityCard(
              priority: 'BLACK',
              title: 'BLACK — Deceased/Expectant',
              description:
                  'Victims with no signs of breathing according to triage.',
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap any priority category to view '
                        'the victims assigned to it.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
