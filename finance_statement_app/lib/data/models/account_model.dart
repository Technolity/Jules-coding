import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final int? id;
  final String name;
  final String accountNumber;
  final double initialBalance;
  final int color; // store as 0xAARRGGBB

  const Account({
    this.id,
    required this.name,
    required this.accountNumber,
    this.initialBalance = 0.0,
    this.color = 0xFF424242,
  });

  Account copyWith({
    int? id,
    String? name,
    String? accountNumber,
    double? initialBalance,
    int? color,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      initialBalance: initialBalance ?? this.initialBalance,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_number': accountNumber,
      'initial_balance': initialBalance,
      'color': color,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      accountNumber: map['account_number'] as String,
      initialBalance: (map['initial_balance'] as num).toDouble(),
      color: map['color'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, accountNumber, initialBalance, color];
}
