import 'package:flutter/material.dart';

import 'triage_screen.dart';
import 'victim_management_screen.dart';
import 'offline_gis_screen.dart';
import 'resource_allocation_screen.dart';
import 'ble_lora_screen.dart';
import 'sos_alert_screen.dart';
import 'local_sos_screen.dart';
import 'login_screen.dart';

import '../services/auth_service.dart';
import '../services/victim_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // USER ROLE
  // ============================================================
  String userRole = 'local_user';
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    loadUserRole();
  }

  Future<void> loadUserRole() async {
    final String? role = await AuthService.getRole();

    if (!mounted) return;

    setState(() {
      userRole = role ?? 'local_user';
      isLoadingRole = false;
    });
  }

  bool get isRescueTeam => userRole == 'rescue_team';

  bool get isLocalUser => userRole == 'local_user';

  // ============================================================
  // VICTIM COUNTS
  // ============================================================

  int get totalVictims {
    return VictimStore.victims.length;
  }

  int get redVictims {
    return VictimStore.victims
        .where((victim) => victim.triagePriority.toUpperCase() == 'RED')
        .length;
  }

  int get yellowVictims {
    return VictimStore.victims
        .where((victim) => victim.triagePriority.toUpperCase() == 'YELLOW')
        .length;
  }

  int get greenVictims {
    return VictimStore.victims
        .where((victim) => victim.triagePriority.toUpperCase() == 'GREEN')
        .length;
  }

  int get blackVictims {
    return VictimStore.victims
        .where((victim) => victim.triagePriority.toUpperCase() == 'BLACK')
        .length;
  }

  int get sosVictims {
    return VictimStore.victims.where((victim) => victim.sosTriggered).length;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // SOS ALERT SCREEN
  // ============================================================

  void openSosAlerts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SosAlertScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ============================================================
  // LOCAL USER SOS SCREEN
  // ============================================================

  void openLocalSos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocalSosScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ============================================================
  // REFRESH DASHBOARD
  // ============================================================

  void refreshDashboard() {
    setState(() {});
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF062B4A),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'ResQNova',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
        ),

        actions: [
          IconButton(
            onPressed: refreshDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),

          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: RefreshIndicator(
        onRefresh: () async {
          await loadUserRole();

          if (mounted) {
            setState(() {});
          }
        },

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ROLE BANNER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: isRescueTeam
                      ? Colors.red.shade50
                      : Colors.blue.shade50,

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: isRescueTeam
                        ? Colors.red.shade200
                        : Colors.blue.shade200,
                  ),
                ),

                child: Row(
                  children: [
                    Icon(
                      isRescueTeam ? Icons.groups : Icons.person,

                      color: isRescueTeam ? Colors.red : Colors.blue,

                      size: 34,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            isRescueTeam ? 'Rescue Team' : 'Local User',

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            isRescueTeam
                                ? 'Emergency response access'
                                : 'Citizen emergency access',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // OFFLINE STATUS
              // ==================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,

                  borderRadius: BorderRadius.circular(15),

                  border: Border.all(color: Colors.green.shade200),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.green, size: 28),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'OFFLINE MODE',

                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 15,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Local disaster network active',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DASHBOARD TITLE
              // ==================================================
              Text(
                isRescueTeam ? 'Rescue Team Dashboard' : 'Emergency Dashboard',

                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                isRescueTeam
                    ? 'Monitor victims, communication and resources'
                    : 'Send emergency alerts and report victims',

                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // SUMMARY CARDS
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Victims',
                      totalVictims.toString(),
                      Icons.people,
                      Colors.red,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard(
                      'Critical',
                      (redVictims + blackVictims).toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Teams',
                      '08',
                      Icons.groups,
                      Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _summaryCard('Nodes', '17', Icons.hub, Colors.green),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // TRIAGE SUMMARY
              // ==================================================
              const Text(
                'Triage Summary',

                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _priorityCard(
                      'RED',
                      redVictims,
                      Colors.red,
                      Icons.warning,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _priorityCard(
                      'YELLOW',
                      yellowVictims,
                      Colors.orange,
                      Icons.priority_high,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _priorityCard(
                      'GREEN',
                      greenVictims,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _priorityCard(
                      'BLACK',
                      blackVictims,
                      Colors.black,
                      Icons.remove_circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==================================================
              // SOS ALERTS
              // ==================================================
              GestureDetector(
                onTap: () {
                  openSosAlerts(context);
                },

                child: _priorityCard(
                  'SOS ALERTS',
                  sosVictims,
                  Colors.red,
                  Icons.sos,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // MODULES
              // ==================================================
              const Text(
                'Modules',

                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // --------------------------------------------------
              // VICTIM TRIAGE
              // --------------------------------------------------
              _moduleCard(
                context,
                Icons.medical_services,
                'Victim Triage',
                'Assess and prioritize victims',
                Colors.red,
              ),

              // --------------------------------------------------
              // LOCAL USER SOS
              // --------------------------------------------------
              if (isLocalUser)
                _moduleCard(
                  context,
                  Icons.sos,
                  'Emergency SOS',
                  'Send an emergency distress alert',
                  Colors.red,
                ),

              // --------------------------------------------------
              // RESCUE TEAM MODULES
              // --------------------------------------------------
              if (isRescueTeam)
                _moduleCard(
                  context,
                  Icons.map,
                  'Offline GIS',
                  'Victim location mapping',
                  Colors.blue,
                ),

              if (isRescueTeam)
                _moduleCard(
                  context,
                  Icons.inventory_2,
                  'Resource Allocation',
                  'Manage rescue and medical resources',
                  Colors.green,
                ),

              if (isRescueTeam)
                _moduleCard(
                  context,
                  Icons.wifi_tethering,
                  'BLE + LoRa Network',
                  'Monitor resilient communication',
                  Colors.purple,
                ),

              if (isRescueTeam)
                _moduleCard(
                  context,
                  Icons.people,
                  'Victim Management',
                  'View all registered victims',
                  Colors.orange,
                ),

              if (isRescueTeam)
                _moduleCard(
                  context,
                  Icons.warning,
                  'SOS Alerts',
                  'Monitor emergency distress alerts',
                  Colors.red,
                ),

              const SizedBox(height: 20),

              // ==================================================
              // SYSTEM STATUS
              // ==================================================
              if (isRescueTeam) ...[
                const Text(
                  'System Status',

                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _statusRow(
                  Icons.memory,
                  'ESP32 Device',
                  'Connected',
                  Colors.green,
                ),

                _statusRow(Icons.sensors, 'PPG Sensor', 'Active', Colors.green),

                _statusRow(
                  Icons.mic,
                  'Acoustic Sensor',
                  'Active',
                  Colors.green,
                ),

                _statusRow(
                  Icons.cell_tower,
                  'LoRa Mesh',
                  '17 Nodes Connected',
                  Colors.green,
                ),

                _statusRow(
                  Icons.storage,
                  'Local Server',
                  'Running',
                  Colors.green,
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 12),

          Text(
            value,

            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ============================================================
  // PRIORITY CARD
  // ============================================================

  Widget _priorityCard(String title, int count, Color color, IconData icon) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(icon, color: color, size: 30),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  count.toString(),

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODULE CARD
  // ============================================================

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),

            borderRadius: BorderRadius.circular(14),
          ),

          child: Icon(icon, color: color, size: 25),
        ),

        title: Text(
          title,

          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),

          child: Text(
            subtitle,

            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),

        // ======================================================
        // NAVIGATION
        // ======================================================
        onTap: () {
          // Victim Triage
          if (title == 'Victim Triage') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TriageScreen()),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
          // Emergency SOS
          else if (title == 'Emergency SOS') {
            openLocalSos(context);
          }
          // SOS Alerts
          else if (title == 'SOS Alerts') {
            openSosAlerts(context);
          }
          // Victim Management
          else if (title == 'Victim Management') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VictimManagementScreen(),
              ),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
          // Offline GIS
          else if (title == 'Offline GIS') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfflineGisScreen()),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
          // Resource Allocation
          else if (title == 'Resource Allocation') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResourceAllocationScreen(),
              ),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
          // BLE + LoRa
          else if (title == 'BLE + LoRa Network') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BleLoraScreen()),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          }
        },
      ),
    );
  }

  // ============================================================
  // STATUS ROW
  // ============================================================

  Widget _statusRow(IconData icon, String title, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, color: color, size: 24),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              status,

              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
