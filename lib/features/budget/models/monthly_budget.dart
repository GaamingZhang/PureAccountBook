class MonthlyBudget {
  final int? id;
  final double amount;
  final String month; // YYYY-MM format
  final DateTime createdAt;
  final DateTime updatedAt;

  MonthlyBudget({
    this.id,
    required this.amount,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'month': month,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      month: map['month'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  MonthlyBudget copyWith({
    int? id,
    double? amount,
    String? month,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory MonthlyBudget.create({
    required double amount,
    required String month,
  }) {
    final now = DateTime.now();
    return MonthlyBudget(
      amount: amount,
      month: month,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'MonthlyBudget{id: $id, amount: $amount, month: $month}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthlyBudget &&
        other.id == id &&
        other.amount == amount &&
        other.month == month;
  }

  @override
  int get hashCode => id.hashCode ^ amount.hashCode ^ month.hashCode;
}
