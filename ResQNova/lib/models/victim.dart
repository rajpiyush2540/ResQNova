class Victim {
  final String id;
  final String name;
  final int age;
  final String gender;

  final String triagePriority;

  final bool unconscious;
  final bool breathing;
  final bool severeBleeding;
  final bool canWalk;

  final bool ppgActive;
  final bool acousticActive;
  final bool sosTriggered;

  final double? latitude;
  final double? longitude;

  final DateTime timestamp;

  Victim({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.triagePriority,
    required this.unconscious,
    required this.breathing,
    required this.severeBleeding,
    required this.canWalk,
    required this.ppgActive,
    required this.acousticActive,
    required this.sosTriggered,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'triagePriority': triagePriority,
      'unconscious': unconscious,
      'breathing': breathing,
      'severeBleeding': severeBleeding,
      'canWalk': canWalk,
      'ppgActive': ppgActive,
      'acousticActive': acousticActive,
      'sosTriggered': sosTriggered,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Victim.fromJson(Map<String, dynamic> json) {
    return Victim(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Victim',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Unknown',
      triagePriority: json['triagePriority'] ?? '',
      unconscious: json['unconscious'] ?? false,
      breathing: json['breathing'] ?? true,
      severeBleeding: json['severeBleeding'] ?? false,
      canWalk: json['canWalk'] ?? true,
      ppgActive: json['ppgActive'] ?? false,
      acousticActive: json['acousticActive'] ?? false,
      sosTriggered: json['sosTriggered'] ?? false,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      timestamp: DateTime.tryParse(
            json['timestamp'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}