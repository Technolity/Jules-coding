import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class TransactionModel extends Equatable {
  final int? id;
  final int accountId;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String partyName;
  final String? description;

  const TransactionModel({
    this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.date,
    required this.partyName,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'amount': amount,
      'type': type.name, // 'credit' or 'debit'
      'date': date.toIso8601String(),
      'party_name': partyName,
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.parse(map['date'] as String),
      partyName: map['party_name'] as String,
      description: map['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, accountId, amount, type, date, partyName, description];
}
