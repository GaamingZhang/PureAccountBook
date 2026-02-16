class TransactionRecord {
  final int? id;
  final double amount;
  final String type;
  final int categoryId;
  final String date;
  final String? note;
  final String createdAt;

  const TransactionRecord({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as int,
      date: map['date'] as String,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date,
      'note': note,
      'created_at': createdAt,
    };
  }

  TransactionRecord copyWith({
    int? id,
    double? amount,
    String? type,
    int? categoryId,
    String? date,
    String? note,
    String? createdAt,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionRecord &&
        other.id == id &&
        other.amount == amount &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.date == date &&
        other.note == note &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, amount, type, categoryId, date, note, createdAt);
  }

  @override
  String toString() {
    return 'TransactionRecord(id: $id, amount: $amount, type: $type, date: $date)';
  }
}
