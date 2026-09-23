class Expense {
  final int? id;
  final int tripId;
  final String category;
  final String description;
  final double amount;
  final String date;

  Expense({
    this.id,
    required this.tripId,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      tripId: map['tripId'],
      category: map['category'],
      description: map['description'],
      amount: map['amount'],
      date: map['date'],
    );
  }

  Expense copyWith({
    int? id,
    int? tripId,
    String? category,
    String? description,
    double? amount,
    String? date,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}
