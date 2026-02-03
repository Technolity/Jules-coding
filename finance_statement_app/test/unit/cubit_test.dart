import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:finance_statement_app/data/models/account_model.dart';
import 'package:finance_statement_app/data/models/transaction_model.dart';
import 'package:finance_statement_app/domain/repositories/finance_repository.dart';
import 'package:finance_statement_app/features/transactions/cubit/transactions_cubit.dart';
import 'package:finance_statement_app/features/transactions/cubit/transactions_state.dart';

class MockFinanceRepository implements FinanceRepository {
  @override
  Future<Account> createAccount(Account account) async => account;

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async => transaction;

  @override
  Future<void> deleteAccount(int id) async {}

  @override
  Future<void> deleteTransaction(int id) async {}

  @override
  Future<Account?> getAccount(int id) async {
    if (id == 1) {
      return const Account(id: 1, name: 'Test Bank', accountNumber: '123', initialBalance: 1000.0);
    }
    return null;
  }

  @override
  Future<List<Account>> getAccounts() async => [];

  @override
  Future<List<TransactionModel>> getTransactions(int accountId) async {
    if (accountId == 1) {
      // Return unordered list as if from DB (but usually DB returns sorted if requested)
      // Cubit expects them from Repo.
      // Let's return 2 transactions.
      return [
        TransactionModel(id: 1, accountId: 1, amount: 200, type: TransactionType.debit, date: DateTime(2023, 1, 2), partyName: 'Store'),
        TransactionModel(id: 2, accountId: 1, amount: 500, type: TransactionType.credit, date: DateTime(2023, 1, 1), partyName: 'Salary'),
      ];
    }
    return [];
  }
}

void main() {
  group('TransactionsCubit', () {
    late MockFinanceRepository repository;

    setUp(() {
      repository = MockFinanceRepository();
    });

    // Initial Balance: 1000
    // Tx 1: +500 (Date 2023-01-01) -> Balance 1500
    // Tx 2: -200 (Date 2023-01-02) -> Balance 1300

    // Cubit should sort them by date (oldest first) to calculate:
    // 1. +500 -> 1500
    // 2. -200 -> 1300

    // And emit list reversed (Newest first):
    // 1. Tx 2 (-200), Balance After 1300
    // 2. Tx 1 (+500), Balance After 1500

    blocTest<TransactionsCubit, TransactionsState>(
      'loads transactions and calculates running balance correctly',
      build: () => TransactionsCubit(repository),
      act: (cubit) => cubit.loadTransactions(1),
      expect: () => [
        TransactionsLoading(),
        isA<TransactionsLoaded>().having(
          (state) => state.statement,
          'statement',
          (statement) {
            // Check order (Newest first)
            if (statement.length != 2) return false;
            final newest = statement[0]; // Date Jan 2
            final oldest = statement[1]; // Date Jan 1

            return newest.transaction.amount == 200 && newest.balanceAfter == 1300 &&
                   oldest.transaction.amount == 500 && oldest.balanceAfter == 1500;
          },
        ).having((state) => state.currentBalance, 'currentBalance', 1300.0),
      ],
    );
  });
}
