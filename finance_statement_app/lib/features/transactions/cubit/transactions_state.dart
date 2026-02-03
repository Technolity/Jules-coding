import 'package:equatable/equatable.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';

class StatementEntry extends Equatable {
  final TransactionModel transaction;
  final double balanceAfter;

  const StatementEntry({required this.transaction, required this.balanceAfter});

  @override
  List<Object?> get props => [transaction, balanceAfter];
}

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<StatementEntry> statement;
  final double currentBalance;
  final Account account;

  const TransactionsLoaded({
    required this.statement,
    required this.currentBalance,
    required this.account,
  });

  // Helper to keep compatibility or easy access
  int get accountId => account.id!;

  @override
  List<Object> get props => [statement, currentBalance, account];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object> get props => [message];
}
