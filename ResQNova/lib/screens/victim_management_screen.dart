import 'package:flutter/material.dart';

import '../models/victim.dart';
import '../services/victim_store.dart';
import 'resource_allocation_details_screen.dart';

class VictimManagementScreen extends StatefulWidget {
  const VictimManagementScreen({super.key});

  @override
  State<VictimManagementScreen> createState() =>
      _VictimManagementScreenState();
}

class _VictimManagementScreenState
    extends State<VictimManagementScreen> {

  // ============================================================
  // GET PRIORITY COLOR
  // ============================================================

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

  // ============================================================
  // GET PRIORITY MESSAGE
  // ============================================================

  String getPriorityMessage(String priority) {
    switch (priority) {
      case 'RED':
        return 'Immediate attention required';

      case 'YELLOW':
        return 'Urgent treatment required';

      case 'GREEN':
        return 'Minor injury / can wait';

      case 'BLACK':
        return 'No breathing detected';

      default:
        return 'Priority not assigned';
    }
  }

  // ============================================================
  // LOAD VICTIMS
  // ============================================================

  Future<void> loadVictims() async {
    await VictimStore.loadVictims();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadVictims();
  }

  // ============================================================
  // OPEN RESOURCE ALLOCATION
  // ============================================================

  void openResourceAllocation(
    BuildContext context,
    Victim victim,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResourceAllocationDetailsScreen(
          victim: victim,
        ),
      ),
    );
  }

  // ============================================================
  // DELETE VICTIM
  // ============================================================

  Future<void> deleteVictim(Victim victim) async {
    await VictimStore.deleteVictim(victim.id);

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Victim deleted'),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<Victim> victims = VictimStore.victims;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Victim Management',
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

      body: victims.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No victims recorded yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Complete a triage assessment first.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadVictims,

              child: ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: victims.length,

                itemBuilder: (context, index) {
                  final Victim victim = victims[index];

                  // ==================================================
                  // PRIORITY COLOR
                  // ==================================================

                  final Color priorityColor =
                      getPriorityColor(
                    victim.triagePriority,
                  );

                  // ==================================================
                  // VICTIM CARD
                  // ==================================================

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 14,
                    ),

                    elevation: 2,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    // ==================================================
                    // INKWELL
                    // Tap card → Resource Allocation
                    // ==================================================

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(14),

                      onTap: () {
                        openResourceAllocation(
                          context,
                          victim,
                        );
                      },

                      child: Padding(
                        padding:
                            const EdgeInsets.all(14),

                        child: Column(
                          children: [

                            // ==========================================
                            // VICTIM HEADER
                            // ==========================================

                            Row(
                              children: [

                                // Priority Circle
                                CircleAvatar(
                                  radius: 28,

                                  backgroundColor:
                                      priorityColor,

                                  child: Text(
                                    victim.triagePriority,

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,

                                      fontSize: 10,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 14,
                                ),

                                // Victim Name + ID
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        victim.name,

                                        style:
                                            const TextStyle(
                                          fontSize: 18,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        'ID: ${victim.id}',

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,

                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ========================================
                                // DELETE BUTTON
                                // ========================================

                                IconButton(
                                  icon:
                                      const Icon(
                                    Icons
                                        .delete_outline,
                                    color:
                                        Colors.red,
                                  ),

                                  onPressed: () {
                                    deleteVictim(
                                      victim,
                                    );
                                  },
                                ),
                              ],
                            ),

                            const Divider(
                              height: 25,
                            ),

                            // ==========================================
                            // BASIC INFORMATION
                            // ==========================================

                            Row(
                              children: [

                                Expanded(
                                  child: infoItem(
                                    Icons.person,
                                    'Age',
                                    '${victim.age}',
                                  ),
                                ),

                                Expanded(
                                  child: infoItem(
                                    Icons.wc,
                                    'Gender',
                                    victim.gender,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==========================================
                            // TRIAGE PRIORITY
                            // ==========================================

                            Container(
                              width:
                                  double.infinity,

                              padding:
                                  const EdgeInsets.all(
                                12,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    priorityColor
                                        .withValues(
                                  alpha: 0.10,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),

                                border:
                                    Border.all(
                                  color:
                                      priorityColor
                                          .withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(
                                    'TRIAGE PRIORITY',

                                    style:
                                        TextStyle(
                                      color:
                                          priorityColor,

                                      fontSize: 12,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    victim
                                        .triagePriority,

                                    style:
                                        TextStyle(
                                      color:
                                          priorityColor,

                                      fontSize: 20,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    getPriorityMessage(
                                      victim
                                          .triagePriority,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==========================================
                            // SENSOR STATUS
                            // ==========================================

                            Row(
                              children: [

                                statusChip(
                                  'PPG',
                                  victim.ppgActive,
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                statusChip(
                                  'Acoustic',
                                  victim
                                      .acousticActive,
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                statusChip(
                                  'SOS',
                                  victim
                                      .sosTriggered,
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // ==========================================
                            // GPS LOCATION
                            // ==========================================

                            if (victim.latitude != null &&
                                victim.longitude != null)
                              Container(
                                width:
                                    double.infinity,

                                padding:
                                    const EdgeInsets.all(
                                  10,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.blue
                                          .shade50,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),

                                child: Row(
                                  children: [

                                    const Icon(
                                      Icons
                                          .location_on,
                                      color:
                                          Colors.blue,
                                      size: 20,
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),

                                    Expanded(
                                      child: Text(
                                        'GPS: '
                                        '${victim.latitude!.toStringAsFixed(6)}, '
                                        '${victim.longitude!.toStringAsFixed(6)}',

                                        style:
                                            const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(
                              height: 12,
                            ),

                            // ==========================================
                            // RESOURCE ALLOCATION BUTTON
                            // ==========================================

                            SizedBox(
                              width:
                                  double.infinity,

                              child:
                                  ElevatedButton.icon(
                                onPressed: () {
                                  openResourceAllocation(
                                    context,
                                    victim,
                                  );
                                },

                                icon: const Icon(
                                  Icons
                                      .medical_services,
                                ),

                                label: const Text(
                                  'ALLOCATE RESOURCES',
                                ),

                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFF0878D1,
                                  ),

                                  foregroundColor:
                                      Colors.white,

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 12,
                                  ),

                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  // ============================================================
  // INFORMATION ITEM
  // ============================================================

  Widget infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          size: 20,
          color: const Color(0xFF0878D1),
        ),

        const SizedBox(
          width: 8,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              title,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            Text(
              value,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget statusChip(
    String title,
    bool active,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),

        decoration:
            BoxDecoration(
          color: active
              ? Colors.green.withValues(
                  alpha: 0.10,
                )
              : Colors.grey.withValues(
                  alpha: 0.10,
                ),

          borderRadius:
              BorderRadius.circular(8),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              active
                  ? Icons.check_circle
                  : Icons.cancel,

              size: 15,

              color: active
                  ? Colors.green
                  : Colors.grey,
            ),

            const SizedBox(
              width: 4,
            ),

            Text(
              title,

              style: TextStyle(
                fontSize: 11,

                fontWeight:
                    FontWeight.bold,

                color: active
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}