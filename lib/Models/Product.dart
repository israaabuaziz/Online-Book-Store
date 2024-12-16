import 'package:cloud_firestore/cloud_firestore.dart';
//Prototype Desgin Pattern
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int numStock;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.numStock,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert the Product instance into a map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'numStock': numStock,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a Product instance from a Firestore document
  factory Product.fromFirestore(Map<String, dynamic> firestoreData) {
    return Product(
      id: firestoreData['id'] ?? '',
      name: firestoreData['name'] ?? '',
      category: firestoreData['category'] ?? '',
      price: (firestoreData['price'] as num).toDouble(), // Convert to double
      numStock: (firestoreData['numStock'] as num).toInt(),
      description: firestoreData['description'] ?? '',
      createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
      updatedAt: (firestoreData['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Clone method for Prototype Pattern
  Product clone({
    String? id,
    String? name,
    String? category,
    double? price,
    int? numStock,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      numStock: numStock ?? this.numStock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
