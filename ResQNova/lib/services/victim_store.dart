import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/victim.dart';

class VictimStore {
  static final List<Victim> victims = [];

  static const String _storageKey = 'saved_victims';

  // Add a victim
  static Future<void> addVictim(Victim victim) async {
    victims.add(victim);
    await saveVictims();
  }

  // Save all victims
  static Future<void> saveVictims() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> victimData = victims.map((victim) {
      return jsonEncode(victim.toJson());
    }).toList();

    await prefs.setStringList(
      _storageKey,
      victimData,
    );
  }

  // Load victims when app starts
  static Future<void> loadVictims() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String>? victimData =
        prefs.getStringList(_storageKey);

    if (victimData == null) {
      return;
    }

    victims.clear();

    for (final String data in victimData) {
      final Map<String, dynamic> json =
          jsonDecode(data);

      victims.add(
        Victim.fromJson(json),
      );
    }
  }

  // Delete a victim
  static Future<void> deleteVictim(String id) async {
    victims.removeWhere(
      (victim) => victim.id == id,
    );

    await saveVictims();
  }

  // Clear all victims
  static Future<void> clearVictims() async {
    victims.clear();

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}