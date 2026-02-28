class aiModel {
  bool isMe;
  String text;

  //<editor-fold desc="Data Methods">
  aiModel({required this.isMe, required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is aiModel &&
          runtimeType == other.runtimeType &&
          isMe == other.isMe &&
          text == other.text);

  @override
  int get hashCode => isMe.hashCode ^ text.hashCode;

  @override
  String toString() {
    return 'aiModel{'
            ' isMe: $isMe,' +
        ' text: $text,' +
        '}';
  }

  aiModel copyWith({bool? isMe, String? text}) {
    return aiModel(isMe: isMe ?? this.isMe, text: text ?? this.text);
  }

  Map<String, dynamic> toMap() {
    return {'isMe': isMe, 'text': text};
  }

  factory aiModel.fromMap(Map<String, dynamic> map) {
    return aiModel(isMe: map['isMe'] as bool, text: map['text'] as String);
  }

  //</editor-fold>
}
