class addTranModel {
  String type;
  DateTime date;
  String amount;
  String wallet;
  String category;
  String note;

  //<editor-fold desc="Data Methods">
  addTranModel({
    required this.type,
    required this.date,
    required this.amount,
    required this.wallet,
    required this.category,
    required this.note,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is addTranModel &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          date == other.date &&
          amount == other.amount &&
          wallet == other.wallet &&
          category == other.category &&
          note == other.note);

  @override
  int get hashCode =>
      type.hashCode ^
      date.hashCode ^
      amount.hashCode ^
      wallet.hashCode ^
      category.hashCode ^
      note.hashCode;

  @override
  String toString() {
    return 'addTranModel{' +
        ' type: $type,' +
        ' date: $date,' +
        ' amount: $amount,' +
        ' wallet: $wallet,' +
        ' category: $category,' +
        ' note: $note,' +
        '}';
  }

  addTranModel copyWith({
    String? type,
    DateTime? date,
    String? amount,
    String? wallet,
    String? category,
    String? note,
  }) {
    return addTranModel(
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      wallet: wallet ?? this.wallet,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': this.type,
      'date': this.date,
      'amount': this.amount,
      'wallet': this.wallet,
      'category': this.category,
      'note': this.note,
    };
  }

  factory addTranModel.fromMap(Map<String, dynamic> map) {
    return addTranModel(
      type: map['type'] as String,
      date: map['date'] as DateTime,
      amount: map['amount'] as String,
      wallet: map['wallet'] as String,
      category: map['category'] as String,
      note: map['note'] as String,
    );
  }

  //</editor-fold>
}