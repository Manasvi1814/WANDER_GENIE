class Trip {
  final int? id;
  final int userId;
  final String destination;
  final int numberOfDays;
  final String budget;
  final int numberOfPeople;
  final String? createdAt;

  // Cloud synchronization fields
  final String? cloudId;
  final String syncStatus; // 'synced', 'pending', 'failed'
  final String? lastSyncedAt;
  final String? updatedAt;

  Trip({
    this.id,
    required this.userId,
    required this.destination,
    required this.numberOfDays,
    required this.budget,
    required this.numberOfPeople,
    this.createdAt,
    this.cloudId,
    this.syncStatus = 'pending',
    this.lastSyncedAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'destination': destination,
      'numberOfDays': numberOfDays,
      'budget': budget,
      'numberOfPeople': numberOfPeople,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'cloudId': cloudId,
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt,
      'updatedAt': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      destination: map['destination'] as String,
      numberOfDays: map['numberOfDays'] as int,
      budget: map['budget'] as String,
      numberOfPeople: map['numberOfPeople'] as int,
      createdAt: map['createdAt'] as String?,
      cloudId: map['cloudId'] as String?,
      syncStatus: map['syncStatus'] as String? ?? 'pending',
      lastSyncedAt: map['lastSyncedAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  Trip copyWith({
    int? id,
    int? userId,
    String? destination,
    int? numberOfDays,
    String? budget,
    int? numberOfPeople,
    String? createdAt,
    String? cloudId,
    String? syncStatus,
    String? lastSyncedAt,
    String? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      budget: budget ?? this.budget,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      createdAt: createdAt ?? this.createdAt,
      cloudId: cloudId ?? this.cloudId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
