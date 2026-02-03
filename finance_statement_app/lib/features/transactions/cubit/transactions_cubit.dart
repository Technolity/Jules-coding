import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/finance_repository.dart';
import '../../../data/models/transaction_model.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final FinanceRepository _repository;

  TransactionsCubit(this._repository) : super(TransactionsInitial());

  Future<void> loadTransactions(int accountId) async {
    emit(TransactionsLoading());
    try {
      // 1. Get Account for initial balance
      final account = await _repository.getAccount(accountId);
      if (account == null) {
        emit(const TransactionsError("Account not found"));
        return;
      }

      // 2. Get Transactions
      // The repo returns them ordered by Date DESC. We need ASC to calculate running balance correctly.
      final transactions = await _repository.getTransactions(accountId);

      // Sort ASC for calculation
      // Note: TransactionModel needs comparable or we do it manually.
      final sortedTransactions = List<TransactionModel>.from(transactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      double runningBalance = account.initialBalance;
      final List<StatementEntry> statement = [];

      for (var tx in sortedTransactions) {
        if (tx.type == TransactionType.credit) {
          runningBalance += tx.amount;
        } else {
          runningBalance -= tx.amount;
        }
        statement.add(StatementEntry(transaction: tx, balanceAfter: runningBalance));
      }

      // 3. Reverse for display (Newest First)
      final reversedStatement = statement.reversed.toList();

      emit(TransactionsLoaded(
        statement: reversedStatement,
        currentBalance: runningBalance,
        account: account,
      ));
    } catch (e) {
      emit(TransactionsError("Failed to load transactions: $e"));
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.createTransaction(transaction);
      loadTransactions(transaction.accountId);
    } catch (e) {
      emit(TransactionsError("Failed to add transaction: $e"));
    }
  }

  Future<void> deleteTransaction(int id, int accountId) async {
    try {
      await _repository.deleteTransaction(id);
      loadTransactions(accountId);
    } catch (e) {
      emit(TransactionsError("Failed to delete transaction: $e"));
    }
  }
}
