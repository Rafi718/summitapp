class Category {
  final int? id;
  final String name;
  final int? parentId;
  final String icon;
  final String? image;

  Category({
    this.id,
    required this.name,
    this.parentId,
    required this.icon,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon': icon,
      'image': image,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      parentId: map['parent_id'] as int?,
      icon: map['icon'] as String? ?? '',
      image: map['image'] as String?,
    );
  }
}
