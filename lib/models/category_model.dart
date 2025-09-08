class Category {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final bool isActive;
  final int? parentId;
  final int order;
  final bool hasChildren;
  final List<Category>? children;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.isActive,
    this.parentId,
    required this.order,
    required this.hasChildren,
    this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      parentId: json['parent_id'] as int?,
      order: json['order'] as int? ?? 0,
      hasChildren: json['has_children'] as bool? ?? false,
      children: json['children'] != null
          ? List<Category>.from(
              (json['children'] as List).map(
                (x) => Category.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'image': image,
        'is_active': isActive,
        'parent_id': parentId,
        'order': order,
        'has_children': hasChildren,
        'children': children?.map((x) => x.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CategoryResponse {
  final bool success;
  final List<Category> data;

  CategoryResponse({
    required this.success,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'] as bool? ?? false,
      data: List<Category>.from(
        (json['data'] as List).map(
          (x) => Category.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
