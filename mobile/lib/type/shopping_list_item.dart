class ShoppingListItem {
  String id;
  String text;
  bool isChecked;
  String? personalNote;

  ShoppingListItem({
    required this.id,
    required this.text,
    this.isChecked = false,
    this.personalNote,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isChecked': isChecked,
    'personalNote': personalNote,
  };

  // Create from JSON for loading
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        id: json['id'],
        text: json['text'],
        isChecked: json['isChecked'] ?? false,
        personalNote: json['personalNote'],
      );
}
