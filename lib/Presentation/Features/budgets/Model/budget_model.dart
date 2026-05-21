class BudgetModel {
  final String id;
  final String groupName; // Use this for display. For single categories, it's just the category name.
  final List<String> categories;
  final double budget;
  double spent;

  BudgetModel({
    required this.id,
    required this.groupName,
    required this.categories,
    required this.budget,
    this.spent = 0.0,
  });

  bool get isGrouped => categories.length > 1;
}
