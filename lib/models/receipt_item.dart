class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({
    required this.name,
    required this.price,
  });

  // Convert this item to a Map for JSON storage in the database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  // Factory constructor to create from Map
  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
    );
  }
}
