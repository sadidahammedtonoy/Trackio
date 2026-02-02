class MonthSaving {
  final String monthKey;   // e.g. 2026-02
  final double income;
  final double expense;

  MonthSaving({
    required this.monthKey,
    required this.income,
    required this.expense,
  });

  double get saving => income - expense;
}
