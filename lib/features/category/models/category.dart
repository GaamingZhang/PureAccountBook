class Category {
  final int? id;
  final String name;
  final String icon;
  final String type;
  final bool isDefault;
  final int sortOrder;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      type: map['type'] as String,
      isDefault: (map['is_default'] as int?) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'is_default': isDefault ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    String? type,
    bool? isDefault,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.type == type &&
        other.isDefault == isDefault &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, icon, type, isDefault, sortOrder);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, type: $type)';
  }
}
