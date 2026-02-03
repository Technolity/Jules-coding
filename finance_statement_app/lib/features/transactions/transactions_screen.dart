import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/finance_repository_impl.dart'; // Access to type for DI
import '../../data/datasources/database_helper.dart'; // To get instance
import 'cubit/transactions_cubit.dart';
import 'cubit/transactions_state.dart';
import 'add_transaction_screen.dart';
import '../../core/utils/export_service.dart';

class TransactionsScreen extends StatelessWidget {
  final int accountId;

  const TransactionsScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    // We need to provide the TransactionsCubit here.
    // We can get the repository from context if we provided it up top,
    // or just re-instantiate since it's just a wrapper around the singleton DB Helper.
    // Better to provide Repository at the top in main.dart via RepositoryProvider.
    // But in main.dart I passed it to MyApp. I didn't use RepositoryProvider.
    // Let's rely on the singleton pattern of DatabaseHelper for now, constructing repo here is cheap.
    // Ideally we'd update main.dart to use RepositoryProvider.

    return BlocProvider(
      create: (context) => TransactionsCubit(
        FinanceRepositoryImpl(databaseHelper: DatabaseHelper.instance)
      )..loadTransactions(accountId),
      child: const TransactionsView(),
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement'),
        actions: [
          BlocBuilder<TransactionsCubit, TransactionsState>(
            builder: (context, state) {
              if (state is TransactionsLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () {
                        ExportService.exportPdf(state.account, state.statement);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.table_chart),
                      onPressed: () {
                        ExportService.exportCsv(state.account, state.statement);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Exporting CSV...")),
                        );
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            final currencyFormat = NumberFormat.simpleCurrency();
            final dateFormat = DateFormat('yyyy-MM-dd');

            return Column(
              children: [
                // Header: Current Balance
                GlassContainer(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current Balance",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        currencyFormat.format(state.currentBalance),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Transaction List
                Expanded(
                  child: state.statement.isEmpty
                  ? const Center(child: Text("No transactions yet."))
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.statement.length,
                    itemBuilder: (context, index) {
                      final entry = state.statement[index];
                      final tx = entry.transaction;
                      final isCredit = tx.type == TransactionType.credit;
                      final color = isCredit ? Colors.green[800] : Colors.red[800];
                      final sign = isCredit ? "+" : "-";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormat.format(tx.date),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    "Bal: ${currencyFormat.format(entry.balanceAfter)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontSize: 12
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.partyName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (tx.description != null && tx.description!.isNotEmpty)
                                          Text(
                                            tx.description!,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "$sign${currencyFormat.format(tx.amount)}",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is TransactionsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           final state = context.read<TransactionsCubit>().state;
           if (state is TransactionsLoaded) {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => AddTransactionScreen(accountId: state.accountId)),
             ).then((value) {
               if (value == true && context.mounted) {
                 context.read<TransactionsCubit>().loadTransactions(state.accountId);
               }
             });
           }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
