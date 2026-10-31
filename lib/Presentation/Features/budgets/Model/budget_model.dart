class BudgetModel {
  final String id;
  final String groupName; // Use this for display. For single categories, it's just the category name.
  final List<String> categories;
  final double budget;
  double spent;
  final String? month;

  BudgetModel({
    required this.id,
    required this.groupName,
    required this.categories,
    required this.budget,
    this.spent = 0.0,
    this.month,
  });

  bool get isGrouped => categories.length > 1;
}
