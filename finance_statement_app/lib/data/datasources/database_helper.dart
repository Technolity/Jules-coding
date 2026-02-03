import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI for Windows/Linux if needed
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('finance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE accounts (
  id $idType,
  name $textType,
  account_number $textType,
  initial_balance $doubleType,
  color $integerType
)
    ''');

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  account_id $integerType,
  amount $doubleType,
  type $textType,
  date $textType,
  party_name $textType,
  description TEXT,
  FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
)
    ''');
  }

  // --- Account Operations ---

  Future<Account> createAccount(Account account) async {
    final db = await instance.database;
    final id = await db.insert('accounts', account.toMap());
    return account.copyWith(id: id);
  }

  Future<Account?> readAccount(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'accounts',
      columns: ['id', 'name', 'account_number', 'initial_balance', 'color'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Account>> readAllAccounts() async {
    final db = await instance.database;
    final orderBy = 'name ASC';
    final result = await db.query('accounts', orderBy: orderBy);
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<int> updateAccount(Account account) async {
    final db = await instance.database;
    return db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await instance.database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Transaction Operations ---

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    final id = await db.insert('transactions', transaction.toMap());
    return TransactionModel(
      id: id,
      accountId: transaction.accountId,
      amount: transaction.amount,
      type: transaction.type,
      date: transaction.date,
      partyName: transaction.partyName,
      description: transaction.description,
    );
  }

  Future<List<TransactionModel>> readTransactionsByAccount(int accountId) async {
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: orderBy,
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> readAllTransactions() async {
     final db = await instance.database;
     final orderBy = 'date DESC';
     final result = await db.query('transactions', orderBy: orderBy);
     return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
