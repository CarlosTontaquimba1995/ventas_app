class Category {
  final String id;
  final String name;
  final String icon;
  final int itemCount;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.itemCount = 0,
    required this.color,
  });

  // Sample categories for our wholesale store
  static List<Category> sampleCategories = [
    Category(
      id: '1',
      name: 'Beverages',
      icon: 'assets/icons/drink.png',
      itemCount: 24,
      color: '0xFF4CAF50', // Green
    ),
    Category(
      id: '2',
      name: 'Groceries',
      icon: 'assets/icons/groceries.png',
      itemCount: 36,
      color: '0xFF2196F3', // Blue
    ),
    Category(
      id: '3',
      name: 'Household',
      icon: 'assets/icons/household.png',
      itemCount: 18,
      color: '0xFFFF9800', // Orange
    ),
    Category(
      id: '4',
      name: 'Snacks',
      icon: 'assets/icons/snacks.png',
      itemCount: 42,
      color: '0xFFE91E63', // Pink
    ),
    Category(
      id: '5',
      name: 'Personal Care',
      icon: 'assets/icons/personal_care.png',
      itemCount: 15,
      color: '0xFF9C27B0', // Purple
    ),
    Category(
      id: '6',
      name: 'Others',
      icon: 'assets/icons/more.png',
      itemCount: 12,
      color: '0xFF607D8B', // Blue Grey
    ),
  ];
}
