class Product {
  final int id;
  final String name;
  final String unit;
  final double sellingPrice;
  final int quantity;
  final int categoryId;
  final String categoryName;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.sellingPrice,
    required this.quantity,
    required this.categoryId,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      sellingPrice: double.parse(json['sellingPrice'].toString()),
      quantity: json['quantity'],
      categoryId: json['categoryId'],
      categoryName: json['category']['name'],
    );
  }
}