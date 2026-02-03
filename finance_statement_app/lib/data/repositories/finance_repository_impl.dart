import '../../domain/repositories/finance_repository.dart';
import '../datasources/database_helper.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final DatabaseHelper databaseHelper;

  FinanceRepositoryImpl({required this.databaseHelper});

  @override
  Future<List<Account>> getAccounts() async {
    return await databaseHelper.readAllAccounts();
  }

  @override
  Future<Account?> getAccount(int id) async {
    return await databaseHelper.readAccount(id);
  }

  @override
  Future<Account> createAccount(Account account) async {
    return await databaseHelper.createAccount(account);
  }

  @override
  Future<void> deleteAccount(int id) async {
    await databaseHelper.deleteAccount(id);
  }

  @override
  Future<List<TransactionModel>> getTransactions(int accountId) async {
    return await databaseHelper.readTransactionsByAccount(accountId);
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    return await databaseHelper.createTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await databaseHelper.deleteTransaction(id);
  }
}
