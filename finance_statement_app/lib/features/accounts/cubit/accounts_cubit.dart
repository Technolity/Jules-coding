import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/finance_repository.dart';
import '../../../data/models/account_model.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final FinanceRepository _repository;

  AccountsCubit(this._repository) : super(AccountsInitial());

  Future<void> loadAccounts() async {
    emit(AccountsLoading());
    try {
      final accounts = await _repository.getAccounts();
      emit(AccountsLoaded(accounts));
    } catch (e) {
      emit(AccountsError("Failed to load accounts: $e"));
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      await _repository.createAccount(account);
      loadAccounts(); // Reload to update list
    } catch (e) {
      emit(AccountsError("Failed to create account: $e"));
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _repository.deleteAccount(id);
      loadAccounts();
    } catch (e) {
      emit(AccountsError("Failed to delete account: $e"));
    }
  }
}
