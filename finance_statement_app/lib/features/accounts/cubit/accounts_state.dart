import 'package:equatable/equatable.dart';
import '../../../data/models/account_model.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;

  const AccountsLoaded(this.accounts);

  @override
  List<Object> get props => [accounts];
}

class AccountsError extends AccountsState {
  final String message;

  const AccountsError(this.message);

  @override
  List<Object> get props => [message];
}
