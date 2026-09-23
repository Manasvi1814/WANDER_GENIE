class ItineraryItem {
  final int? id;
  final int tripId;
  final int dayNumber;
  final String category;
  final String name;
  final String description;
  final String time;
  final String imageUrl;

  ItineraryItem({
    this.id,
    required this.tripId,
    required this.dayNumber,
    required this.category,
    required this.name,
    required this.description,
    required this.time,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'dayNumber': dayNumber,
      'category': category,
      'name': name,
      'description': description,
      'time': time,
      'imageUrl': imageUrl,
    };
  }

  factory ItineraryItem.fromMap(Map<String, dynamic> map) {
    return ItineraryItem(
      id: map['id'],
      tripId: map['tripId'],
      dayNumber: map['dayNumber'],
      category: map['category'],
      name: map['name'],
      description: map['description'],
      time: map['time'],
      imageUrl: map['imageUrl'],
    );
  }

  ItineraryItem copyWith({
    int? id,
    int? tripId,
    int? dayNumber,
    String? category,
    String? name,
    String? description,
    String? time,
    String? imageUrl,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
