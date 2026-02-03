import 'package:flutter_test/flutter_test.dart';
import 'package:finance_statement_app/data/models/account_model.dart';
import 'package:finance_statement_app/data/models/transaction_model.dart';

void main() {
  group('Account Model', () {
    test('supports value equality', () {
      const account1 = Account(name: 'Bank A', accountNumber: '123', initialBalance: 100);
      const account2 = Account(name: 'Bank A', accountNumber: '123', initialBalance: 100);
      expect(account1, account2);
    });

    test('toMap and fromMap work correctly', () {
      const account = Account(id: 1, name: 'Bank A', accountNumber: '123', initialBalance: 100);
      final map = account.toMap();
      final fromMap = Account.fromMap(map);
      expect(fromMap, account);
    });
  });

  group('Transaction Model', () {
    test('supports value equality', () {
      final date = DateTime(2023, 1, 1);
      final tx1 = TransactionModel(accountId: 1, amount: 50, type: TransactionType.credit, date: date, partyName: 'John');
      final tx2 = TransactionModel(accountId: 1, amount: 50, type: TransactionType.credit, date: date, partyName: 'John');
      expect(tx1, tx2);
    });

    test('toMap and fromMap work correctly', () {
      final date = DateTime(2023, 1, 1);
      final tx = TransactionModel(id: 1, accountId: 1, amount: 50, type: TransactionType.credit, date: date, partyName: 'John', description: 'Test');
      final map = tx.toMap();
      final fromMap = TransactionModel.fromMap(map);
      expect(fromMap, tx);
    });
  });
}
