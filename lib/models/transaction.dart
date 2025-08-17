import 'package:flutter/cupertino.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String userId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Геттеры
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  bool get hasDescription => description != null && description!.isNotEmpty;
  String? get firstCategoryWord => category.split(' ').first;

  // Сеттеры через copyWith
  Transaction setTitle(String newTitle) => copyWith(title: newTitle);
  Transaction setAmount(double newAmount) => copyWith(amount: newAmount);
  Transaction setCategory(String newCategory) => copyWith(category: newCategory);
  Transaction setDate(DateTime newDate) => copyWith(date: newDate);
  Transaction setDescription(String? newDescription) => copyWith(description: newDescription);

  // Для тестирования - позволяет изменять "final" поля через метод
  @visibleForTesting
  Transaction setTestCreatedAt(DateTime newDate) => copyWith(createdAt: newDate);

  @visibleForTesting
  Transaction setTestUpdatedAt(DateTime newDate) => copyWith(updatedAt: newDate);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? 'Other',
      date: DateTime.parse(map['date']),
      userId: map['userId'] ?? '',
      description: map['description'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? userId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Transaction &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              amount == other.amount &&
              category == other.category &&
              date == other.date &&
              userId == other.userId &&
              description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      userId.hashCode ^
      description.hashCode;
}