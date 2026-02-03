import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';

abstract class FinanceRepository {
  Future<List<Account>> getAccounts();
  Future<Account?> getAccount(int id);
  Future<Account> createAccount(Account account);
  Future<void> deleteAccount(int id);

  Future<List<TransactionModel>> getTransactions(int accountId);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(int id);
}
